Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A2F146B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 08:24:47 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u63so853295wmu.0
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 05:24:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q18si1759582wra.35.2017.02.22.05.24.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 05:24:46 -0800 (PST)
Date: Wed, 22 Feb 2017 14:24:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: provide shmem statistics
Message-ID: <20170222132444.GK5753@dhcp22.suse.cz>
References: <20170221164343.32252-1-hannes@cmpxchg.org>
 <20170222081230.GC5753@dhcp22.suse.cz>
 <20170222124501.GA9184@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170222124501.GA9184@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Chris Down <cdown@fb.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed 22-02-17 07:45:01, Johannes Weiner wrote:
> On Wed, Feb 22, 2017 at 09:12:31AM +0100, Michal Hocko wrote:
> > On Tue 21-02-17 11:43:43, Johannes Weiner wrote:
> > > Cgroups currently don't report how much shmem they use, which can be
> > > useful data to have, in particular since shmem is included in the
> > > cache/file item while being reclaimed like anonymous memory.
> > > 
> > > Add a counter to track shmem pages during charging and uncharging.
> > 
> > Yes this is indeed useful. Accounting shmem to the page cache was a
> > mistake because this is more than confusing. Sad we cannot fix that.
> 
> Agreed, this continues to cause confusion with many Linux users :(
> 
> > I would have just one concern with this patch. You are relying on
> > PageSwapBacked check but it looks like we are going to implement
> > MADV_FREE by dropping this flag. I know we do not support MADV_FREE
> > on shared mappings but if we ever do then the accounting will become
> > subtly broken. Can/Should we rely on shmem_mapping() check instead?
> 
> Yes, right now we do MADV_FREE only on private pages, so this patch is
> safe with Shaohua's changes to how we use PG_swapbacked.
> 
> Should we support MADV_FREE on shared mappings in the future, using
> shmem_mapping() for memcg accounting won't work unfortunately, because
> shared pages are truncated from the page cache before uncharging, and
> that clears the page->mapping pointer.

You are right!

> However, in that case we could
> probably unaccount the pages from shmem at the time of MADV_FREE, when
> we clear the PG_swapbacked bit.

Or we can just keep the code as is and add a comment to
madvise_free_single_vma to remind that memcg charging would have to be
handled properly if we want to drop vma_is_anonymous check there. It is
really hard to tell whether we ever get a support for MADV_FREE for
shared pages.

> > Other than that the patch looks good to me.
> 
> Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
