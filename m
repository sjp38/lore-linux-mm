Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6B496B0253
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 01:22:27 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id hb5so3254391wjc.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 22:22:27 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id b11si32640022wjs.152.2016.12.08.22.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 22:22:26 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id j10so892439wjb.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 22:22:26 -0800 (PST)
Date: Fri, 9 Dec 2016 07:22:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20161209062224.GB12012@dhcp22.suse.cz>
References: <20161208103300.23217-1-mhocko@kernel.org>
 <20161209014417.GN4326@dastard>
 <20161209020016.GX1555@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161209020016.GX1555@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, LKML <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org

On Fri 09-12-16 02:00:17, Al Viro wrote:
> On Fri, Dec 09, 2016 at 12:44:17PM +1100, Dave Chinner wrote:
> > On Thu, Dec 08, 2016 at 11:33:00AM +0100, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > Using kmalloc with the vmalloc fallback for larger allocations is a
> > > common pattern in the kernel code. Yet we do not have any common helper
> > > for that and so users have invented their own helpers. Some of them are
> > > really creative when doing so. Let's just add kv[mz]alloc and make sure
> > > it is implemented properly. This implementation makes sure to not make
> > > a large memory pressure for > PAGE_SZE requests (__GFP_NORETRY) and also
> > > to not warn about allocation failures. This also rules out the OOM
> > > killer as the vmalloc is a more approapriate fallback than a disruptive
> > > user visible action.
> > > 
> > > This patch also changes some existing users and removes helpers which
> > > are specific for them. In some cases this is not possible (e.g.
> > > ext4_kvmalloc, libcfs_kvzalloc, __aa_kvmalloc) because those seems to be
> > > broken and require GFP_NO{FS,IO} context which is not vmalloc compatible
> > > in general (note that the page table allocation is GFP_KERNEL). Those
> > > need to be fixed separately.
> > 
> > See fs/xfs/kmem.c::kmem_zalloc_large(), which is XFS's version of
> > kvmalloc() that is GFP_NOFS/GFP_NOIO safe. Any generic API for this
> > functionality will have to play these memalloc_noio_save/
> > memalloc_noio_restore games to ensure they are GFP_NOFS safe....
> 
> Easier to handle those in vmalloc() itself.

I think there were some attempts in the past but some of the code paths
are burried too deep and adding gfp_mask all the way down there seemed
like a major surgery.

> The problem I have with these
> helpers is that different places have different cutoff thresholds for
> switch from kmalloc to vmalloc; has anyone done an analysis of those?

Yes, I have noticed some creativity as well. Some of them didn't bother
to kmalloc at all for size > PAGE_SIZE. Some where playing tricks with
PAGE_ALLOC_COSTLY_ORDER. I believe the right thing to do is to simply do
not hammer the system with size > PAGE_SZE which means __GFP_NORETRY for
them and fallback to vmalloc on the failure (basically what
seq_buf_alloc did). I cannot offer any numbers but at least
seq_buf_alloc has proven to do the right thing over time.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
