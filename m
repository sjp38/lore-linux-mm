Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9DFF6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 11:02:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so76353597wma.2
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 08:02:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p199si49715837wmd.1.2017.01.02.08.02.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jan 2017 08:02:54 -0800 (PST)
Date: Mon, 2 Jan 2017 17:02:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20170102160249.GA11635@dhcp22.suse.cz>
References: <20170102133700.1734-1-mhocko@kernel.org>
 <1483372522.1955.20.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1483372522.1955.20.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, linux-ext4@vger.kernel.org, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>

On Mon 02-01-17 07:55:22, Joe Perches wrote:
> On Mon, 2017-01-02 at 14:37 +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Using kmalloc with the vmalloc fallback for larger allocations is a
> > common pattern in the kernel code. Yet we do not have any common helper
> > for that and so users have invented their own helpers. Some of them are
> > really creative when doing so. Let's just add kv[mz]alloc and make sure
> > it is implemented properly. This implementation makes sure to not make
> > a large memory pressure for > PAGE_SZE requests (__GFP_NORETRY) and also
> > to not warn about allocation failures. This also rules out the OOM
> > killer as the vmalloc is a more approapriate fallback than a disruptive
> > user visible action.
> > 
> > This patch also changes some existing users and removes helpers which
> > are specific for them. In some cases this is not possible (e.g.
> > ext4_kvmalloc, libcfs_kvzalloc, __aa_kvmalloc) because those seems to be
> > broken and require GFP_NO{FS,IO} context which is not vmalloc compatible
> > in general (note that the page table allocation is GFP_KERNEL). Those
> > need to be fixed separately.
> > 
> > apparmor has already claimed kv[mz]alloc so remove those and use
> > __aa_kvmalloc instead to prevent from the naming clashes.
> 
> I have no real objection but perhaps this would
> be better done as 3 or more patches
> 
> o rename apparmor uses
> o introduce generic
> o conversions to generic

Whatever maintainers of the respective code prefer. I usually prefer to
have newly introduced functions along with their users so that it is
clear how they are used. The patch doesn't seem to be too large
either...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
