Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A37ED6B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 18:31:15 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g23so11423221wme.4
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 15:31:15 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id n11si9375951wjw.117.2016.12.16.15.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 15:31:14 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id xy5so16209269wjc.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 15:31:14 -0800 (PST)
Date: Sat, 17 Dec 2016 00:31:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM: Better, but still there on 4.9
Message-ID: <20161216233111.GA23392@dhcp22.suse.cz>
References: <20161215225702.GA27944@boerne.fritz.box>
 <20161216073941.GA26976@dhcp22.suse.cz>
 <1da4691d-d0da-a620-020c-c2e968c2a5ec@fb.com>
 <20161216221420.GF7645@dhcp22.suse.cz>
 <4e87e963-154a-df2c-80a4-ecc6d898f9a8@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4e87e963-154a-df2c-80a4-ecc6d898f9a8@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <clm@fb.com>
Cc: Nils Holland <nholland@tisys.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Fri 16-12-16 17:47:25, Chris Mason wrote:
> On 12/16/2016 05:14 PM, Michal Hocko wrote:
> > On Fri 16-12-16 13:15:18, Chris Mason wrote:
> > > On 12/16/2016 02:39 AM, Michal Hocko wrote:
> > [...]
> > > > I believe the right way to go around this is to pursue what I've started
> > > > in [1]. I will try to prepare something for testing today for you. Stay
> > > > tuned. But I would be really happy if somebody from the btrfs camp could
> > > > check the NOFS aspect of this allocation. We have already seen
> > > > allocation stalls from this path quite recently
> > > 
> > > Just double checking, are you asking why we're using GFP_NOFS to avoid going
> > > into btrfs from the btrfs writepages call, or are you asking why we aren't
> > > allowing highmem?
> > 
> > I am more interested in the NOFS part. Why cannot this be a full
> > GFP_KERNEL context? What kind of locks we would lock up when recursing
> > to the fs via slab shrinkers?
> > 
> 
> Since this is our writepages call, any jump into direct reclaim would go to
> writepage, which would end up calling the same set of code to read metadata
> blocks, which would do a GFP_KERNEL allocation and end up back in writepage
> again.

But we are not doing pageout on the page cache from the direct reclaim
for a long time. So basically the only way to recurse back to the fs
code is via slab ([di]cache) shrinkers. Are those a problem as well?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
