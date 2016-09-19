Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id F1CCD6B0253
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 11:59:26 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fu14so247621409pad.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 08:59:26 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x6si29651052pac.8.2016.09.19.08.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 08:59:24 -0700 (PDT)
Message-ID: <1474300762.3916.103.camel@linux.intel.com>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Mon, 19 Sep 2016 08:59:22 -0700
In-Reply-To: <20160919071153.GB4083@bbox>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	 <20160909054336.GA2114@bbox> <87sht824n3.fsf@yhuang-mobile.sh.intel.com>
	 <20160913061349.GA4445@bbox> <87y42wgv5r.fsf@yhuang-dev.intel.com>
	 <20160913070524.GA4973@bbox> <87vay0ji3m.fsf@yhuang-mobile.sh.intel.com>
	 <20160913091652.GB7132@bbox>
	 <045D8A5597B93E4EBEDDCBF1FC15F50935BF9343@fmsmsx104.amr.corp.intel.com>
	 <20160919071153.GB4083@bbox>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, "Chen, Tim C" <tim.c.chen@intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Lu, Aaron" <aaron.lu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Mon, 2016-09-19 at 16:11 +0900, Minchan Kim wrote:
> Hi Tim,
> 
> On Tue, Sep 13, 2016 at 11:52:27PM +0000, Chen, Tim C wrote:
> > 
> > > 
> > > > 
> > > > 
> > > > - Avoid CPU time for splitting, collapsing THP across swap out/in.
> > > Yes, if you want, please give us how bad it is.
> > > 
> > It could be pretty bad.A A In an experiment with THP turned on and we
> > enter swap, 50% of the cpu are spent in the page compaction path.A A 
> It's page compaction overhead, especially, pageblock_pfn_to_page.
> Why is it related to overhead THP split for swapout?
> I don't understand.

Today you have to split a large page into 4K pages to swap it out.
Then after you swap in all the 4K pages, you have to re-compact
them back into a large page.

If you can swap the large page out as a contiguous unit, and swap
it back in as a single large page, the splitting and re-compaction
back into a large page can be avoided.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
