Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 709666B0055
	for <linux-mm@kvack.org>; Fri, 22 May 2009 19:49:05 -0400 (EDT)
Received: from ::ffff:71.182.83.218 ([71.182.83.218]) by xenotime.net for <linux-mm@kvack.org>; Fri, 22 May 2009 16:49:39 -0700
Message-ID: <4A173AAE.3050500@xenotime.net>
Date: Fri, 22 May 2009 16:52:14 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: Re: [PATCH] Support for kernel memory sanitization
References: <20090520183045.GB10547@oblivion.subreption.com> <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu> <20090522113809.GB13971@oblivion.subreption.com> <20090522143914.2019dd47@lxorguk.ukuu.org.uk> <20090522180351.GC13971@oblivion.subreption.com> <20090522192158.28fe412e@lxorguk.ukuu.org.uk> <20090522232526.GG13971@oblivion.subreption.com>
In-Reply-To: <20090522232526.GG13971@oblivion.subreption.com>
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

Larry H. wrote:
> [PATCH] Support for kernel memory sanitization
> 
> This patch adds support for the CONFIDENTIAL flag to the SLAB and SLUB
> allocators. An additional GFP flag is added for use with higher level
> allocators (GFP_CONFIDENTIAL, which implies GFP_ZERO).
> 
> A boot command line option (sanitize_mem) is added for the page
> allocator to perform sanitization of all pages upon release and
> allocation.
> 
> The code is largely based off the memory sanitization feature in the
> PaX project (licensed under the GPL v2 terms) and the original
> PG_sensitive patch which allowed fine-grained marking of pages using
> a page flag. The lack of a page flag makes the gfp flag mostly useless,
> since we can't track pages with the sensitive/confidential bit, and
> properly sanitize them on release. The only way to overcome this
> limitation is to enable the sanitize_mem boot option and perform
> unconditional page sanitization.
> 
> This avoids leaking sensitive information when memory is released to
> the system after use, for example in cryptographic subsystems. More
> specifically, the following threats are addressed:
> 
> 	1. Information leaks in use-after-free or uninitialized
> 	variable usage scenarios, such as CVE-2005-0400,
> 	CVE-2009-0787 and CVE-2007-6417.
> 
> 	2. Data remanence based attacks, such as Iceman/Coldboot,
> 	which combine cold rebooting and memory image scanning
> 	to extract cryptographic secrets (ex. detecting AES key
> 	expansion blocks, RSA key patterns, etc) or other
> 	confidential information.
> 
> 	3. Re-allocation based information leaks, especially in the
> 	SLAB/SLUB allocators which use LIFO caches and might expose
> 	sensitive data out of context (when a caller allocates an
> 	object and receives a pointer to a location which was used
> 	previously by another user).
> 
> The "Shredding Your Garbage: Reducing Data Lifetime Through Secure
> Deallocation" paper by Jim Chow et. al from the Stanford University
> Department of Computer Science, explains the security implications of
> insecure deallocation, and provides extensive information with figures
> and applications thoroughly analyzed for this behavior [1]. More recently
> this issue came to widespread attention when the "Lest We Remember:
> Cold Boot Attacks on Encryption Keys" (by Halderman et. al) paper was
> published [2].
> 
> This patch has been tested on x86 and amd64, with and without HIGHMEM.
> 
> 	[1] http://www.stanford.edu/~blp/papers/shredding.html
> 	[2] http://citp.princeton.edu/memory/
> 	[3] http://marc.info/?l=linux-mm&m=124284428226461&w=2
> 	[4] http://marc.info/?t=124284431000002&r=1&w=2
> 
> Signed-off-by: Larry H. <research@subreption.com>


BTW, are you familiar with Documentation/SubmittingPatches,
section 12: Sign your work ?  in particular, this part:

"then you just add a line saying

	Signed-off-by: Random J Developer <random@developer.example.org>

using your real name (sorry, no pseudonyms or anonymous contributions.)"


-- 
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
