Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB606B006E
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 23:02:33 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id ge10so3941822lab.38
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 20:02:32 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k10si28756621lbp.126.2014.10.16.20.02.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 20:02:31 -0700 (PDT)
Date: Thu, 16 Oct 2014 23:02:21 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 4/5] mm: memcontrol: continue cache reclaim from offlined
 groups
Message-ID: <20141017030221.GA8506@phnom.home.cmpxchg.org>
References: <1413303637-23862-1-git-send-email-hannes@cmpxchg.org>
 <1413303637-23862-5-git-send-email-hannes@cmpxchg.org>
 <20141015152555.GI23547@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141015152555.GI23547@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 15, 2014 at 05:25:55PM +0200, Michal Hocko wrote:
> On Tue 14-10-14 12:20:36, Johannes Weiner wrote:
> > On cgroup deletion, outstanding page cache charges are moved to the
> > parent group so that they're not lost and can be reclaimed during
> > pressure on/inside said parent.  But this reparenting is fairly tricky
> > and its synchroneous nature has led to several lock-ups in the past.
> > 
> > Since css iterators now also include offlined css, memcg iterators can
> > be changed to include offlined children during reclaim of a group, and
> > leftover cache can just stay put.
> 
> I think it would be nice to mention c2931b70a32c (cgroup: iterate
> cgroup_subsys_states directly) here to have a full context about the
> tryget vs tryget_online.

Yes, that commit is probably the most direct dependency.

Andrew, could you update the changelog in place to have that paragraph
read

Since c2931b70a32c ("cgroup: iterate cgroup_subsys_states directly")
css iterators now also include offlined css, so memcg iterators can be
changed to include offlined children during reclaim of a group, and
leftover cache can just stay put.

please?  Thanks!

> > There is a slight change of behavior in that charges of deleted groups
> > no longer show up as local charges in the parent.  But they are still
> > included in the parent's hierarchical statistics.
> 
> Thank you for pulling drain_stock cleanup out. This made the patch so
> much easier to review.
>  
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
