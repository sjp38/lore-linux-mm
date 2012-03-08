Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 326B06B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 03:39:52 -0500 (EST)
Received: by wibhq7 with SMTP id hq7so8138wib.2
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 00:39:50 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: Control page reclaim granularity
References: <20120308073412.GA6975@gmail.com>
Date: Thu, 08 Mar 2012 00:39:49 -0800
In-Reply-To: <20120308073412.GA6975@gmail.com> (Zheng Liu's message of "Thu, 8
	Mar 2012 15:34:13 +0800")
Message-ID: <xr93haxzo59m.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>

Zheng Liu <gnehzuil.liu@gmail.com> writes:
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

It's not exactly the same approach, but we have toyed with the idea of
charging different inodes to different cgroups.  Each cgroup would have
different soft/hard limits to allow for different cache behavior.

http://www.spinics.net/lists/linux-mm/msg06006.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
