Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id E2AC26B006C
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 11:19:27 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id fb4so18032680wid.2
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 08:19:27 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id et10si24051219wib.101.2015.02.02.08.19.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Feb 2015 08:19:26 -0800 (PST)
Date: Mon, 2 Feb 2015 17:18:57 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg, shmem: fix shmem migration to use lrucare. (was:
 Re: [Intel-gfx] memcontrol.c BUG)
Message-ID: <20150202161857.GA4275@cmpxchg.org>
References: <CAPM=9tyyP_pKpWjc7LBZU7e6wAt26XGZsyhRh7N497B2+28rrQ@mail.gmail.com>
 <20150128084852.GC28132@nuc-i3427.alporthouse.com>
 <20150128143242.GF6542@dhcp22.suse.cz>
 <alpine.LSU.2.11.1501291751170.1761@eggly.anvils>
 <20150202150050.GD4583@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150202150050.GD4583@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Chris Wilson <chris@chris-wilson.co.uk>, Dave Airlie <airlied@gmail.com>, "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Jet Chen <jet.chen@intel.com>, Felipe Balbi <balbi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Feb 02, 2015 at 04:00:51PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 2 Feb 2015 15:22:19 +0100
> Subject: [PATCH] memcg, shmem: fix shmem migration to use lrucare.
> 
> It has been reported that 965GM might trigger
> 
> VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage), oldpage)
> 
> in mem_cgroup_migrate when shmem wants to replace a swap cache page
> because of shmem_should_replace_page (the page is allocated from an
> inappropriate zone). shmem_replace_page expects that the oldpage is not
> on LRU list and calls mem_cgroup_migrate without lrucare. This is obviously
> incorrect because swapcache pages might be on the LRU list (e.g. swapin
> readahead page).
> 
> Fix this by enabling lrucare for the migration in shmem_replace_page.
> Also clarify that lrucare should be used even if one of the pages might
> be on LRU list.
> 
> The BUG_ON will trigger only when CONFIG_DEBUG_VM is enabled but even
> without that the migration code might leave the old page on an
> inappropriate memcg' LRU which is not that critical because the page
> would get removed with its last reference but it is still confusing.
> 
> Fixes: 0a31bc97c80c (mm: memcontrol: rewrite uncharge API)
> Cc: stable@vger.kernel.org # 3.17+
> Reported-by: Chris Wilson <chris@chris-wilson.co.uk>
> Reported-by: Dave Airlie <airlied@gmail.com>
> Acked-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks, Michal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
