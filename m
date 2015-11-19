Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 689176B0255
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:12:39 -0500 (EST)
Received: by wmvv187 with SMTP id v187so40983842wmv.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 11:12:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fd18si13099219wjc.165.2015.11.19.11.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 11:12:38 -0800 (PST)
Date: Thu, 19 Nov 2015 14:12:29 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 6/6] Account certain kmem allocations to memcg
Message-ID: <20151119191229.GF3941@cmpxchg.org>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <3af491b9661b97708ec38e9f9a4f0cccb69ade5c.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3af491b9661b97708ec38e9f9a4f0cccb69ade5c.1447172835.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 10, 2015 at 09:34:07PM +0300, Vladimir Davydov wrote:
> This patch marks those kmem allocations that are known to be easily
> triggered from userspace as __GFP_ACCOUNT/SLAB_ACCOUNT, which makes them
> accounted to memcg. For the list, see below:
> 
>  - threadinfo
>  - task_struct
>  - task_delay_info
>  - pid
>  - cred
>  - mm_struct
>  - vm_area_struct and vm_region (nommu)
>  - anon_vma and anon_vma_chain
>  - signal_struct
>  - sighand_struct
>  - fs_struct
>  - files_struct
>  - fdtable and fdtable->full_fds_bits
>  - dentry and external_name
>  - inode for all filesystems. This is the most tedious part, because
>    most filesystems overwrite the alloc_inode method.
> 
> The list is by far not complete, so feel free to add more objects.
> Nevertheless, it should be close to "account everything" approach and
> keep most workloads within bounds. Malevolent users will be able to
> breach the limit, but this was possible even with the former "account
> everything" approach (simply because it did not account everything in
> fact).
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks for doing that work, Vladimir. It looks reasonable to me.

We can update the list as we go along and testing reveals more things
that need to be considered. As far as malicious users go, I agree that
we can not make this bullet proof, and so we shouldn't aim for that.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
