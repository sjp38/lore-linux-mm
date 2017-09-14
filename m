Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF1A6B0253
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 04:15:51 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v82so4766566pgb.5
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 01:15:51 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id r84si1876062pfi.228.2017.09.14.01.15.49
        for <linux-mm@kvack.org>;
        Thu, 14 Sep 2017 01:15:50 -0700 (PDT)
Date: Thu, 14 Sep 2017 17:15:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -v4 3/5] mm, swap: VMA based swap readahead
Message-ID: <20170914081547.GC5533@bbox>
References: <20170807054038.1843-1-ying.huang@intel.com>
 <20170807054038.1843-4-ying.huang@intel.com>
 <20170913014019.GB29422@bbox>
 <20170913140229.8a6cad6f017fa3ea8b53cefc@linux-foundation.org>
 <87lglim77z.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lglim77z.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Thu, Sep 14, 2017 at 08:53:04AM +0800, Huang, Ying wrote:
> Hi, Andrew,
> 
> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Wed, 13 Sep 2017 10:40:19 +0900 Minchan Kim <minchan@kernel.org> wrote:
> >
> >> Every zram users like low-end android device has used 0 page-cluster
> >> to disable swap readahead because it has no seek cost and works as
> >> synchronous IO operation so if we do readahead multiple pages,
> >> swap falut latency would be (4K * readahead window size). IOW,
> >> readahead is meaningful only if it doesn't bother faulted page's
> >> latency.
> >> 
> >> However, this patch introduces additional knob /sys/kernel/mm/swap/
> >> vma_ra_max_order as well as page-cluster. It means existing users
> >> has used disabled swap readahead doesn't work until they should be
> >> aware of new knob and modification of their script/code to disable
> >> vma_ra_max_order as well as page-cluster.
> >> 
> >> I say it's a *regression* and wanted to fix it but Huang's opinion
> >> is that it's not a functional regression so userspace should be fixed
> >> by themselves.
> >> Please look into detail of discussion in
> >> http://lkml.kernel.org/r/%3C1505183833-4739-4-git-send-email-minchan@kernel.org%3E
> >
> > hm, tricky problem.  I do agree that linking the physical and virtual
> > readahead schemes in the proposed fashion is unfortunate.  I also agree
> > that breaking existing setups (a bit) is also unfortunate.
> >
> > Would it help if, when page-cluster is written to zero, we do
> >
> > printk_once("physical readahead disabled, virtual readahead still
> > enabled.  Disable virtual readhead via
> > /sys/kernel/mm/swap/vma_ra_max_order").
> >
> > Or something like that.  It's pretty lame, but it should help alert the
> > zram-readahead-disabling people to the issue?
> 
> This sounds good for me.
> 
> Hi, Minchan, what do you think about this?  I think for low-end android
> device, the end-user may have no opportunity to upgrade to the latest
> kernel, the device vendor should care about this.  For desktop users,
> the warning proposed by Andrew may help to remind them for the new knob.

Yes, it would be option. At least, we should alert to the user to make
a chance to fix. However, can't we make vma-based readahead new config
option? Please look at the detail in my reply of andrew.

With that, there is no regression with current users and as a bonus,
user can measure both algorithm with their real workload with both
algorithm rather than artificial benchmark. I think recency vs spartial
locality would have each pros and cons so that kind soft landing would
be safer option rather than sudden replacing.
After a while, we can set new algorithm as default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
