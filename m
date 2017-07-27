Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D19676B04CE
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 18:49:01 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g21so24830909lfg.3
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 15:49:01 -0700 (PDT)
Received: from mail-lf0-f65.google.com (mail-lf0-f65.google.com. [209.85.215.65])
        by mx.google.com with ESMTPS id 40si7243751lfw.365.2017.07.27.15.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 15:49:00 -0700 (PDT)
Received: by mail-lf0-f65.google.com with SMTP id x16so9165583lfb.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 15:49:00 -0700 (PDT)
Reply-To: alex.popov@linux.com
Subject: Re: [v3] mm: Add SLUB free list pointer obfuscation
References: <20170706002718.GA102852@beast>
 <cdd42a1b-ce15-df8c-6bd1-b0943275986f@linux.com>
 <CAGXu5jKRDhvqj0TU10W10hsdixN2P+hHzpYfSVvOFZy=hW72Mg@mail.gmail.com>
 <alpine.DEB.2.20.1707260906230.6341@nuc-kabylake>
 <CAGXu5jLkOjDKSZ48jOyh2voP17xXMeEnqzV_=8dGSvFmqdCZCA@mail.gmail.com>
 <alpine.DEB.2.20.1707261154140.9167@nuc-kabylake>
From: Alexander Popov <alex.popov@linux.com>
Message-ID: <515333f5-1815-8591-503e-c0cf6941670e@linux.com>
Date: Fri, 28 Jul 2017 01:48:56 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1707261154140.9167@nuc-kabylake>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, alex.popov@linux.com

Hello Christopher and Kees,

On 26.07.2017 19:55, Christopher Lameter wrote:
> On Wed, 26 Jul 2017, Kees Cook wrote:
> 
>>>> What happens if, instead of BUG_ON, we do:
>>>>
>>>> if (unlikely(WARN_RATELIMIT(object == fp, "double-free detected"))
>>>>         return;
>>>
>>> This may work for the free fastpath but the set_freepointer function is
>>> use in multiple other locations. Maybe just add this to the fastpath
>>> instead of to this fucnction?
>>
>> Do you mean do_slab_free()?
> 
> Yes inserting these lines into do_slab_free() would simple ignore the
> double free operation in the fast path and that would be safe.

I don't really like ignoring double-free. I think, that:
  - it will hide dangerous bugs in the kernel,
  - it can make some kernel exploits more stable.
I would rather add BUG_ON to set_freepointer() behind SLAB_FREELIST_HARDENED. Is
it fine?

At the same time avoiding the consequences of some double-free errors is better
than not doing that. It may be considered as kernel "self-healing", I don't
know. I can prepare a second patch for do_slab_free(), as you described. Would
you like it?

Best regards,
Alexander

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
