Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 081796B0087
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 17:05:47 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id p10so11281275pdj.13
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 14:05:47 -0700 (PDT)
Received: from mblankhorst.nl (mblankhorst.nl. [141.105.120.124])
        by mx.google.com with ESMTPS id ks9si3974419wjb.72.2014.09.25.12.34.17
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 12:34:18 -0700 (PDT)
Message-ID: <54246E32.9070406@canonical.com>
Date: Thu, 25 Sep 2014 21:34:10 +0200
From: Maarten Lankhorst <maarten.lankhorst@canonical.com>
MIME-Version: 1.0
Subject: Re: page allocator bug in 3.16?
References: <54246506.50401@hurleysoftware.com>
In-Reply-To: <54246506.50401@hurleysoftware.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Thomas Hellstrom <thellstrom@vmware.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickens <hughd@google.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

Hey,

On 25-09-14 20:55, Peter Hurley wrote:
> After several days uptime with a 3.16 kernel (generally running
> Thunderbird, emacs, kernel builds, several Chrome tabs on multiple
> desktop workspaces) I've been seeing some really extreme slowdowns.
> 
> Mostly the slowdowns are associated with gpu-related tasks, like
> opening new emacs windows, switching workspaces, laughing at internet
> gifs, etc. Because this x86_64 desktop is nouveau-based, I didn't pursue
> it right away -- 3.15 is the first time suspend has worked reliably.
> 
> This week I started looking into what the slowdown was and discovered
> it's happening during dma allocation through swiotlb (the cpus can do
> intel iommu but I don't use it because it's not the default for most users).
> 
> I'm still working on a bisection but each step takes 8+ hours to
> validate and even then I'm no longer sure I still have the 'bad'
> commit in the bisection. [edit: yup, I started over]
> 
> I just discovered a smattering of these in my logs and only on 3.16-rc+ kernels:
> Sep 25 07:57:59 thor kernel: [28786.001300] alloc_contig_range test_pages_isolated(2bf560, 2bf562) failed
> 
> This dual-Xeon box has 10GB and sysrq Show Memory isn't showing heavy
> fragmentation [1].
> 
> Besides Mel's page allocator changes in 3.16, another suspect commit is:
Maybe related, but I've been seeing page corruption in nouveau as well, with 3.15.9:

http://paste.debian.net/122800/

I think it might be an even older bug because I've been using nouveau on my desktop and it hasn't been stable for the past few releases. I'm also lazy with updating kernel, still do it from time to time.

The lookup and nvapeek warnings/crashes are not important btw, I was testing some nouveau things.
The linker trap probably is. After the second BUG Xorg was no longer able to recover.

But this was after various suspend/resume cycles, although I suspect I've hit some corruption on radeon too (on a somewhat more recent kernel) when I fiddle with vgaswitcheroo, ending up with a real massive amount of spam there, etc.

Unfortunately I haven't been able to find out what caused it yet, nor am I sure what debug options I should set in the kernel to debug this.

~Maarten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
