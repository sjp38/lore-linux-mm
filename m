Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B6ECF6B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 04:57:12 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g6so3638470pgn.11
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 01:57:12 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l12si6667665pgq.59.2017.10.18.01.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 01:57:11 -0700 (PDT)
Date: Wed, 18 Oct 2017 16:57:11 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH] mm/page_alloc: make sure __rmqueue() etc. always inline
Message-ID: <20171018085711.GC1753@intel.com>
References: <20171010025151.GD1798@intel.com>
 <20171010025601.GE1798@intel.com>
 <8d6a98d3-764e-fd41-59dc-88a9d21822c7@intel.com>
 <20171010054342.GF1798@intel.com>
 <20171010144545.c87a28b0f3c4e475305254ab@linux-foundation.org>
 <20171011023402.GC27907@intel.com>
 <20171013063111.GA26032@intel.com>
 <7304b3a4-d6cb-63fa-743d-ea8e7b126e32@suse.cz>
 <1508291629.14336.14.camel@intel.com>
 <29e5343f-b352-fe6a-02a8-74955cd606b8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29e5343f-b352-fe6a-02a8-74955cd606b8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "Wang, Kemi" <kemi.wang@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Huang, Ying" <ying.huang@intel.com>

On Wed, Oct 18, 2017 at 08:28:56AM +0200, Vlastimil Babka wrote:
> On 10/18/2017 03:53 AM, Lu, Aaron wrote:
> > On Tue, 2017-10-17 at 13:32 +0200, Vlastimil Babka wrote:
> >> With gcc 7.2.1:
> >>> ./scripts/bloat-o-meter base.o mm/page_alloc.o
> >>
> >> add/remove: 1/2 grow/shrink: 2/0 up/down: 2493/-1649 (844)
> > 
> > Nice, it clearly showed 844 bytes bloat.
> > 
> >> function                                     old     new   delta
> >> get_page_from_freelist                      2898    4937   +2039
> >> steal_suitable_fallback                        -     365    +365
> >> find_suitable_fallback                        31     120     +89
> >> find_suitable_fallback.part                  115       -    -115
> >> __rmqueue                                   1534       -   -1534
> 
> It also shows that steal_suitable_fallback() is no longer inlined. Which
> is fine, because that should ideally be rarely executed.

Ah right, so this script is really good for analysing inline changes.

> 
> >>
> >>> [aaron@aaronlu obj]$ size */*/vmlinux
> >>>    text    data     bss     dec       hex     filename
> >>> 10342757   5903208 17723392 33969357  20654cd gcc-4.9.4/base/vmlinux
> >>> 10342757   5903208 17723392 33969357  20654cd gcc-4.9.4/head/vmlinux
> >>> 10332448   5836608 17715200 33884256  2050860 gcc-5.5.0/base/vmlinux
> >>> 10332448   5836608 17715200 33884256  2050860 gcc-5.5.0/head/vmlinux
> >>> 10094546   5836696 17715200 33646442  201676a gcc-6.4.0/base/vmlinux
> >>> 10094546   5836696 17715200 33646442  201676a gcc-6.4.0/head/vmlinux
> >>> 10018775   5828732 17715200 33562707  2002053 gcc-7.2.0/base/vmlinux
> >>> 10018775   5828732 17715200 33562707  2002053 gcc-7.2.0/head/vmlinux
> >>>
> >>> Text size for vmlinux has no change though, probably due to function
> >>> alignment.
> >>
> >> Yep that's useless to show. These differences do add up though, until
> >> they eventually cross the alignment boundary.
> > 
> > Agreed.
> > But you know, it is the hot path, the performance improvement might be
> > worth it.
> 
> I'd agree, so you can add
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
