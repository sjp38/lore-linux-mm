Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0D83F6B025A
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 13:10:03 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id g62so173863540wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 10:10:03 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id mm10si3564381wjc.2.2016.02.17.10.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 10:10:01 -0800 (PST)
Received: by mail-wm0-f52.google.com with SMTP id a4so40297775wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 10:10:01 -0800 (PST)
Date: Wed, 17 Feb 2016 19:10:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add MM_SWAPENTS and page table when calculate
 tasksize in lowmem_scan()
Message-ID: <20160217181000.GB29370@dhcp22.suse.cz>
References: <56C2EDC1.2090509@huawei.com>
 <20160216173849.GA10487@kroah.com>
 <alpine.DEB.2.10.1602161629560.19997@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1602161629560.19997@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Xishi Qiu <qiuxishi@huawei.com>, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, zhong jiang <zhongjiang@huawei.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue 16-02-16 16:35:39, David Rientjes wrote:
> On Tue, 16 Feb 2016, Greg Kroah-Hartman wrote:
> 
> > On Tue, Feb 16, 2016 at 05:37:05PM +0800, Xishi Qiu wrote:
> > > Currently tasksize in lowmem_scan() only calculate rss, and not include swap.
> > > But usually smart phones enable zram, so swap space actually use ram.
> > 
> > Yes, but does that matter for this type of calculation?  I need an ack
> > from the android team before I could ever take such a core change to
> > this code...
> > 
> 
> The calculation proposed in this patch is the same as the generic oom 
> killer, it's an estimate of the amount of memory that will be freed if it 
> is killed and can exit.  This is better than simply get_mm_rss().
> 
> However, I think we seriously need to re-consider the implementation of 
> the lowmem killer entirely.  It currently abuses the use of TIF_MEMDIE, 
> which should ideally only be set for one thread on the system since it 
> allows unbounded access to global memory reserves.
> 
> It also abuses the user-visible /proc/self/oom_score_adj tunable: this 
> tunable is used by the generic oom killer to bias or discount a proportion 
> of memory from a process's usage.  This is the only supported semantic of 
> the tunable.  The lowmem killer uses it as a strict prioritization, so any 
> process with oom_score_adj higher than another process is preferred for 
> kill, REGARDLESS of memory usage.  This leads to priority inversion, the 
> user is unable to always define the same process to be killed by the 
> generic oom killer and the lowmem killer.  This is what happens when a 
> tunable with a very clear and defined purpose is used for other reasons.
> 
> I'd seriously consider not accepting any additional hacks on top of this 
> code until the implementation is rewritten.

Fully agreed!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
