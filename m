Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA04888
	for <linux-mm@kvack.org>; Tue, 22 Oct 2002 13:58:37 -0700 (PDT)
Message-ID: <3DB5BBFC.479BE5DD@digeo.com>
Date: Tue, 22 Oct 2002 13:58:36 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: vm scenario tool / mincore(2) functionality for regular pages?
References: <20021022184313.GA12081@outpost.ds9a.nl>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bert hubert <ahu@ds9a.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

bert hubert wrote:
> 
> I'm building a tool to subject the VM to different scenarios and I'd like to
> be able to determine if a page is swapped out or not. For a file I can
> easily determine if a page is in memory (in the page cache) or not using the
> mincore(2) system call.
> 
> I want to expand my tool so it can investigate which of its pages are
> swapped out under cache pressure or real memory pressure.
> 
> However, to do this, I need a way to determine if a page is there or if it
> is swapped out. My two questions are:
> 
>         1) is there an existing way to do this
>            (the kernel obviously knows)
> 
>         2) would it be correct to expand mincore to also work on
>            non-filebacked memory so it works for 'swap-backed' memory too?
> 

mincore needs to be taught to walk pagetables and to look up
stuff in swapcache.

Also it currently assumes that vma->vm_file is mapped linearly,
so it will return incorrect results with Ingo's nonlinear mapping
extensions.

But if we were to use Ingo's "file pte's" for all mmappings, mincore
only needs to do the pte->pagecache lookup, so it can lose the
"vma is linear" arithmetic.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
