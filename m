Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D42EA6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 06:53:41 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id jl1so88988298obb.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 03:53:41 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 5si1270769ote.236.2016.04.27.03.53.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 03:53:41 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: add PF_MEMALLOC_NOFS
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <1461671772-1269-2-git-send-email-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <32e220de-6028-a32c-e6a5-6935b97d277d@I-love.SAKURA.ne.jp>
Date: Wed, 27 Apr 2016 19:53:21 +0900
MIME-Version: 1.0
In-Reply-To: <1461671772-1269-2-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 2016/04/26 20:56, Michal Hocko wrote:
> Not only this is easier to understand and maintain because there are
> much less problematic contexts than specific allocation requests, this
> also helps code paths where FS layer interacts with other layers (e.g.
> crypto, security modules, MM etc...) and there is no easy way to convey
> the allocation context between the layers.
> 

You arrived at what I wished at
http://lkml.kernel.org/r/201503172305.DIH52162.FOFMFOVJHLOtQS@I-love.SAKURA.ne.jp
(i.e. not CONFIG_DEBUG_* but always enabled).

> Introduce PF_MEMALLOC_NOFS task specific flag and memalloc_nofs_{save,restore}
> API to control the scope. This is basically copying
> memalloc_noio_{save,restore} API we have for other restricted allocation
> context GFP_NOIO.
> 
> Xfs has already had a similar functionality as PF_FSTRANS so let's just
> give it a more generic name and make it usable for others as well and
> move the GFP_NOFS context tracking to the page allocator. Xfs has its
> own accessor functions but let's keep them for now to reduce this patch
> as minimum.
> 
> This patch shouldn't introduce any functional changes. Xfs code paths
> preserve their semantic. kmem_flags_convert() doesn't need to evaluate
> the flag anymore because it is the page allocator to care about the
> flag. memalloc_noio_flags is renamed to current_gfp_context because it
> now cares about both PF_MEMALLOC_NOFS and PF_MEMALLOC_NOIO contexts.
> 
> Let's hope that filesystems will drop direct GFP_NOFS (resp. ~__GFP_FS)
> usage as much and possible and only use a properly documented
> memalloc_nofs_{save,restore} checkpoints where they are appropriate.

Is the story simple enough to monotonically replace GFP_NOFS/GFP_NOIO
with GFP_KERNEL after memalloc_no{fs,io}_{save,restore} are inserted?
We sometimes delegate some operations to somebody else. Don't we need to
convey PF_MEMALLOC_NOFS/PF_MEMALLOC_NOIO flags to APIs which interact with
other threads?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
