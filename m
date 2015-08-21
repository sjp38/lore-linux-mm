Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8B79A6B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 03:25:55 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so8481113wic.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 00:25:55 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id sa6si13338914wjb.10.2015.08.21.00.25.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 00:25:54 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so11867097wic.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 00:25:53 -0700 (PDT)
Date: Fri, 21 Aug 2015 09:25:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150821072552.GF23723@dhcp22.suse.cz>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-4-git-send-email-emunson@akamai.com>
 <20150812115909.GA5182@dhcp22.suse.cz>
 <20150819213345.GB4536@akamai.com>
 <20150820075611.GD4780@dhcp22.suse.cz>
 <20150820170309.GA11557@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150820170309.GA11557@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Thu 20-08-15 13:03:09, Eric B Munson wrote:
> On Thu, 20 Aug 2015, Michal Hocko wrote:
> 
> > On Wed 19-08-15 17:33:45, Eric B Munson wrote:
> > [...]
> > > The group which asked for this feature here
> > > wants the ability to distinguish between LOCKED and LOCKONFAULT regions
> > > and without the VMA flag there isn't a way to do that.
> > 
> > Could you be more specific on why this is needed?
> 
> They want to keep metrics on the amount of memory used in a LOCKONFAULT
> region versus the address space of the region.

/proc/<pid>/smaps already exports that information AFAICS. It exports
VMA flags including VM_LOCKED and if rss < size then this is clearly
LOCKONFAULT because the standard mlock semantic is to populate. Would
that be sufficient?

Now, it is true that LOCKONFAULT wouldn't be distinguishable from
MAP_LOCKED which failed to populate but does that really matter? It is
LOCKONFAULT in a way as well.

> > > Do we know that these last two open flags are needed right now or is
> > > this speculation that they will be and that none of the other VMA flags
> > > can be reclaimed?
> > 
> > I do not think they are needed by anybody right now but that is not a
> > reason why it should be used without a really strong justification.
> > If the discoverability is really needed then fair enough but I haven't
> > seen any justification for that yet.
> 
> To be completely clear you believe that if the metrics collection is
> not a strong enough justification, it is better to expand the mm_struct
> by another unsigned long than to use one of these bits right?

A simple bool is sufficient for that. And yes I think we should go with
per mm_struct flag rather than the additional vma flag if it has only
the global (whole address space) scope - which would be the case if the
LOCKONFAULT is always an mlock modifier and the persistance is needed
only for MCL_FUTURE. Which is imho a sane semantic.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
