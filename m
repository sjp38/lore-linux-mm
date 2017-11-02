Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 51E7C6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 00:22:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u23so4663928pgo.4
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 21:22:28 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id b75si2705678pfk.343.2017.11.01.21.22.26
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 21:22:26 -0700 (PDT)
Date: Thu, 2 Nov 2017 13:22:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: =?utf-8?B?562U5aSNOiBbUEFUQ0g=?= =?utf-8?Q?=5D?= mm: extend
 reuse_swap_page range as much as possible
Message-ID: <20171102042223.GA26523@bbox>
References: <1509533474-98584-1-git-send-email-zhouxianrong@huawei.com>
 <87tvyd4fsx.fsf@yhuang-dev.intel.com>
 <AE94847B1D9E864B8593BD8051012AF36E13E3BE@DGGEMA505-MBS.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AE94847B1D9E864B8593BD8051012AF36E13E3BE@DGGEMA505-MBS.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "rientjes@google.com" <rientjes@google.com>, "mingo@kernel.org" <mingo@kernel.org>, "vegard.nossum@oracle.com" <vegard.nossum@oracle.com>, "aaron.lu@intel.com" <aaron.lu@intel.com>, Zhouxiyu <zhouxiyu@huawei.com>, "Duwei (Device OS)" <weidu.du@huawei.com>, fanghua <fanghua3@huawei.com>, hutj <hutj@huawei.com>, Won Ho Park <won.ho.park@huawei.com>

On Thu, Nov 02, 2017 at 02:09:57AM +0000, zhouxianrong wrote:
> <zhouxianrong@huawei.com> writes:
> 
> > From: zhouxianrong <zhouxianrong@huawei.com>
> >
> > origanlly reuse_swap_page requires that the sum of page's mapcount and 
> > swapcount less than or equal to one.
> > in this case we can reuse this page and avoid COW currently.
> >
> > now reuse_swap_page requires only that page's mapcount less than or 
> > equal to one and the page is not dirty in swap cache. in this case we 
> > do not care its swap count.
> >
> > the page without dirty in swap cache means that it has been written to 
> > swap device successfully for reclaim before and then read again on a 
> > swap fault. in this case the page can be reused even though its swap 
> > count is greater than one and postpone the COW on other successive 
> > accesses to the swap cache page later rather than now.
> >
> > i did this patch test in kernel 4.4.23 with arm64 and none huge 
> > memory. it work fine.
> 
> Why do you need this?  You saved copying one page from memory to memory
> (COW) now, at the cost of reading a page from disk to memory later?
> 
> yes, accessing later does not always happen, there is probability for it, so postpone COW now.

So, it's trade-off. It means we need some number with some scenarios
to prove it's better than as-is.
It would help to drive reviewers/maintainer.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
