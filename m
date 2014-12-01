Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 04D266B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 18:13:34 -0500 (EST)
Received: by mail-ie0-f179.google.com with SMTP id rp18so10574099iec.10
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 15:13:33 -0800 (PST)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id g80si3970980iog.4.2014.12.01.15.13.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Dec 2014 15:13:32 -0800 (PST)
Received: by mail-ig0-f178.google.com with SMTP id hl2so9817554igb.17
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 15:13:32 -0800 (PST)
Date: Mon, 1 Dec 2014 15:13:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v8 01/12] Add kernel address sanitizer infrastructure.
In-Reply-To: <1417104057-20335-2-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.10.1412011512390.26834@chino.kir.corp.google.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com> <1417104057-20335-2-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, 27 Nov 2014, Andrey Ryabinin wrote:

> diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
> new file mode 100644
> index 0000000..a3a9009
> --- /dev/null
> +++ b/Documentation/kasan.txt
> @@ -0,0 +1,169 @@
> +Kernel address sanitizer
> +================
> +
> +0. Overview
> +===========
> +
> +Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
> +a fast and comprehensive solution for finding use-after-free and out-of-bounds
> +bugs.
> +
> +KASan uses compile-time instrumentation for checking every memory access,
> +therefore you will need a certain version of GCC >= 4.9.2
> +
> +Currently KASan is supported only for x86_64 architecture and requires that the
> +kernel be built with the SLUB allocator.
> +
> +1. Usage
> +=========
> +
> +To enable KASAN configure kernel with:
> +
> +	  CONFIG_KASAN = y
> +
> +and choose between CONFIG_KASAN_OUTLINE and CONFIG_KASAN_INLINE. Outline/inline
> +is compiler instrumentation types. The former produces smaller binary the
> +latter is 1.1 - 2 times faster. Inline instrumentation requires GCC 5.0 or
> +latter.
> +
> +Currently KASAN works only with the SLUB memory allocator.
> +For better bug detection and nicer report, enable CONFIG_STACKTRACE and put
> +at least 'slub_debug=U' in the boot cmdline.
> +
> +To disable instrumentation for specific files or directories, add a line
> +similar to the following to the respective kernel Makefile:
> +
> +        For a single file (e.g. main.o):
> +                KASAN_SANITIZE_main.o := n
> +
> +        For all files in one directory:
> +                KASAN_SANITIZE := n
> +

More precisely, this requires CONFIG_SLUB_DEBUG and not just CONFIG_SLUB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
