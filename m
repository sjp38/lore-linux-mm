Received: from digeo-nav01.digeo.com (digeo-nav01 [192.168.1.233])
	by packet.digeo.com (8.12.8/8.12.8) with SMTP id h2FMJVPu006861
	for <linux-mm@kvack.org>; Sat, 15 Mar 2003 14:19:35 -0800 (PST)
Date: Sat, 15 Mar 2003 12:03:43 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.64-mm7 - dies on smp with raid
Message-Id: <20030315120343.71faf732.akpm@digeo.com>
In-Reply-To: <3E736505.2000106@aitel.hist.no>
References: <20030315011758.7098b006.akpm@digeo.com>
	<3E736505.2000106@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Neil Brown <neilb@cse.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

Helge Hafting <helgehaf@aitel.hist.no> wrote:
>
> mm7 crashed where mm2 works.
> The machine is a dual celeron with two scsi disks with
> some raid-1 & raid-0 partitions.
> 
> deadline or anicipatory scheduler does not make a difference.
> It dies anyway, attempting to kill init.
> 
> Here's what I managed to  write down before the 30 second reboot
> kicked in:
> 
> EIP is at md_wakeup_thread
> 
> stack:
> do_md_run
> autorun_array
> autorun_devices
> autostart_arrays
> md_ioctl
> dentry_open
> kmem_cache_free
> blkdev_ioctl
> sys_ioctl
> init
> init
> 
> This happened during the boot process. The kernel is compiled
> with gcc 2.95.4 from debian testing. The machine uses devfs
> 

A lot of md updates went into Linus's tree overnight.  Can you get some more
details for Neil?

Here is a wild guess:

diff -puN drivers/md/md.c~a drivers/md/md.c
--- 25/drivers/md/md.c~a	2003-03-15 12:02:04.000000000 -0800
+++ 25-akpm/drivers/md/md.c	2003-03-15 12:02:14.000000000 -0800
@@ -2818,6 +2818,8 @@ int md_thread(void * arg)
 
 void md_wakeup_thread(mdk_thread_t *thread)
 {
+	if (!thread)
+		return;
 	dprintk("md: waking up MD thread %p.\n", thread);
 	set_bit(THREAD_WAKEUP, &thread->flags);
 	wake_up(&thread->wqueue);

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
