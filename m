Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 83BCC6B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 19:23:41 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id i138so9704008oig.1
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 16:23:41 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c9si4170180oid.57.2015.01.21.16.23.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 16:23:40 -0800 (PST)
Message-ID: <54C042D2.4040809@oracle.com>
Date: Wed, 21 Jan 2015 19:22:42 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 00/17]  Kernel address sanitizer - runtime memory debugger.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Linus Torvalds <torvalds@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

On 01/21/2015 11:51 AM, Andrey Ryabinin wrote:
> Changes since v8:
> 	- Fixed unpoisoned redzones for not-allocated-yet object
> 	    in newly allocated slab page. (from Dmitry C.)
> 
> 	- Some minor non-function cleanups in kasan internals.
> 
> 	- Added ack from Catalin
> 
> 	- Added stack instrumentation. With this we could detect
> 	    out of bounds accesses in stack variables. (patch 12)
> 
> 	- Added globals instrumentation - catching out of bounds in
> 	    global varibles. (patches 13-17)
> 
> 	- Shadow moved out from vmalloc into hole between vmemmap
> 	    and %esp fixup stacks. For globals instrumentation
> 	    we will need shadow backing modules addresses.
> 	    So we need some sort of a shadow memory allocator
> 	    (something like vmmemap_populate() function, except
> 	    that it should be available after boot).
> 
> 	    __vmalloc_node_range() suits that purpose, except that
> 	    it can't be used for allocating for shadow in vmalloc
> 	    area because shadow in vmalloc is already 'allocated'
> 	    to protect us from other vmalloc users. So we need
> 	    16TB of unused addresses. And we have big enough hole
> 	    between vmemmap and %esp fixup stacks. So I moved shadow
> 	    there.

I'm not sure which new addition caused it, but I'm getting tons of
false positives from platform drivers trying to access memory they
don't "own" - because they expect to find hardware there.

I suspect we'd need to mark that memory region somehow to prevent
accesses to it from triggering warnings?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
