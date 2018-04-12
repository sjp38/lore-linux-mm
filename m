Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id F10726B0007
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 03:47:57 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 91-v6so3215395plf.6
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 00:47:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g6-v6si2961133pln.619.2018.04.12.00.47.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Apr 2018 00:47:56 -0700 (PDT)
Date: Thu, 12 Apr 2018 09:47:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 0/2] mm: migrate: vm event counter for hugepage
 migration
Message-ID: <20180412074754.GS23400@dhcp22.suse.cz>
References: <1523434167-19995-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180412061859.GR23400@dhcp22.suse.cz>
 <20180412074039.GA3340@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180412074039.GA3340@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Zi Yan <zi.yan@sent.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu 12-04-18 07:40:41, Naoya Horiguchi wrote:
> On Thu, Apr 12, 2018 at 08:18:59AM +0200, Michal Hocko wrote:
> > On Wed 11-04-18 17:09:25, Naoya Horiguchi wrote:
> > > Hi everyone,
> > > 
> > > I wrote patches introducing separate vm event counters for hugepage migration
> > > (both for hugetlb and thp.)
> > > Hugepage migration is different from normal page migration in event frequency
> > > and/or how likely it succeeds, so maintaining statistics for them in mixed
> > > counters might not be helpful both for develors and users.
> > 
> > This is quite a lot of code to be added se we should better document
> > what it is intended for. Sure I understand your reasonaning about huge
> > pages are more likely to fail but is this really worth a separate
> > counter? Do you have an example of how this would be useful?
> 
> Our customers periodically collect some log info to understand what
> happened after system failures happen.  Then if we have separate counters
> for hugepage migration and the values show some anomaly, that might
> help admins and developers understand the issue more quickly.
> We have other ways to get this info like checking /proc/pid/pagemap and
> /proc/kpageflags, but they are costly and most users decide not to
> collect them in periodical logging.

Wouldn't tracepoints be more suitable for that purpose? They can collect
more valuable information.

> > If we are there then what about different huge page sizes (for hugetlb)?
> > Do we need per-hstate stats?
> 
> Yes, per-hstate counters are better. And existing hugetlb counters
> htlb_buddy_alloc_* are also affected by this point.

The thing is that this would bloat the code and the vmstat output even more.
I am not really convinced this is a great idea for something that
tracepoints would handle as well.
-- 
Michal Hocko
SUSE Labs
