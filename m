Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 1B5EE6B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 05:51:39 -0400 (EDT)
Date: Mon, 19 Aug 2013 11:51:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH mmotm,next] mm: fix memcg-less page reclaim
Message-ID: <20130819095136.GB3396@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1308182254220.1040@eggly.anvils>
 <20130819074407.GA3396@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130819074407.GA3396@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

[Let's CC Johannes, Kamezewa and Kosaki]

On Mon 19-08-13 09:44:07, Michal Hocko wrote:
> On Sun 18-08-13 23:05:25, Hugh Dickins wrote:
[...]
> > Adding mem_cgroup_disabled() and once++ test there is ugly.  Ideally,
> > even a !CONFIG_MEMCG build might in future have a stub root_mem_cgroup,
> > which would get around this: but that's not so at present.
> > 
> > However, it appears that nothing actually dereferences the memcg pointer
> > in the mem_cgroup_disabled() case, here or anywhere else that case can
> > reach mem_cgroup_iter() (mem_cgroup_iter_break() is not called in
> > global reclaim).
> > 
> > So, simply pass back an ordinarily-oopsing non-NULL address the first
> > time, and we shall hear about it if I'm wrong.
> 
> This is a bit tricky but it seems like the easiest way for now. I will
> look at the fake root cgroup for !CONFIG_MEMCG.

OK, the following builds for both CONFIG_MEMCG enabled and disabled and
should work with cgroup_disable=memory as well as we are allocating
root_mem_cgroup for disabled case as well AFAICS.

It looks less scary than I expected. I haven't tested it yet but if you
think that it looks promising I will send a full patch with changelog.
---
