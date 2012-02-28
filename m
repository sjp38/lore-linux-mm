Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id A56986B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 22:03:17 -0500 (EST)
Date: Mon, 27 Feb 2012 19:04:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] HUGETLBFS: Align memory request to multiple of huge
 page size to avoid underallocating.
Message-Id: <20120227190432.55d7399a.akpm@linux-foundation.org>
In-Reply-To: <4F4C4215.5020108@utoronto.ca>
References: <1330351768-14874-1-git-send-email-steven.truelove@utoronto.ca>
	<20120227154217.0a0d5a06.akpm@linux-foundation.org>
	<4F4C4215.5020108@utoronto.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Truelove <steven.truelove@utoronto.ca>
Cc: wli@holomorphy.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 27 Feb 2012 21:55:17 -0500 Steven Truelove <steven.truelove@utoronto.ca> wrote:

> > A few things...
> >
> > - sys_mmap_pgoff() does the rounding up prior to calling
> >    hugetlb_file_setup().  ipc/shm.c:newseg() does not.
> >
> >    We should be consistent here: do it in the caller or the callee,
> >    not both (or neither!).  I guess doing it in the callee would be
> >    best.
> >
> > - The above code could/should have used ALIGN().  Or round_up(): the
> >    difference presently escapes me, even though it was so obvious that
> >    we left all these things undocumented.
> >
> > - What's the point in aligning the length if we don't also look at
> >    the start address?  If that isn't a multiple of huge_page_size(), we
> >    will need an additional page.
> >
> 
> Since mmap has an address to check and shmget does not, if the address 
> is going to be checked it will need to be in the caller.

Or pass a value of 0 from shmget.

>  If you like, I 
> will leave the size check in hugetlb_file_setup() and remove the size 
> check from mmap_pgoff, but replace it with a check of the address.  That 
> will centralize the common check (size of buffer), and let mmap_pgoff 
> check the part that is unique to it.  Patch shortly.
> 
> Steven Truelove

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
