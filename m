Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 25E736B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 11:36:50 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w62so1347863wes.29
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 08:36:48 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id tc2si5738835wic.0.2014.07.23.08.36.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 08:36:47 -0700 (PDT)
Date: Wed, 23 Jul 2014 11:36:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140723153638.GG1725@cmpxchg.org>
References: <20140715121935.GB9366@dhcp22.suse.cz>
 <20140718071246.GA21565@dhcp22.suse.cz>
 <20140718144554.GG29639@cmpxchg.org>
 <CAJfpegt9k+YULet3vhmG3br7zSiHy-DRL+MiEE=HRzcs+mLzbw@mail.gmail.com>
 <20140719173911.GA1725@cmpxchg.org>
 <20140722150825.GA4517@dhcp22.suse.cz>
 <CAJfpegscT-ptQzq__uUV2TOn7Uvs6x4FdWGTQb9Fe9MEJr2KjA@mail.gmail.com>
 <20140723143847.GB16721@dhcp22.suse.cz>
 <20140723150608.GF1725@cmpxchg.org>
 <20140723151909.GC16721@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140723151909.GC16721@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jul 23, 2014 at 05:19:09PM +0200, Michal Hocko wrote:
> On Wed 23-07-14 11:06:08, Johannes Weiner wrote:
> > On Wed, Jul 23, 2014 at 04:38:47PM +0200, Michal Hocko wrote:
> [...]
> > > OK, thanks for the clarification. I had this feeling but couldn't wrap
> > > my head around the indirection of the code.
> > > 
> > > It seems that checkig PageCgroupUsed(new) and bail out early in
> > > mem_cgroup_migrate should just work, no?
> > 
> > If the new page is already charged as page cache, we could just drop
> > the call to mem_cgroup_migrate() altogether.
> 
> Yeah, it is just that we do not want to do all the
> page->page_cgroup->PageCgroupUsed thing in replace_page_cache_page.

If the new page is *always* already charged as cache, there is no
reason to even check PageCgroupUsed.  We wouldn't have to do anything
at this point.  The old code had to, because pages were uncharged
during truncation, but now we could just carry the original charge
across truncation and the re-use as replacement page, and then
uncharge the old page.  No migration necessary.

That's why I'm asking if newpage is always charged truncated page
cache, or whether it can be something else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
