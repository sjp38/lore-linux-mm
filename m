Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2426B02AA
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:57:13 -0400 (EDT)
Received: by igvi1 with SMTP id i1so86526974igv.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 13:57:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a79si4651823ioj.25.2015.07.15.13.57.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 13:57:12 -0700 (PDT)
Date: Wed, 15 Jul 2015 13:57:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] memcg: export struct mem_cgroup
Message-Id: <20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
In-Reply-To: <1436958885-18754-2-git-send-email-mhocko@kernel.org>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
	<1436958885-18754-2-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 15 Jul 2015 13:14:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> mem_cgroup structure is defined in mm/memcontrol.c currently which
> means that the code outside of this file has to use external API even
> for trivial access stuff.
> 
> This patch exports mm_struct with its dependencies and makes some of the
> exported functions inlines. This even helps to reduce the code size a bit
> (make defconfig + CONFIG_MEMCG=y)
> 
> text		data    bss     dec     	 hex 	filename
> 12355346        1823792 1089536 15268674         e8fb42 vmlinux.before
> 12354970        1823792 1089536 15268298         e8f9ca vmlinux.after
> 
> This is not much (370B) but better than nothing. We also save a function
> call in some hot paths like callers of mem_cgroup_count_vm_event which is
> used for accounting.
> 
> The patch doesn't introduce any functional changes.
> 
> ...
>
>  include/linux/memcontrol.h | 369 +++++++++++++++++++++++++++++++++++++++++----

Boy, that's a ton of new stuff into the header file.  Do we actually
*need* to expose all this?  Is some other patch dependent on it?  If
not then perhaps we shouldn't do this - if the code was already this
way, I'd be attracted to a patch which was the reverse of this one!

There's some risk of build breakage here - just from a quick scan,
memcontrol.h is going to need eventfd.h for eventfd_ctx.  But what else
is needed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
