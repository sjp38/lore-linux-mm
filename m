Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4DABA6B0008
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:35:21 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d18-v6so131401edp.0
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:35:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r23-v6si7428385edi.91.2018.07.23.01.35.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 01:35:20 -0700 (PDT)
Date: Mon, 23 Jul 2018 10:35:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/5] mm/page_alloc: Optimize free_area_init_core
Message-ID: <20180723083519.GG17905@dhcp22.suse.cz>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-4-osalvador@techadventures.net>
 <20180719134417.GC7193@dhcp22.suse.cz>
 <20180719140327.GB10988@techadventures.net>
 <20180719151555.GH7193@dhcp22.suse.cz>
 <20180719205235.GA14010@techadventures.net>
 <20180720100327.GA19478@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180720100327.GA19478@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Fri 20-07-18 12:03:27, Oscar Salvador wrote:
> On Thu, Jul 19, 2018 at 10:52:35PM +0200, Oscar Salvador wrote:
> > On Thu, Jul 19, 2018 at 05:15:55PM +0200, Michal Hocko wrote:
> > > Your changelog doesn't really explain the motivation. Does the change
> > > help performance? Is this a pure cleanup?
> > 
> > Hi Michal,
> > 
> > Sorry to not have explained this better from the very beginning.
> > 
> > It should help a bit in performance terms as we would be skipping those
> > condition checks and assignations for zones that do not have any pages.
> > It is not a huge win, but I think that skipping code we do not really need to run
> > is worh to have.
> > 
> > > The function is certainly not an example of beauty. It is more an
> > > example of changes done on top of older ones without much thinking. But
> > > I do not see your change would make it so much better. I would consider
> > > it a much nicer cleanup if it was split into logical units each doing
> > > one specific thing.
> > 
> > About the cleanup, I thought that moving that block of code to a separate function
> > would make the code easier to follow.
> > If you think that this is still not enough, I can try to split it and see the outcome.
> 
> I tried to split it innto three logical blocks:
> 
> - Substract memmap pages
> - Substract dma reserves
> - Account kernel pages (nr_kernel_pages and nr_total_pages)

No, I do not think this is much better. Why do we need to separate those
functions out? I think you are too focused on the current function
without a broader context. Think about it. We have two code paths.
Early initialization and the hotplug. The two are subtly different in
some aspects. Maybe reusing free_area_init_core is the wrong thing and
we should have a dedicated subset of this function. This would make the
code more clear probably. You wouldn't have to think which part of
free_area_init_core is special and what has to be done if this function
was to be used in a different context. See my point?
-- 
Michal Hocko
SUSE Labs
