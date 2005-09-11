Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8BC6EeH020447
	for <linux-mm@kvack.org>; Sun, 11 Sep 2005 08:06:14 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8BC6EHp090120
	for <linux-mm@kvack.org>; Sun, 11 Sep 2005 08:06:14 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8BC6ErV032688
	for <linux-mm@kvack.org>; Sun, 11 Sep 2005 08:06:14 -0400
Date: Sun, 11 Sep 2005 17:30:46 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: VM balancing issues on 2.6.13: dentry cache not getting shrunk enough
Message-ID: <20050911120045.GA4477@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <20050911105709.GA16369@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050911105709.GA16369@thunk.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Bharata B. Rao" <bharata@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Ted,

On Sun, Sep 11, 2005 at 06:57:09AM -0400, Theodore Ts'o wrote:
> 
> I have a T40 laptop (Pentium M processor) with 2 gigs of memory, and
> from time to time, after the system has been up for a while, the
> dentry cache grows huge, as does the ext3_inode_cache:
> 
> slabinfo - version: 2.1
> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
> dentry_cache      434515 514112    136   29    1 : tunables  120   60    0 : slabdata  17728  17728      0
> ext3_inode_cache  587635 589992    464    8    1 : tunables   54   27    0 : slabdata  73748  73749      0
> 
> Leading to an impending shortage in low memory:
> 
> LowFree:          9268 kB

Do you have the /proc/sys/fs/dentry-state output when such lowmem
shortage happens ?

> 
> It turns out I can head off the system lockup by requesting the
> formation of hugepages, which will immediately cause a dramatic
> reduction of memory usage in both high- and low- memory as various
> caches and flushed:
> 
> 	echo 100 > /proc/sys/vm/nr_hugepages
> 	echo 0 > /proc/sys/vm/nr_hugepages
> 
> The question is why isn't the kernel able to figure out how to do
> release dentry cache entries automatically when it starts thrashing due
> to a lack of low memory?   Clearly it can, since requesting hugepages
> does shrink the dentry cache:

This is a problem that Bharata has been investigating at the moment.
But he hasn't seen anything that can't be cured by a small memory
pressure - IOW, dentries do get freed under memory pressure. So
your case might be very useful. Bharata is maintaing an instrumentation
patch to collect more information and an alternative dentry aging patch 
(using rbtree). Perhaps you could try with those.

Thanks
Dipankar
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
