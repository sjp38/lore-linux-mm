Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4A26B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 14:50:10 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id o202so15863579itc.14
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 11:50:10 -0700 (PDT)
Received: from mail-it0-x235.google.com (mail-it0-x235.google.com. [2607:f8b0:4001:c0b::235])
        by mx.google.com with ESMTPS id l15si908698ioe.10.2017.07.06.11.50.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 11:50:08 -0700 (PDT)
Received: by mail-it0-x235.google.com with SMTP id m84so12939046ita.0
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 11:50:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1499363602.26846.3.camel@redhat.com>
References: <20170706002718.GA102852@beast> <alpine.DEB.2.20.1707060841170.23867@east.gentwo.org>
 <CAGXu5jKHkKgF90LXbFvrc3fa2PAaaaYHvCbiBM-9aN16TrHL=g@mail.gmail.com>
 <alpine.DEB.2.20.1707061052380.26079@east.gentwo.org> <1499363602.26846.3.camel@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 6 Jul 2017 11:50:07 -0700
Message-ID: <CAGXu5jKQJ=9B-uXV-+BB7Y0EQJ_Xpr3OvUHr6c57TceFvNkxbw@mail.gmail.com>
Subject: Re: [PATCH v3] mm: Add SLUB free list pointer obfuscation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, Jul 6, 2017 at 10:53 AM, Rik van Riel <riel@redhat.com> wrote:
> On Thu, 2017-07-06 at 10:55 -0500, Christoph Lameter wrote:
>> On Thu, 6 Jul 2017, Kees Cook wrote:
>> > That requires a series of arbitrary reads. This is protecting
>> > against
>> > attacks that use an adjacent slab object write overflow to write
>> > the
>> > freelist pointer. This internal structure is very reliable, and has
>> > been the basis of freelist attacks against the kernel for a decade.
>>
>> These reads are not arbitrary. You can usually calculate the page struct
>> address easily from the address and then do a couple of loads to get
>> there.
>>
>> Ok so you get rid of the old attacks because we did not have that
>> hardening in effect when they designed their approaches?
>
> The hardening protects against situations where
> people do not have arbitrary code execution and
> memory read access in the kernel, with the goal
> of protecting people from acquiring those abilities.

Right. This is about blocking the escalation of attack capability. For
slab object overflow flaws, there are mainly two exploitation methods:
adjacent allocated object overwrite and adjacent freed object
overwrite (i.e. a freelist pointer overwrite). The first attack
depends heavily on which slab cache (and therefore which structures)
has been exposed by the bug. It's a very narrow and specific attack
method. The freelist attack is entirely general purpose since it
provides a reliable way to gain arbitrary write capabilities.
Protecting against that attack greatly narrows the options for an
attacker which makes attacks more expensive to create and possibly
less reliable (and reliability is crucial to successful attacks).

>> > It is a probabilistic defense, but then so is the stack protector.
>> > This is a similar defense; while not perfect it makes the class of
>> > attack much more difficult to mount.
>>
>> Na I am not convinced of the "much more difficult". Maybe they will just
>> have to upgrade their approaches to fetch the proper values to
>> decode.
>
> Easier said than done. Most of the time there is an
> unpatched vulnerability outstanding, there is only
> one known issue, before the kernel is updated by the
> user, to a version that does not have that issue.
>
> Bypassing kernel hardening typically requires the
> use of multiple vulnerabilities, and the absence of
> roadblocks (like hardening) that make a type of
> vulnerability exploitable.
>
> Between usercopy hardening, and these slub freelist
> canaries (which is what they effectively are), several
> classes of exploits are no longer usable.

Yup. I've been thinking of this patch kind of like glibc's PTR_MANGLE feature.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
