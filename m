Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 650236B03A1
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:19:09 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k3so4289617ioe.6
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 09:19:09 -0700 (PDT)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id 188si2419306itg.18.2017.04.11.09.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 09:19:08 -0700 (PDT)
Received: by mail-io0-x22b.google.com with SMTP id t68so10367301iof.0
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 09:19:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org>
References: <20170404113022.GC15490@dhcp22.suse.cz> <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org>
 <20170404151600.GN15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org>
 <20170404194220.GT15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org>
 <20170404201334.GV15132@dhcp22.suse.cz> <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com>
 <20170411134618.GN6729@dhcp22.suse.cz> <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com>
 <20170411141956.GP6729@dhcp22.suse.cz> <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 11 Apr 2017 09:19:07 -0700
Message-ID: <CAGXu5jK1j3UWUakakFw=EfVwg+Rnovzst52+uZJYesLqLY+n5A@mail.gmail.com>
Subject: Re: [PATCH] mm: Add additional consistency check
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 11, 2017 at 9:16 AM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 11 Apr 2017, Michal Hocko wrote:
>
>>  static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
>> @@ -3813,14 +3818,18 @@ void kfree(const void *objp)
>>  {
>>       struct kmem_cache *c;
>>       unsigned long flags;
>> +     struct page *page;
>>
>>       trace_kfree(_RET_IP_, objp);
>>
>>       if (unlikely(ZERO_OR_NULL_PTR(objp)))
>>               return;
>> +     page = virt_to_head_page(obj);
>> +     if (CHECK_DATA_CORRUPTION(!PageSlab(page)))
>
> There is a flag SLAB_DEBUG_OBJECTS that is available for this check.
> Consistency checks are configuraable in the slab allocator.
>
> Mentioned that before and got this lecture about data consistency checks.

It seems that enabling the debug checks comes with a non-trivial
performance impact. I'd like to see consistency checks by default so
we can handle intentional heap corruption attacks better. This check
isn't expensive...

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
