Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id AD5936B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 12:02:11 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so147902516pdb.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 09:02:11 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ew8si4815722pac.28.2015.07.08.09.02.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 09:02:10 -0700 (PDT)
Date: Wed, 8 Jul 2015 19:01:59 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 4/8] memcg, mm: move mem_cgroup_select_victim_node into
 vmscan
Message-ID: <20150708160159.GD2436@esperanza>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-5-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1436358472-29137-5-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Wed, Jul 08, 2015 at 02:27:48PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.cz>
> 
> We currently have only one caller of mem_cgroup_select_victim_node which
> is sitting in mm/vmscan.c and which is already wrapped by CONFIG_MEMCG
> ifdef. Now that we have struct mem_cgroup visible outside of
> mm/memcontrol.c we can move the function and its dependencies there.
> This even shrinks the code size by few bytes:
> 
>    text    data     bss     dec     hex filename
>  478509   65806   26384  570699   8b54b mm/built-in.o.before
>  478445   65806   26384  570635   8b50b mm/built-in.o.after
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

I dislike this patch, because I don't see any reason why logic specific
to per memcg reclaim should live in the file representing the global
reclaim path. With such an approach you may end up with moving
mem_cgroup_low, mem_cgroup_soft_limit_reclaim, etc to vmscan.c, because
they are used only there. I don't think it's right.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
