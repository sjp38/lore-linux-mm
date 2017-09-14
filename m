Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 011EC6B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:15:03 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 6so5967662pgh.0
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:15:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor7606624pfb.43.2017.09.14.06.15.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Sep 2017 06:15:01 -0700 (PDT)
Date: Thu, 14 Sep 2017 22:14:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -v4 3/5] mm, swap: VMA based swap readahead
Message-ID: <20170914131446.GA12850@bgram>
References: <20170807054038.1843-1-ying.huang@intel.com>
 <20170807054038.1843-4-ying.huang@intel.com>
 <20170913014019.GB29422@bbox>
 <20170913140229.8a6cad6f017fa3ea8b53cefc@linux-foundation.org>
 <20170914075345.GA5533@bbox>
 <87h8w5jxph.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87h8w5jxph.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Thu, Sep 14, 2017 at 08:01:30PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Wed, Sep 13, 2017 at 02:02:29PM -0700, Andrew Morton wrote:
> >> On Wed, 13 Sep 2017 10:40:19 +0900 Minchan Kim <minchan@kernel.org> wrote:
> >> 
> >> > Every zram users like low-end android device has used 0 page-cluster
> >> > to disable swap readahead because it has no seek cost and works as
> >> > synchronous IO operation so if we do readahead multiple pages,
> >> > swap falut latency would be (4K * readahead window size). IOW,
> >> > readahead is meaningful only if it doesn't bother faulted page's
> >> > latency.
> >> > 
> >> > However, this patch introduces additional knob /sys/kernel/mm/swap/
> >> > vma_ra_max_order as well as page-cluster. It means existing users
> >> > has used disabled swap readahead doesn't work until they should be
> >> > aware of new knob and modification of their script/code to disable
> >> > vma_ra_max_order as well as page-cluster.
> >> > 
> >> > I say it's a *regression* and wanted to fix it but Huang's opinion
> >> > is that it's not a functional regression so userspace should be fixed
> >> > by themselves.
> >> > Please look into detail of discussion in
> >> > http://lkml.kernel.org/r/%3C1505183833-4739-4-git-send-email-minchan@kernel.org%3E
> >> 
> >> hm, tricky problem.  I do agree that linking the physical and virtual
> >> readahead schemes in the proposed fashion is unfortunate.  I also agree
> >> that breaking existing setups (a bit) is also unfortunate.
> >> 
> >> Would it help if, when page-cluster is written to zero, we do
> >> 
> >> printk_once("physical readahead disabled, virtual readahead still
> >> enabled.  Disable virtual readhead via
> >> /sys/kernel/mm/swap/vma_ra_max_order").
> >> 
> >> Or something like that.  It's pretty lame, but it should help alert the
> >> zram-readahead-disabling people to the issue?
> >
> > It was my last resort. If we cannot find other ways after all, yes, it would
> > be a minimum we should do. But it still breaks users don't/can't read/modify
> > alert and program.
> >
> > How about this?
> >
> > Can't we make vma-based readahead config option?
> > With that, users who no interest on readahead don't enable vma-based
> > readahead. In this case, page-cluster works as expected "disable readahead
> > completely" so it doesn't break anything.
> 
> Now.  Users can choose between VMA based readahead and original
> readahead via a knob as follow at runtime,
> 
> /sys/kernel/mm/swap/vma_ra_enabled

It's not a config option and is enabled by default. IOW, it's under the radar
so current users cannot notice it. That's why we want to emit big fat warnning.
when old user set 0 to page-cluster. However, as Andrew said, it's lame.

If we make it config option, product maker/kernel upgrade user can have
a chance to notice and read description so they could be aware of two weird
knobs and help to solve the problem in advance without printk_once warn.
If user has no interest about swap-readahead or skip the new config option
by mistake, it works physcial readahead which means no regression.

>  
> Best Regards,
> Huang, Ying
> 
> 
> > People who want to use upcoming vma-based readahead can enable the feature
> > and we can say such unfortunate things in config/document description
> > somewhere so upcoming users will be aware of that unforunate two knobs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
