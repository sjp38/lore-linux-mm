Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEC56B04B5
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 09:23:50 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r79so13490285wrb.0
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 06:23:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 67si10291883wrc.395.2017.08.21.06.23.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Aug 2017 06:23:49 -0700 (PDT)
Date: Mon, 21 Aug 2017 15:23:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: kernel panic on null pointer on page->mem_cgroup
Message-ID: <20170821132345.GK25956@dhcp22.suse.cz>
References: <20170808162122.GA14689@cmpxchg.org>
 <20170808165601.GA7693@jaegeuk-macbookpro.roam.corp.google.com>
 <20170808173704.GA22887@cmpxchg.org>
 <CADvgSZSn1v-tTpa07ebqr19heQbkzbavdPM_nbRNR1WF-EBnFw@mail.gmail.com>
 <20170808200849.GA1104@cmpxchg.org>
 <20170809014459.GB7693@jaegeuk-macbookpro.roam.corp.google.com>
 <CADvgSZSNn7N3R7+jjeCgns2ZEPtYc6c3MWmkkQ3PA+0LHO_MfA@mail.gmail.com>
 <20170809183825.GA26387@cmpxchg.org>
 <20170810115605.GQ23863@dhcp22.suse.cz>
 <20170821130218.GA1371@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170821130218.GA1371@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Brad Bolen <bradleybolen@gmail.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 21-08-17 09:02:18, Johannes Weiner wrote:
> On Thu, Aug 10, 2017 at 01:56:05PM +0200, Michal Hocko wrote:
> > On Wed 09-08-17 14:38:25, Johannes Weiner wrote:
> > > The issue is that writeback doesn't hold a page reference and the page
> > > might get freed after PG_writeback is cleared (and the mapping is
> > > unlocked) in test_clear_page_writeback(). The stat functions looking
> > > up the page's node or zone are safe, as those attributes are static
> > > across allocation and free cycles. But page->mem_cgroup is not, and it
> > > will get cleared if we race with truncation or migration.
> > 
> > Is there anything that prevents us from holding a reference on a page
> > under writeback?
> 
> Hm, I'm hesitant to add redundant life-time management to the page
> there just for memcg, which is not always configured in.
> 
> Pinning the memcg instead is slightly more complex, but IMO has the
> complexity in a preferrable place.

If that is the single place that needs such a special handling and it is
very likely to stay that way then the additional complexity is probably
justified. I am just worried that this is really subtle and history
tells us that such a code usually kicks us back later.
 
> Would you agree?

Well, I was not objecting to the patch. It seems correct I am just
worried a robust fix would be preferable. And a clear object life time
sounds like a more robust thing to do.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
