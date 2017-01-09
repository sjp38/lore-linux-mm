Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4CB86B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 03:51:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so13611271wmi.6
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 00:51:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10si96101182wjn.46.2017.01.09.00.51.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 00:51:00 -0800 (PST)
Date: Mon, 9 Jan 2017 09:50:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: support __GFP_REPEAT in kvmalloc_node
Message-ID: <20170109085057.GB7495@dhcp22.suse.cz>
References: <20170102133700.1734-1-mhocko@kernel.org>
 <20170104181229.GB10183@dhcp22.suse.cz>
 <49b2c2de-5d50-1f61-5ddf-e72c52017534@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49b2c2de-5d50-1f61-5ddf-e72c52017534@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, linux-ext4@vger.kernel.org, Joe Perches <joe@perches.com>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>

On Fri 06-01-17 13:09:36, Vlastimil Babka wrote:
> On 01/04/2017 07:12 PM, Michal Hocko wrote:
> > While checking opencoded users I've encountered that vhost code would
> > really like to use kvmalloc with __GFP_REPEAT [1] so the following patch
> > adds support for __GFP_REPEAT and converts both vhost users.
> > 
> > So currently I am sitting on 3 patches. I will wait for more feedback -
> > especially about potential split ups or cleanups few more days and then
> > repost the whole series.
> > 
> > [1] http://lkml.kernel.org/r/20170104150800.GO25453@dhcp22.suse.cz
> > ---
> > From 0b92e4d2e040524b878d4e7b9ee88fbad5284b33 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Wed, 4 Jan 2017 18:01:39 +0100
> > Subject: [PATCH] mm: support __GFP_REPEAT in kvmalloc_node
> > 
> > vhost code uses __GFP_REPEAT when allocating vhost_virtqueue resp.
> > vhost_vsock because it would really like to prefer kmalloc to the
> > vmalloc fallback - see 23cc5a991c7a ("vhost-net: extend device
> > allocation to vmalloc") for more context. Michael Tsirkin has also
> > noted:
> > "
> > __GFP_REPEAT overhead is during allocation time.  Using vmalloc means all
> > accesses are slowed down.  Allocation is not on data path, accesses are.
> > "
> > 
> > Let's teach kvmalloc_node to handle __GFP_REPEAT properly. There are two
> > things to be careful about. First we should prevent from the OOM killer
> > and so have to involve __GFP_NORETRY by default and secondly override
> > __GFP_REPEAT for !costly order requests as the __GFP_REPEAT is ignored
> > for !costly orders.
> > 
> > This patch shouldn't introduce any functional change.
> 
> Which is because the converted usages are always used for costly order,
> right.

I have overlooked this remark previously. You are right. And I've
updated the documentation and also the inline comment to be more
explicit about this. We do not have a good way to support __GFP_REPEAT
for !costly orders currently unfortunatelly. Maybe I should revive my
__GFP_RETRY_MAYFAIL patch, this would be another user (outside of xfs
which already wants something like that for KM_MAYFAIL.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
