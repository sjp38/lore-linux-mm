Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6CFF26B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 08:08:40 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so38331644wgx.3
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 05:08:39 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id vm3si9418146wjc.165.2015.07.09.05.08.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 05:08:38 -0700 (PDT)
Received: by wiga1 with SMTP id a1so311062801wig.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 05:08:38 -0700 (PDT)
Date: Thu, 9 Jul 2015 14:08:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/8] memcg, mm: move mem_cgroup_select_victim_node into
 vmscan
Message-ID: <20150709120835.GF13872@dhcp22.suse.cz>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-5-git-send-email-mhocko@kernel.org>
 <20150708160159.GD2436@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150708160159.GD2436@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 08-07-15 19:01:59, Vladimir Davydov wrote:
> On Wed, Jul 08, 2015 at 02:27:48PM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.cz>
> > 
> > We currently have only one caller of mem_cgroup_select_victim_node which
> > is sitting in mm/vmscan.c and which is already wrapped by CONFIG_MEMCG
> > ifdef. Now that we have struct mem_cgroup visible outside of
> > mm/memcontrol.c we can move the function and its dependencies there.
> > This even shrinks the code size by few bytes:
> > 
> >    text    data     bss     dec     hex filename
> >  478509   65806   26384  570699   8b54b mm/built-in.o.before
> >  478445   65806   26384  570635   8b50b mm/built-in.o.after
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> I dislike this patch, because I don't see any reason why logic specific
> to per memcg reclaim should live in the file representing the global
> reclaim path.

Well the idea was that mem_cgroup_select_victim_node is specific to
try_to_free_mem_cgroup_pages. It is basically a split up of otherwise
large function for readability. Same applies to
mem_cgroup_may_update_nodemask. Having that code together makes some
sense to me.

On the other hand I do agree that at least
test_mem_cgroup_node_reclaimable is generally reusable and so it
shouldn't be in vmscan. I can move it back to memcontrol but that leaves
the generated code much worse.

Fair enough then, I will drop this patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
