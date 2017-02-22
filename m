Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1E656B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 07:45:12 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x4so470654wme.3
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 04:45:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y6si2015411wmg.57.2017.02.22.04.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 04:45:11 -0800 (PST)
Date: Wed, 22 Feb 2017 07:45:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: provide shmem statistics
Message-ID: <20170222124501.GA9184@cmpxchg.org>
References: <20170221164343.32252-1-hannes@cmpxchg.org>
 <20170222081230.GC5753@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170222081230.GC5753@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Chris Down <cdown@fb.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Feb 22, 2017 at 09:12:31AM +0100, Michal Hocko wrote:
> On Tue 21-02-17 11:43:43, Johannes Weiner wrote:
> > Cgroups currently don't report how much shmem they use, which can be
> > useful data to have, in particular since shmem is included in the
> > cache/file item while being reclaimed like anonymous memory.
> > 
> > Add a counter to track shmem pages during charging and uncharging.
> 
> Yes this is indeed useful. Accounting shmem to the page cache was a
> mistake because this is more than confusing. Sad we cannot fix that.

Agreed, this continues to cause confusion with many Linux users :(

> I would have just one concern with this patch. You are relying on
> PageSwapBacked check but it looks like we are going to implement
> MADV_FREE by dropping this flag. I know we do not support MADV_FREE
> on shared mappings but if we ever do then the accounting will become
> subtly broken. Can/Should we rely on shmem_mapping() check instead?

Yes, right now we do MADV_FREE only on private pages, so this patch is
safe with Shaohua's changes to how we use PG_swapbacked.

Should we support MADV_FREE on shared mappings in the future, using
shmem_mapping() for memcg accounting won't work unfortunately, because
shared pages are truncated from the page cache before uncharging, and
that clears the page->mapping pointer. However, in that case we could
probably unaccount the pages from shmem at the time of MADV_FREE, when
we clear the PG_swapbacked bit.

> Other than that the patch looks good to me.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
