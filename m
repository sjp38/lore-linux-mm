Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E6A6D6B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 04:35:23 -0500 (EST)
Received: by pbcup15 with SMTP id up15so1564043pbc.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 01:35:23 -0800 (PST)
Date: Thu, 8 Mar 2012 18:35:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Control page reclaim granularity
Message-ID: <20120308093514.GA28856@barrios>
References: <20120308073412.GA6975@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120308073412.GA6975@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: riel@redhat.com, kosaki.motohiro@jp.fujitsu.com

On Thu, Mar 08, 2012 at 03:34:13PM +0800, Zheng Liu wrote:
> Hi list,
> 
> Recently we encounter a problem about page reclaim.  I abstract it in here.
> The problem is that there are two different file types.  One is small index
> file, and another is large data file.  The index file is mmaped into memory,
> and application hope that they can be kept in memory and don't be reclaimed
> too frequently.  The data file is manipulted by read/write, and they should
> be reclaimed more frequently than the index file.
> 
> As previously discussion [1], Konstantin suggest me to mmap index file with
> PROT_EXEC flag.  Meanwhile he provides a patch to set a flag in mm_flags to
> increase the priority of mmaped file pages.  However, these solutions are
> not perfect.  I review the related patches (8cab4754 and c909e993) and I
> think that mmaped index file with PROT_EXEC flag is too tricky.  From the
> view of applicaton programmer, index file is a regular file that stores
> some data.  So they should be mmap with PROT_READ | PROT_WRITE rather than
> with PROT_EXEC.  As commit log said (8cab4754), the purpose of this patch
> is to keep executable code in memory to improve the response of application.
> In addition, Kongstantin's patch needs to adjust the application program.
> So in some cases, we cannot touch the code of application, and this patch is
> useless.
> 
> I have discussed with Kongstantin about this problem and we think maybe
> kernel should provide some mechanism.  For example, user can set memory
> pressure priorities for vma or inode, or mmaped pages and file pages can be
> reclaimed separately.  If someone has thought about it, please let me know.
> Any feedbacks are welcomed.  Thank you.
> 
> Previously discussion:
> 1. http://marc.info/?l=linux-mm&m=132947026019538&w=2
> 
> Regards,
> Zheng

I  think it's a regression since 2.6.28.
Before we were trying to keep mapped pages in memory(See calc_reclaim_mapped).
But we removed that routine when we applied split lru page replacement.
Rik, KOSAKI. What's the rationale?
We have to decide whether recovering that routine or creating new logic to keep
mapped page in memory.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
