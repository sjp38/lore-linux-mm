Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id ECC7B6B0254
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 11:08:59 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so224902425wib.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:08:59 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id cu9si27512164wib.124.2015.07.29.08.08.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 08:08:58 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so30680336wib.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:08:57 -0700 (PDT)
Date: Wed, 29 Jul 2015 17:08:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150729150855.GM15801@dhcp22.suse.cz>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <20150729123629.GI15801@dhcp22.suse.cz>
 <20150729135907.GT8100@esperanza>
 <CANN689HJX2ZL891uOd8TW9ct4PNH9d5odQZm86WMxkpkCWhA-w@mail.gmail.com>
 <20150729144539.GU8100@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150729144539.GU8100@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 29-07-15 17:45:39, Vladimir Davydov wrote:
> On Wed, Jul 29, 2015 at 07:12:13AM -0700, Michel Lespinasse wrote:
> > On Wed, Jul 29, 2015 at 6:59 AM, Vladimir Davydov <vdavydov@parallels.com>
> > wrote:
> > >> I guess the primary reason to rely on the pfn rather than the LRU walk,
> > >> which would be more targeted (especially for memcg cases), is that we
> > >> cannot hold lru lock for the whole LRU walk and we cannot continue
> > >> walking after the lock is dropped. Maybe we can try to address that
> > >> instead? I do not think this is easy to achieve but have you considered
> > >> that as an option?
> > >
> > > Yes, I have, and I've come to a conclusion it's not doable, because LRU
> > > lists can be constantly rotating at an arbitrary rate. If you have an
> > > idea in mind how this could be done, please share.
> > >
> > > Speaking of LRU-vs-PFN walk, iterating over PFNs has its own advantages:
> > >  - You can distribute a walk in time to avoid CPU bursts.
> > >  - You are free to parallelize the scanner as you wish to decrease the
> > >    scan time.
> > 
> > There is a third way: one could go through every MM in the system and scan
> > their page tables. Doing things that way turns out to be generally faster
> > than scanning by physical address, because you don't have to go through
> > RMAP for every page. But, you end up needing to take the mmap_sem lock of
> > every MM (in turn) while scanning them, and that degrades quickly under
> > memory load, which is exactly when you most need this feature. So, scan by
> > address is still what we use here.
> 
> Page table scan approach has the inherent problem - it ignores unmapped
> page cache. If a workload does a lot of read/write or map-access-unmap
> operations, we won't be able to even roughly estimate its wss.

That page cache is trivially reclaimable if it is clean. If it needs
writeback then it is non-idle only until the next writeback. So why does
it matter for the estimation?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
