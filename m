Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 132096B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:03:45 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p192so35731641wme.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 12:03:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8si29191wrd.173.2017.01.17.12.03.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 12:03:43 -0800 (PST)
Date: Tue, 17 Jan 2017 21:03:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Update][PATCH v5 7/9] mm/swap: Add cache for swap slots
 allocation
Message-ID: <20170117200338.GA26217@dhcp22.suse.cz>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
 <35de301a4eaa8daa2977de6e987f2c154385eb66.1484082593.git.tim.c.chen@linux.intel.com>
 <87tw8ymm2z.fsf_-_@yhuang-dev.intel.com>
 <20170117101631.GG19699@dhcp22.suse.cz>
 <045D8A5597B93E4EBEDDCBF1FC15F50935C9F523@fmsmsx104.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <045D8A5597B93E4EBEDDCBF1FC15F50935C9F523@fmsmsx104.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Chen, Tim C" <tim.c.chen@intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "Lu, Aaron" <aaron.lu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Tue 17-01-17 17:24:15, Chen, Tim C wrote:
> > > +	/*
> > > +	 * Preemption need to be turned on here, because we may sleep
> > > +	 * in refill_swap_slots_cache().  But it is safe, because
> > > +	 * accesses to the per-CPU data structure are protected by a
> > > +	 * mutex.
> > > +	 */
> > 
> > the comment doesn't really explain why it is safe. THere are other users
> > which are not using the lock. E.g. just look at free_swap_slot above.
> > How can
> > 	cache->slots_ret[cache->n_ret++] = entry; be safe wrt.
> > 	pentry = &cache->slots[cache->cur++];
> > 	entry = *pentry;
> > 
> > Both of them might touch the same slot, no? Btw. I would rather prefer this
> > would be a follow up fix with the trace and the detailed explanation.
> > 
> 
> The cache->slots_ret  is protected by cache->free_lock and cache->slots is
> protected by cache->free_lock.

Ohh, I have misread those names and considered them the same thing.
Sorry about the confusion. I will look at code more deeply tomorrow.

> They are two separate structures, one for
> caching the slots returned and one for caching the slots allocated.  So
> they do no touch the same slots.  We'll update the comments so it is clearer.

That would be really appreciated.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
