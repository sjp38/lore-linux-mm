Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7B56B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 07:17:31 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e53so67184eek.41
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 04:17:30 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d46si7489469eeo.39.2014.01.15.04.17.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 04:17:29 -0800 (PST)
Date: Wed, 15 Jan 2014 13:17:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/3] mm/memcg: fix endless iteration in reclaim
Message-ID: <20140115121728.GJ8782@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
 <alpine.LSU.2.11.1401131751080.2229@eggly.anvils>
 <20140114132727.GB32227@dhcp22.suse.cz>
 <20140114142610.GF32227@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401141201120.3762@eggly.anvils>
 <20140115095829.GI8782@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140115095829.GI8782@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 15-01-14 10:58:29, Michal Hocko wrote:
> On Tue 14-01-14 12:42:28, Hugh Dickins wrote:
> > On Tue, 14 Jan 2014, Michal Hocko wrote:
[...]
> > > Ouch. And thinking about this shows that out_css_put is broken as well
> > > for subtree walks (those that do not start at root_mem_cgroup level). We
> > > need something like the the snippet bellow.
> > 
> > It's the out_css_put precedent that I was following in not incrementing
> > for the root.  I think that's been discussed in the past, and rightly or
> > wrongly we've concluded that the caller of mem_cgroup_iter() always has
> > some hold on the root, which makes it safe to skip get/put on it here.
> > No doubt one of those many short cuts to avoid memcg overhead when
> > there's no memcg other than the root_mem_cgroup.
> 
> That might be true but I guess it makes sense to get rid of some subtle
> assumptions. Especially now that we have an effective per-cpu ref.
> counting for css.

OK, I finally found some time to think about this some more and it seems
that the issue you have reported and the above issue are in fact
identical. css reference counting optimization in fact also prevent from
the endless loop you are seeing here because we simply didn't call
css_tryget on the root...

Therefore I guess we should reintroduce the optimization. What do you
think about the following? This is on top of the current mmotm but it
certainly needs backporting to the stable kernels.
---
