Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id ECA556B0033
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:41:29 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d8so27619645pgt.1
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 06:41:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor4531124pgp.231.2017.09.27.06.41.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Sep 2017 06:41:28 -0700 (PDT)
Date: Wed, 27 Sep 2017 22:41:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
Message-ID: <20170927134117.GB338@bgram>
References: <20170921013310.31348-1-ying.huang@intel.com>
 <20170926132129.dbtr2mof35x4j4og@dhcp22.suse.cz>
 <20170927050401.GA715@bbox>
 <20170927074835.37m4dclmew5ecli2@dhcp22.suse.cz>
 <20170927080432.GA1160@bbox>
 <20170927083512.dydqlqezh5polggb@dhcp22.suse.cz>
 <20170927131511.GA338@bgram>
 <20170927132241.tshup6kcwe5pcxek@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927132241.tshup6kcwe5pcxek@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Wed, Sep 27, 2017 at 03:22:41PM +0200, Michal Hocko wrote:
> On Wed 27-09-17 22:15:11, Minchan Kim wrote:
> > On Wed, Sep 27, 2017 at 10:35:12AM +0200, Michal Hocko wrote:
> > > On Wed 27-09-17 17:04:32, Minchan Kim wrote:
> > > > On Wed, Sep 27, 2017 at 09:48:35AM +0200, Michal Hocko wrote:
> > > > > On Wed 27-09-17 14:04:01, Minchan Kim wrote:
> > > [...]
> > > > > > The problem is users have disabled swap readahead by echo 0 > /proc/sys/
> > > > > > vm/page-cluster are regressed by this new interface /sys/kernel/mm/swap/
> > > > > > vma_ra_max_order. Because for disabling readahead completely, they should
> > > > > > disable vma_ra_max_order as well as page-cluster from now on.
> > > > > > 
> > > > > > So, goal of new config to notice new feature to admins so they can be aware
> > > > > > of new konb vma_ra_max_order as well as page-cluster.
> > > > > > I canont think other better idea to preventing such regression.
> > > > > > 
> > > > > > http://lkml.kernel.org/r/%3C20170913014019.GB29422@bbox%3E
> > > > > 
> > > > > So, how are you going to configure this when you do not know whether
> > > > > zram will be used? In other words what should e.g. distribution set this
> > > > > to?
> > > > 
> > > > I have no idea. Unfortunately, it depends on them. If they want to use
> > > > zram as swap, they should fix the script. Surely, I don't like it.
> > > > Instead, I wanted that page-cluster zeroing disables both virtual/pysical
> > > > swap readahead not to break current userspace. However, Huang doesn't
> > > > liek it.
> > > > If you have better idea, please suggest.
> > > 
> > > I understand your frustration but config options are not there to bypass
> > > proper design decisions. Why cannot we unconditionally disable all the
> > > read ahead when zram is enabled?
> > 
> > It's not a zram specific issue. Every users who have disabled swap readahead
> > via page-cluster will be broken, too.
> 
> Do you have any examples outside of zram? Also I do not see why we

I'm not a god to know every usecases on earth. It's just knob and
it's have been there for a long time with following semantic:

        Zero disables swap readahead completely.

So, anyuser can use it by their reasons(e.g., small memory system)

I don't want to play with pointless game "Hey, give me an example.
If you couldn't, no worth to keep the semantic" on such long time
simple/clear semantic.


> simply cannot disable swap readahead when page-cluster is 0?

That's was what I want really but Huang want to use two readahead
algorithms in parallel so he wanted to keep two separated disable
knobs.


> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
