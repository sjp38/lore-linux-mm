Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBC2D6B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 20:44:59 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x23so8668594pgx.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 17:44:59 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id q17si31123605pfk.223.2016.12.08.17.44.57
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 17:44:58 -0800 (PST)
Date: Fri, 9 Dec 2016 12:44:17 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20161209014417.GN4326@dastard>
References: <20161208103300.23217-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161208103300.23217-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org

On Thu, Dec 08, 2016 at 11:33:00AM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Using kmalloc with the vmalloc fallback for larger allocations is a
> common pattern in the kernel code. Yet we do not have any common helper
> for that and so users have invented their own helpers. Some of them are
> really creative when doing so. Let's just add kv[mz]alloc and make sure
> it is implemented properly. This implementation makes sure to not make
> a large memory pressure for > PAGE_SZE requests (__GFP_NORETRY) and also
> to not warn about allocation failures. This also rules out the OOM
> killer as the vmalloc is a more approapriate fallback than a disruptive
> user visible action.
> 
> This patch also changes some existing users and removes helpers which
> are specific for them. In some cases this is not possible (e.g.
> ext4_kvmalloc, libcfs_kvzalloc, __aa_kvmalloc) because those seems to be
> broken and require GFP_NO{FS,IO} context which is not vmalloc compatible
> in general (note that the page table allocation is GFP_KERNEL). Those
> need to be fixed separately.

See fs/xfs/kmem.c::kmem_zalloc_large(), which is XFS's version of
kvmalloc() that is GFP_NOFS/GFP_NOIO safe. Any generic API for this
functionality will have to play these memalloc_noio_save/
memalloc_noio_restore games to ensure they are GFP_NOFS safe....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
