Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C06A96B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:20:59 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q64so153129604ioi.6
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:20:59 -0700 (PDT)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id e127si1966475itc.179.2017.07.26.09.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 09:20:58 -0700 (PDT)
Received: by mail-io0-x232.google.com with SMTP id m88so60981498iod.2
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:20:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1707260906230.6341@nuc-kabylake>
References: <20170706002718.GA102852@beast> <cdd42a1b-ce15-df8c-6bd1-b0943275986f@linux.com>
 <CAGXu5jKRDhvqj0TU10W10hsdixN2P+hHzpYfSVvOFZy=hW72Mg@mail.gmail.com> <alpine.DEB.2.20.1707260906230.6341@nuc-kabylake>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 26 Jul 2017 09:20:56 -0700
Message-ID: <CAGXu5jLkOjDKSZ48jOyh2voP17xXMeEnqzV_=8dGSvFmqdCZCA@mail.gmail.com>
Subject: Re: [v3] mm: Add SLUB free list pointer obfuscation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Alexander Popov <alex.popov@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Wed, Jul 26, 2017 at 7:08 AM, Christopher Lameter <cl@linux.com> wrote:
> On Tue, 25 Jul 2017, Kees Cook wrote:
>
>> > @@ -290,6 +290,10 @@ static inline void set_freepointer(struct kmem_cache *s,
>> > void *object, void *fp)
>> >  {
>> >         unsigned long freeptr_addr = (unsigned long)object + s->offset;
>> >
>> > +#ifdef CONFIG_SLAB_FREELIST_HARDENED
>> > +       BUG_ON(object == fp); /* naive detection of double free or corruption */
>> > +#endif
>> > +
>> >         *(void **)freeptr_addr = freelist_ptr(s, fp, freeptr_addr);
>>
>> What happens if, instead of BUG_ON, we do:
>>
>> if (unlikely(WARN_RATELIMIT(object == fp, "double-free detected"))
>>         return;
>
> This may work for the free fastpath but the set_freepointer function is
> use in multiple other locations. Maybe just add this to the fastpath
> instead of to this fucnction?

Do you mean do_slab_free()?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
