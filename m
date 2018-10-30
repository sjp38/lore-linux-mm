Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4296B04CD
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 04:16:43 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bb3-v6so8612625plb.20
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 01:16:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k3-v6si14614936pgm.517.2018.10.30.01.16.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 01:16:42 -0700 (PDT)
Date: Tue, 30 Oct 2018 09:16:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/2] mm: soft-offline: fix race against page allocation
Message-ID: <20181030081639.GW32673@dhcp22.suse.cz>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180815154334.f3eecd1029a153421631413a@linux-foundation.org>
 <20180822013748.GA10343@hori1.linux.bs1.fc.nec.co.jp>
 <20180822080025.GD29735@dhcp22.suse.cz>
 <20181026084636.GY18839@dhcp22.suse.cz>
 <20181030065433.GA1119@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181030065433.GA1119@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Tue 30-10-18 06:54:33, Naoya Horiguchi wrote:
> On Fri, Oct 26, 2018 at 10:46:36AM +0200, Michal Hocko wrote:
> > On Wed 22-08-18 10:00:25, Michal Hocko wrote:
> > > On Wed 22-08-18 01:37:48, Naoya Horiguchi wrote:
> > > > On Wed, Aug 15, 2018 at 03:43:34PM -0700, Andrew Morton wrote:
> > > > > On Tue, 17 Jul 2018 14:32:30 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > > > > 
> > > > > > I've updated the patchset based on feedbacks:
> > > > > > 
> > > > > > - updated comments (from Andrew),
> > > > > > - moved calling set_hwpoison_free_buddy_page() from mm/migrate.c to mm/memory-failure.c,
> > > > > >   which is necessary to check the return code of set_hwpoison_free_buddy_page(),
> > > > > > - lkp bot reported a build error when only 1/2 is applied.
> > > > > > 
> > > > > >   >    mm/memory-failure.c: In function 'soft_offline_huge_page':
> > > > > >   > >> mm/memory-failure.c:1610:8: error: implicit declaration of function
> > > > > >   > 'set_hwpoison_free_buddy_page'; did you mean 'is_free_buddy_page'?
> > > > > >   > [-Werror=implicit-function-declaration]
> > > > > >   >        if (set_hwpoison_free_buddy_page(page))
> > > > > >   >            ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > > > > >   >            is_free_buddy_page
> > > > > >   >    cc1: some warnings being treated as errors
> > > > > > 
> > > > > >   set_hwpoison_free_buddy_page() is defined in 2/2, so we can't use it
> > > > > >   in 1/2. Simply doing s/set_hwpoison_free_buddy_page/!TestSetPageHWPoison/
> > > > > >   will fix this.
> > > > > > 
> > > > > > v1: https://lkml.org/lkml/2018/7/12/968
> > > > > > 
> > > > > 
> > > > > Quite a bit of discussion on these two, but no actual acks or
> > > > > review-by's?
> > > > 
> > > > Really sorry for late response.
> > > > Xishi provided feedback on previous version, but no final ack/reviewed-by.
> > > > This fix should work on the reported issue, but rewriting soft-offlining
> > > > without PageHWPoison flag would be the better fix (no actual patch yet.)
> > > 
> > > If we can go with the later the I would obviously prefer that. I cannot
> > > promise to work on the patch though. I can help with reviewing of
> > > course.
> > > 
> > > If this is important enough that people are hitting the issue in normal
> > > workloads then sure, let's go with the simple fix and continue on top of
> > > that.
> > 
> > Naoya, did you have any chance to look at this or have any plans to look?
> > I am willing to review and help with the overal design but I cannot
> > really promise to work on the code.
> 
> I have a draft version of a patch to isolate a page in buddy-friendly manner
> without PageHWPoison flag (that was written weeks ago, but I couldn't finish
> because my other project interrupted me ...).
> I'll post it after testing, especially confirming that hotplug code properly
> reset the isolated page.

Thanks a lot Naoya. It is highly appreciated!
-- 
Michal Hocko
SUSE Labs
