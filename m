Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8A07B6B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 07:31:21 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so3277368wmu.1
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 04:31:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l67si2561218wml.30.2017.01.06.04.31.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 04:31:20 -0800 (PST)
Date: Fri, 6 Jan 2017 13:31:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: support __GFP_REPEAT in kvmalloc_node
Message-ID: <20170106123117.GL5556@dhcp22.suse.cz>
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
[...]
> > diff --git a/mm/util.c b/mm/util.c
> > index 8e4ea6cbe379..a2bfb85e60e5 100644
> > --- a/mm/util.c
> > +++ b/mm/util.c
> > @@ -348,8 +348,13 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
> >  	 * Make sure that larger requests are not too disruptive - no OOM
> >  	 * killer and no allocation failure warnings as we have a fallback
> >  	 */
> > -	if (size > PAGE_SIZE)
> > -		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
> > +	if (size > PAGE_SIZE) {
> > +		kmalloc_flags |= __GFP_NOWARN;
> > +
> > +		if (!(kmalloc_flags & __GFP_REPEAT) ||
> > +				(size <= PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> > +			kmalloc_flags |= __GFP_NORETRY;
> 
> I think this would be more understandable for me if it was written in
> the opposite way, i.e. "if we have costly __GFP_REPEAT allocation, don't
> use __GFP_NORETRY",

Dunno, doesn't look much simpler to me
		kmalloc_flags |= __GFP_NORETRY;
		if ((kmalloc_flags & __GFP_REPEAT) &&
				(size > PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
			kmalloc_flags &= ~__GFP_NORETRY;
		}

> but nevermind, seems correct to me wrt current
> handling of both flags in the page allocator. And it serves as a good
> argument to have this wrapper in mm/ as we are hopefully more likely to
> keep it working as intended with future changes, than all the opencoded
> variants.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
