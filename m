Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id AACE66B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 09:54:56 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id z2so9490347wiv.5
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 06:54:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hf2si2841656wjc.63.2014.09.25.06.54.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Sep 2014 06:54:55 -0700 (PDT)
Date: Thu, 25 Sep 2014 09:54:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v2] mm: memcontrol: do not iterate uninitialized memcgs
Message-ID: <20140925135450.GA1822@cmpxchg.org>
References: <1411612278-4707-1-git-send-email-hannes@cmpxchg.org>
 <20140925024054.GA4888@cmpxchg.org>
 <20140925114339.GD12090@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140925114339.GD12090@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 25, 2014 at 01:43:39PM +0200, Michal Hocko wrote:
> On Wed 24-09-14 22:40:55, Johannes Weiner wrote:
> > Argh, buggy css_put() against the root.  Hand grenades, everywhere.
> > Update:
> > 
> > ---
> > From 9b0b4d72d71cd8acd7aaa58d2006c751decc8739 Mon Sep 17 00:00:00 2001
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Date: Wed, 24 Sep 2014 22:00:20 -0400
> > Subject: [patch] mm: memcontrol: do not iterate uninitialized memcgs
> > 
> > The cgroup iterators yield css objects that have not yet gone through
> > css_online(), but they are not complete memcgs at this point and so
> > the memcg iterators should not return them.  d8ad30559715 ("mm/memcg:
> > iteration skip memcgs not yet fully initialized") set out to implement
> > exactly this, but it uses CSS_ONLINE, a cgroup-internal flag that does
> > not meet the ordering requirements for memcg, and so we still may see
> > partially initialized memcgs from the iterators.
> 
> I do not see how would this happen. CSS_ONLINE is set after css_online
> callback returns and mem_cgroup_css_online ends the core initialization
> with mutex_unlock which should provide sufficient memory ordering
> requirements

But the iterators do not use the mutex?  We are missing the matching
acquire for the proper ordering.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
