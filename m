Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 05B996B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 06:30:03 -0400 (EDT)
Received: by iofh134 with SMTP id h134so52682351iof.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 03:30:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bd3si40750437pdb.204.2015.09.03.03.30.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 03:30:02 -0700 (PDT)
Date: Thu, 3 Sep 2015 12:29:49 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150903122949.78ee3c94@redhat.com>
In-Reply-To: <20150903060247.GV1933@devil.localdomain>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903060247.GV1933@devil.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: brouer@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>, Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>


On Thu, 3 Sep 2015 16:02:47 +1000 Dave Chinner <dchinner@redhat.com> wrote:

> On Wed, Sep 02, 2015 at 06:21:02PM -0700, Linus Torvalds wrote:
> > On Wed, Sep 2, 2015 at 5:51 PM, Mike Snitzer <snitzer@redhat.com> wrote:
> > >
> > > What I made possible with SLAB_NO_MERGE is for each subsystem to decide
> > > if they would prefer to not allow slab merging.
> > 
> > .. and why is that a choice that even makes sense at that level?
> > 
> > Seriously.
> > 
> > THAT is the fundamental issue here.
> 
> It makes a lot more sense than you think, Linus.
> 
[...]
> 
> On the surface, this looks like a big win but it's not - it's
> actually a major problem for slab reclaim and it manifests when
> there are large bursts of allocation activity followed by sudden
> reclaim activity.  When the slab grows rapidly, we get the majority
> of objects on a page being of one type, but a couple will be of a
> different type. Than under memory pressure, the shrinker can then
> only free the majority of objects on a page, guaranteeing the slab
> will remain fragmented under memory pressure.  Continuing to run the
> shrinker won't result in any more memory being freed from the merged
> slab and so we are stuck with unfixable slab fragmentation.
> 
> However, if the slab with a shrinker only contains one kind of
> object, when it becomes fragmented due to variable object lifetime,
> continued memory pressure will cause it to keep shrinking and hence
> will eventually correct the fragmentation problem. This is a much
> more robust configuration - the system will self correct without
> user intervention being necessary.
> 
> IOWs, slab merging prevents us from implementing effective active
> fragmentation management algorithms and hence prevents us  from
> reducing slab fragmentation via improved shrinker reclaim
> algorithms.  Simply put: slab merging reduces the effectiveness of
> shrinker based slab reclaim.

I'm buying into the problem of variable object lifetime sharing the
same slub.

With the SLAB bulk free API I'm introducing, we can speedup slub
slowpath, by free several objects with a single cmpxchg_double, BUT
these objects need to belong to the same page.
 Thus, as Dave describe with merging, other users of the same size
objects might end up holding onto objects scattered across several
pages, which gives the bulk free less opportunities.

That would be a technical argument for introducing a SLAB_NO_MERGE flag
per slab.  But I want to do some measurement before making any
decision. And it might be hard to show for my use-case of SKB free,
because SKB allocs will likely be dominating 256 bytes slab anyhow.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
