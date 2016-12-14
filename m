Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53AE46B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:05:07 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o2so4699655wje.5
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 01:05:07 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id g66si6275939wmf.113.2016.12.14.01.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 01:05:05 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id kp2so3160556wjc.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 01:05:05 -0800 (PST)
Date: Wed, 14 Dec 2016 10:05:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20161214090502.GC25573@dhcp22.suse.cz>
References: <20161208103300.23217-1-mhocko@kernel.org>
 <20161213101451.GB10492@dhcp22.suse.cz>
 <C2C892CD-BAF7-4E72-927D-B79D95A9B7FA@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C2C892CD-BAF7-4E72-927D-B79D95A9B7FA@dilger.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, LKML <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>

On Tue 13-12-16 13:55:46, Andreas Dilger wrote:
> On Dec 13, 2016, at 3:14 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > Are there any more comments or objections to this patch? Is this a good
> > start or kv[mz]alloc has to provide a way to cover GFP_NOFS users as
> > well in the initial version.
> 
> I'm in favour of this cleanup as a starting point.  I definitely agree
> that this same functionality is in use in a number of places and should
> be consolidated.
> 
> The vmalloc() from GFP_NOFS can be addressed separately in later patches.
> That is an issue for several filesystems, and while XFS works around this,
> it would be better to lift that out of the filesystem code into the VM.

Well, my longer term plan is to change how GFP_NOFS is used from the fs
code rather than tweak the VM layer. The current situation with the nofs
is messy and confusing. In many contexts it is used without a good
reason - just to be sure that nothing will break. I strongly believe
that we should use a scope api [1] which marks whole regions of
potentially reclaim dangerous code paths and all the allocations within
that region will inherit the nofs protection automatically. That would
solve the vmalloc(GFP_NOFS) problem as well. The route to get there is
no short or easy. I am planning to repost the scope patchset hopefully
soon with ext4 converted.

[1] http://lkml.kernel.org/r/1461671772-1269-1-git-send-email-mhocko@kernel.org

> Really, there are several of things about vmalloc() that could improve
> if we decided to move it out of the dog house and allow it to become a
> first class citizen, but that needs a larger discussion, and you can
> already do a lot of cleanup with just the introduction of kvmalloc().
> 
> Since this is changing the ext4 code, you can add my:
> 
> Reviewed-by: Andreas Dilger <adilger@dilger.ca>

thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
