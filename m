Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17FBF6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 12:37:20 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m186so290514832ioa.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 09:37:20 -0700 (PDT)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id 36si24958766iop.6.2016.09.19.09.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 09:37:06 -0700 (PDT)
Received: by mail-it0-x22b.google.com with SMTP id 186so76324912itf.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 09:37:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160919030558.GI2279@X58A-UD3R>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-4-git-send-email-byungchul.park@lge.com>
 <CACbG308kitsX23FTCJiUDVpN2uusabHiN1ifao53yR5fM4Z7VA@mail.gmail.com> <20160919030558.GI2279@X58A-UD3R>
From: Nilay Vaish <nilayvaish@gmail.com>
Date: Mon, 19 Sep 2016 11:36:25 -0500
Message-ID: <CACbG30_fB6WaXysshhx55KP+vVbtYh1eT-q+RajNMBUbPCaBoQ@mail.gmail.com>
Subject: Re: [PATCH v3 03/15] lockdep: Refactor lookup_chain_cache()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On 18 September 2016 at 22:05, Byungchul Park <byungchul.park@lge.com> wrote:
> On Thu, Sep 15, 2016 at 10:33:46AM -0500, Nilay Vaish wrote:
>> On 13 September 2016 at 04:45, Byungchul Park <byungchul.park@lge.com> wrote:
>> > @@ -2215,6 +2178,75 @@ cache_hit:
>> >         return 1;
>> >  }
>> >
>> > +/*
>> > + * Look up a dependency chain.
>> > + */
>> > +static inline struct lock_chain *lookup_chain_cache(u64 chain_key)
>> > +{
>> > +       struct hlist_head *hash_head = chainhashentry(chain_key);
>> > +       struct lock_chain *chain;
>> > +
>> > +       /*
>> > +        * We can walk it lock-free, because entries only get added
>> > +        * to the hash:
>> > +        */
>> > +       hlist_for_each_entry_rcu(chain, hash_head, entry) {
>> > +               if (chain->chain_key == chain_key) {
>> > +                       debug_atomic_inc(chain_lookup_hits);
>> > +                       return chain;
>> > +               }
>> > +       }
>> > +       return NULL;
>> > +}
>>
>> Byungchul,  do you think we should increment chain_lookup_misses
>> before returning NULL from the above function?
>
> Hello,
>
> No, I don't think so.
> It will be done in add_chain_cache().
>

I think you are assuming that a call to lookup will always be followed
by add.  I thought the point of breaking the original function into
two was that each of the functions can be used individually, without
the other being called.  This means we would not increment the number
of misses when only lookup() gets called, but not add().  Or we would
increment the number of misses when only add() is called and not
lookup().

It really seems odd to me that hits get incremented in lookup and misses don't.

--
Nilay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
