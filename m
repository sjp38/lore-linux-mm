Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE9D76B0273
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:29:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b34-v6so1751048ede.5
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:29:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a36-v6si405722edd.80.2018.10.03.09.29.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 09:29:07 -0700 (PDT)
Date: Wed, 3 Oct 2018 18:29:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmstat: fix outdated vmstat_text
Message-ID: <20181003162905.GK4714@dhcp22.suse.cz>
References: <20180929013611.163130-1-jannh@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180929013611.163130-1-jannh@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Roman Gushchin <guro@fb.com>, Kemi Wang <kemi.wang@intel.com>, Kees Cook <keescook@chromium.org>

On Sat 29-09-18 03:36:11, Jann Horn wrote:
> commit 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
> removed the VMACACHE_FULL_FLUSHES statistics, but didn't remove the
> corresponding entry in vmstat_text. This causes an out-of-bounds access in
> vmstat_show().
> 
> Luckily this only affects kernels with CONFIG_DEBUG_VM_VMACACHE=y, which is
> probably very rare.
> 
> Having two gigantic arrays that must be kept in sync isn't exactly robust.
> To make it easier to catch such issues in the future, add a BUILD_BUG_ON().
> 
> Fixes: 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jannh@google.com>

Those could be two separate patches but anyway
Acked-by: Michal Hocko <mhocko@suse.com>

to both changes. I have burned myself on this in the past as well. Build
bugon would save me a lot of debugging.

> ---
>  mm/vmstat.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 8ba0870ecddd..db6379a3f8bf 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1283,7 +1283,6 @@ const char * const vmstat_text[] = {
>  #ifdef CONFIG_DEBUG_VM_VMACACHE
>  	"vmacache_find_calls",
>  	"vmacache_find_hits",
> -	"vmacache_full_flushes",
>  #endif
>  #ifdef CONFIG_SWAP
>  	"swap_ra",
> @@ -1661,6 +1660,8 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
>  	stat_items_size += sizeof(struct vm_event_state);
>  #endif
>  
> +	BUILD_BUG_ON(stat_items_size !=
> +		     ARRAY_SIZE(vmstat_text) * sizeof(unsigned long));
>  	v = kmalloc(stat_items_size, GFP_KERNEL);
>  	m->private = v;
>  	if (!v)
> -- 
> 2.19.0.605.g01d371f741-goog

-- 
Michal Hocko
SUSE Labs
