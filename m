Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E17D36B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 03:01:03 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so1836298wms.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 00:01:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q6si2173633wrb.276.2017.01.12.00.01.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 00:01:02 -0800 (PST)
Date: Thu, 12 Jan 2017 09:01:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, thp: add new defer+madvise defrag option
Message-ID: <20170112080059.GA2264@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
 <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
 <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
 <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
 <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz>
 <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com>
 <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz>
 <alpine.DEB.2.10.1701091818340.61862@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1701101614330.41805@chino.kir.corp.google.com>
 <2099d74d-fa2c-e67e-b528-66598d072329@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2099d74d-fa2c-e67e-b528-66598d072329@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux API <linux-api@vger.kernel.org>

On Wed 11-01-17 08:35:27, Vlastimil Babka wrote:
> [+CC linux-api]
> 
> On 01/11/2017 01:15 AM, David Rientjes wrote:
> > There is no thp defrag option that currently allows MADV_HUGEPAGE regions 
> > to do direct compaction and reclaim while all other thp allocations simply 
> > trigger kswapd and kcompactd in the background and fail immediately.
> > 
> > The "defer" setting simply triggers background reclaim and compaction for 
> > all regions, regardless of MADV_HUGEPAGE, which makes it unusable for our 
> > userspace where MADV_HUGEPAGE is being used to indicate the application is 
> > willing to wait for work for thp memory to be available.
> > 
> > The "madvise" setting will do direct compaction and reclaim for these
> > MADV_HUGEPAGE regions, but does not trigger kswapd and kcompactd in the 
> > background for anybody else.
> > 
> > For reasonable usage, there needs to be a mesh between the two options.  
> > This patch introduces a fifth mode, "defer+madvise", that will do direct 
> > reclaim and compaction for MADV_HUGEPAGE regions and trigger background 
> > reclaim and compaction for everybody else so that hugepages may be 
> > available in the near future.
> > 
> > A proposal to allow direct reclaim and compaction for MADV_HUGEPAGE 
> > regions as part of the "defer" mode, making it a very powerful setting and 
> > avoids breaking userspace, was offered: 
> > http://marc.info/?t=148236612700003.  This additional mode is a 
> > compromise.
> > 
> > A second proposal to allow both "defer" and "madvise" to be selected at
> > the same time was also offered: http://marc.info/?t=148357345300001.
> > This is possible, but there was a concern that it might break existing
> > userspaces the parse the output of the defrag mode, so the fifth option
> > was introduced instead.
> > 
> > This patch also cleans up the helper function for storing to "enabled" 
> > and "defrag" since the former supports three modes while the latter 
> > supports five and triple_flag_store() was getting unnecessarily messy.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> alloc_hugepage_direct_gfpmask() would have been IMHO simpler if a new
> internal flag wasn't added, and combination of two existing for defer
> and madvise used,

I agree with Vlastimil here. The patch can do without touching anything
outside of the sysfs handling.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
