Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A58E6B30F9
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:15:59 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c18so5465630edt.23
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:15:59 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j11-v6si9104402ejk.136.2018.11.23.03.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 03:15:58 -0800 (PST)
Date: Fri, 23 Nov 2018 12:15:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: Check if mmu notifier callbacks are allowed to
 fail
Message-ID: <20181123111557.GG8625@dhcp22.suse.cz>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-2-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181122165106.18238-2-daniel.vetter@ffwll.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

On Thu 22-11-18 17:51:04, Daniel Vetter wrote:
> Just a bit of paranoia, since if we start pushing this deep into
> callchains it's hard to spot all places where an mmu notifier
> implementation might fail when it's not allowed to.

What does WARN give you more than the existing pr_info? Is really
backtrace that interesting?

> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Christian K�nig" <christian.koenig@amd.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: "J�r�me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> ---
>  mm/mmu_notifier.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 5119ff846769..59e102589a25 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -190,6 +190,8 @@ int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>  				pr_info("%pS callback failed with %d in %sblockable context.\n",
>  						mn->ops->invalidate_range_start, _ret,
>  						!blockable ? "non-" : "");
> +				WARN(blockable,"%pS callback failure not allowed\n",
> +				     mn->ops->invalidate_range_start);
>  				ret = _ret;
>  			}
>  		}
> -- 
> 2.19.1
> 

-- 
Michal Hocko
SUSE Labs
