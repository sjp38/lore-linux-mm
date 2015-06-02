Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 52688900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 17:27:56 -0400 (EDT)
Received: by qgdy38 with SMTP id y38so39637891qgd.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 14:27:56 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id i81si17092498qkh.107.2015.06.02.14.27.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 14:27:55 -0700 (PDT)
Received: by qkoo18 with SMTP id o18so109080890qko.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 14:27:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150602140620.08465687d7c69f851cd2a10f@linux-foundation.org>
References: <20150529150705.5fd6b7c1545ef5829f7ace93@linux-foundation.org>
 <1433168544-26301-1-git-send-email-ddstreet@ieee.org> <20150602140620.08465687d7c69f851cd2a10f@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 2 Jun 2015 17:27:34 -0400
Message-ID: <CALZtONCq7BELJFHqJZwTi66tB1VdP9VojFVUF_Li50SiLePNVw@mail.gmail.com>
Subject: Re: [PATCHv2] frontswap: allow multiple backends
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xenproject.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Jun 2, 2015 at 5:06 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon,  1 Jun 2015 10:22:24 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> Change frontswap single pointer to a singly linked list of frontswap
>> implementations.  Update Xen tmem implementation as register no longer
>> returns anything.
>>
>> Frontswap only keeps track of a single implementation; any implementation
>> that registers second (or later) will replace the previously registered
>> implementation, and gets a pointer to the previous implementation that
>> the new implementation is expected to pass all frontswap functions to
>> if it can't handle the function itself.  However that method doesn't
>> really make much sense, as passing that work on to every implementation
>> adds unnecessary work to implementations; instead, frontswap should
>> simply keep a list of all registered implementations and try each
>> implementation for any function.  Most importantly, neither of the
>> two currently existing frontswap implementations in the kernel actually
>> do anything with any previous frontswap implementation that they
>> replace when registering.
>>
>> This allows frontswap to successfully manage multiple implementations
>> by keeping a list of them all.
>>
>> ...
>>
>> -struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
>> +void frontswap_register_ops(struct frontswap_ops *ops)
>>  {
>> -     struct frontswap_ops *old = frontswap_ops;
>> -     int i;
>> -
>> -     for (i = 0; i < MAX_SWAPFILES; i++) {
>> -             if (test_and_clear_bit(i, need_init)) {
>> -                     struct swap_info_struct *sis = swap_info[i];
>> -                     /* __frontswap_init _should_ have set it! */
>> -                     if (!sis->frontswap_map)
>> -                             return ERR_PTR(-EINVAL);
>> -                     ops->init(i);
>> -             }
>> +     DECLARE_BITMAP(a, MAX_SWAPFILES);
>> +     DECLARE_BITMAP(b, MAX_SWAPFILES);
>> +     struct swap_info_struct *si;
>> +     unsigned int i;
>> +
>> +     spin_lock(&swap_lock);
>> +     plist_for_each_entry(si, &swap_active_head, list) {
>> +             if (!WARN_ON(!si->frontswap_map))
>> +                     set_bit(si->type, a);
>
> umm, DECLARE_BITMAP() doesn't initialise the storage.  Either this
> patch wasn't tested very well or you should buy me a lottery ticket!

Doh!  I'll fix and resend.

I did test it, too, but zswap doesn't care if the swap device actually
exists, it just alloc's a tree for whatever it's told.  So likely it
was allocing some extra trees there :)

>
>>       }
>> -     /*
>> -      * We MUST have frontswap_ops set _after_ the frontswap_init's
>> -      * have been called. Otherwise __frontswap_store might fail. Hence
>> -      * the barrier to make sure compiler does not re-order us.
>> +     spin_unlock(&swap_lock);
>> +
>> +     /* the new ops needs to know the currently active swap devices */
>> +     for_each_set_bit(i, a, MAX_SWAPFILES)
>> +             ops->init(i);
>> +
>> +     /* setting frontswap_ops must happen after the ops->init() calls
>> +      * above; cmpxchg implies smp_mb() which will ensure the init is
>> +      * complete at this point
>> +      */
>
> Like this, please:
>
>         /*
>          * Setting ...
>
> and sentences start with capital letters ;)

okay, okay :-)

>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
