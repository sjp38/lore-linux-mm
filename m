Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id F33F16B006C
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 13:53:45 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so1297101lbi.9
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:53:45 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lm8si3795045lac.7.2014.10.23.10.53.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 10:53:44 -0700 (PDT)
Date: Thu, 23 Oct 2014 13:53:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: fold
 mem_cgroup_start_move()/mem_cgroup_end_move()
Message-ID: <20141023175338.GA15937@phnom.home.cmpxchg.org>
References: <1414075327-15039-1-git-send-email-hannes@cmpxchg.org>
 <20141023155607.GN23011@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141023155607.GN23011@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 23, 2014 at 05:56:07PM +0200, Michal Hocko wrote:
> On Thu 23-10-14 10:42:07, Johannes Weiner wrote:
> > Having these functions and their documentation split out and somewhere
> > makes it harder, not easier, to follow what's going on.
> > 
> > Inline them directly where charge moving is prepared and finished, and
> > put an explanation right next to it.
> 
> I do not see the open coded version much more readable or maintainable to be
> honest. mem_cgroup_{start,end}_move are a good markers of the transaction.

What transaction, though?  The names are really non-descript and they
actively hide what's going on.  mem_cgroup_start_move() could mean
anything that prepares for moving and it doesn't seem out of place in
can_attach().  atomic_inc(&memcg->moving_account) on the other hand is
much more specific and nicely shows that we are currently forcing the
page stat update slow path way too early.  There is no reason to make
it take the move_lock while we are still counting rss and precharging,
we are not actually moving charges and flipping pc->mem_cgroups yet.

[ I already have a patch to relocate it into mem_cgroup_move_charge(),
  but let's let the dust in -mm settle a bit first. :-) ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
