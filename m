Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7731D6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 03:49:22 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p96so2489729wrb.12
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 00:49:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3si2523970edm.63.2017.11.02.00.49.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 00:49:21 -0700 (PDT)
Date: Thu, 2 Nov 2017 08:49:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?562U5aSNOiBbUEFUQ0g=?= =?utf-8?Q?=5D?= mm: extend
 reuse_swap_page range as much as possible
Message-ID: <20171102074917.y4uvfrzshtr7jahi@dhcp22.suse.cz>
References: <1509533474-98584-1-git-send-email-zhouxianrong@huawei.com>
 <87tvyd4fsx.fsf@yhuang-dev.intel.com>
 <AE94847B1D9E864B8593BD8051012AF36E13E3BE@DGGEMA505-MBS.china.huawei.com>
 <20171102042223.GA26523@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171102042223.GA26523@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: zhouxianrong <zhouxianrong@huawei.com>, "Huang, Ying" <ying.huang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>, "rientjes@google.com" <rientjes@google.com>, "mingo@kernel.org" <mingo@kernel.org>, "vegard.nossum@oracle.com" <vegard.nossum@oracle.com>, "aaron.lu@intel.com" <aaron.lu@intel.com>, Zhouxiyu <zhouxiyu@huawei.com>, "Duwei (Device OS)" <weidu.du@huawei.com>, fanghua <fanghua3@huawei.com>, hutj <hutj@huawei.com>, Won Ho Park <won.ho.park@huawei.com>

On Thu 02-11-17 13:22:23, Minchan Kim wrote:
> On Thu, Nov 02, 2017 at 02:09:57AM +0000, zhouxianrong wrote:
> > <zhouxianrong@huawei.com> writes:
> > 
> > > From: zhouxianrong <zhouxianrong@huawei.com>
> > >
> > > origanlly reuse_swap_page requires that the sum of page's mapcount and 
> > > swapcount less than or equal to one.
> > > in this case we can reuse this page and avoid COW currently.
> > >
> > > now reuse_swap_page requires only that page's mapcount less than or 
> > > equal to one and the page is not dirty in swap cache. in this case we 
> > > do not care its swap count.
> > >
> > > the page without dirty in swap cache means that it has been written to 
> > > swap device successfully for reclaim before and then read again on a 
> > > swap fault. in this case the page can be reused even though its swap 
> > > count is greater than one and postpone the COW on other successive 
> > > accesses to the swap cache page later rather than now.
> > >
> > > i did this patch test in kernel 4.4.23 with arm64 and none huge 
> > > memory. it work fine.

this is not an appropriate justification

> > Why do you need this?  You saved copying one page from memory to memory
> > (COW) now, at the cost of reading a page from disk to memory later?
> > 
> > yes, accessing later does not always happen, there is probability for it, so postpone COW now.
> 
> So, it's trade-off. It means we need some number with some scenarios
> to prove it's better than as-is.
> It would help to drive reviewers/maintainer.

Absolutely agreed. We definitely need some numbers for different set of
workloads.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
