Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 50F2F6B02F3
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 12:51:10 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id v193so58868781itc.10
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 09:51:10 -0700 (PDT)
Received: from mail-it0-x231.google.com (mail-it0-x231.google.com. [2607:f8b0:4001:c0b::231])
        by mx.google.com with ESMTPS id n66si3906852itb.107.2017.07.07.09.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 09:51:09 -0700 (PDT)
Received: by mail-it0-x231.google.com with SMTP id m84so42023642ita.0
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 09:51:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1707070844100.11769@east.gentwo.org>
References: <20170706002718.GA102852@beast> <alpine.DEB.2.20.1707060841170.23867@east.gentwo.org>
 <CAGXu5jKHkKgF90LXbFvrc3fa2PAaaaYHvCbiBM-9aN16TrHL=g@mail.gmail.com>
 <alpine.DEB.2.20.1707061052380.26079@east.gentwo.org> <1499363602.26846.3.camel@redhat.com>
 <CAGXu5jKQJ=9B-uXV-+BB7Y0EQJ_Xpr3OvUHr6c57TceFvNkxbw@mail.gmail.com> <alpine.DEB.2.20.1707070844100.11769@east.gentwo.org>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 7 Jul 2017 09:51:07 -0700
Message-ID: <CAGXu5jLmU2vrP2ftQd=EvC7-OEzV+Nm7zYEf=6C0kZuoUEBXvA@mail.gmail.com>
Subject: Re: [PATCH v3] mm: Add SLUB free list pointer obfuscation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Fri, Jul 7, 2017 at 6:50 AM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 6 Jul 2017, Kees Cook wrote:
>
>> Right. This is about blocking the escalation of attack capability. For
>> slab object overflow flaws, there are mainly two exploitation methods:
>> adjacent allocated object overwrite and adjacent freed object
>> overwrite (i.e. a freelist pointer overwrite). The first attack
>> depends heavily on which slab cache (and therefore which structures)
>> has been exposed by the bug. It's a very narrow and specific attack
>> method. The freelist attack is entirely general purpose since it
>> provides a reliable way to gain arbitrary write capabilities.
>> Protecting against that attack greatly narrows the options for an
>> attacker which makes attacks more expensive to create and possibly
>> less reliable (and reliability is crucial to successful attacks).
>
>
> The simplest thing here is to vary the location of the freelist pointer.
> That way you cannot hit the freepointer in a deterministic way
>
> The freepointer is put at offset 0 right now. But you could put it
> anywhere in the object.
>
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -3467,7 +3467,8 @@ static int calculate_sizes(struct kmem_c
>                  */
>                 s->offset = size;
>                 size += sizeof(void *);
> -       }
> +       } else
> +               s->offset = s->size / sizeof(void *) * <insert random chance logic here>
>
>  #ifdef CONFIG_SLUB_DEBUG
>         if (flags & SLAB_STORE_USER)

I wouldn't mind having both mitigations, but this alone is still open
to spraying attacks. As long as an attacker's overflow can span an
entire object, they can still hit the freelist pointer (which is
especially true with small objects). With the XOR obfuscation they
have to know where the pointer is stored (usually not available since
they have only been able to arrange "next object is unallocated"
without knowing _where_ it is allocated) and the random number (stored
separately in the cache).

If we also added a >0 offset, that would make things even less
deterministic. Though I wonder if it would make the performance impact
higher. The XOR patch right now is very light.

Yet another option would be to moving the freelist pointer over by
sizeof(void *) and adding a canary to be checked at offset 0, but that
involves additional memory fetches and doesn't protect against a bad
array index attack (rather than a linear overflow). So, I still think
the XOR patch is the right first step. Would could further harden it,
but I think it's the place to start.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
