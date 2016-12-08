Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9D26B0253
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 04:18:09 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o2so86642082wje.5
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 01:18:09 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id t65si12433142wmf.30.2016.12.08.01.18.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 01:18:07 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 469A798624
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 09:18:07 +0000 (UTC)
Date: Thu, 8 Dec 2016 09:18:06 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161208091806.gzcxlerxprcjvt3l@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
 <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161207194801.krhonj7yggbedpba@techsingularity.net>
 <1481141424.4930.71.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161207211958.s3ymjva54wgakpkm@techsingularity.net>
 <20161207232531.fxqdgrweilej5gs6@techsingularity.net>
 <20161208092231.55c7eacf@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161208092231.55c7eacf@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Dec 08, 2016 at 09:22:31AM +0100, Jesper Dangaard Brouer wrote:
> On Wed, 7 Dec 2016 23:25:31 +0000
> Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > On Wed, Dec 07, 2016 at 09:19:58PM +0000, Mel Gorman wrote:
> > > At small packet sizes on localhost, I see relatively low page allocator
> > > activity except during the socket setup and other unrelated activity
> > > (khugepaged, irqbalance, some btrfs stuff) which is curious as it's
> > > less clear why the performance was improved in that case. I considered
> > > the possibility that it was cache hotness of pages but that's not a
> > > good fit. If it was true then the first test would be slow and the rest
> > > relatively fast and I'm not seeing that. The other side-effect is that
> > > all the high-order pages that are allocated at the start are physically
> > > close together but that shouldn't have that big an impact. So for now,
> > > the gain is unexplained even though it happens consistently.
> > >   
> > 
> > Further investigation led me to conclude that the netperf automation on
> > my side had some methodology errors that could account for an artifically
> > low score in some cases. The netperf automation is years old and would
> > have been developed against a much older and smaller machine which may be
> > why I missed it until I went back looking at exactly what the automation
> > was doing. Minimally in a server/client test on remote maching there was
> > potentially higher packet loss than is acceptable. This would account why
> > some machines "benefitted" while others did not -- there would be boot to
> > boot variations that some machines happened to be "lucky". I believe I've
> > corrected the errors, discarded all the old data and scheduled a rest to
> > see what falls out.
> 
> I guess you are talking about setting the netperf socket queue low
> (+256 bytes above msg size), that I pointed out in[1]. 

Primarily, yes.

> From the same commit[2] I can see you explicitly set (local+remote):
> 
>   sysctl net.core.rmem_max=16777216
>   sysctl net.core.wmem_max=16777216
> 

Yes, I set it for higher speed networks as a starting point to remind me
to examine rmem_default or socket configurations if any significant packet
loss is observed.

> Eric do you have any advice on this setting?
> 
> And later[4] you further increase this to 32MiB.  Notice that the
> netperf UDP_STREAM test will still use the default value from:
> net.core.rmem_default = 212992.
> 

That's expected. In the initial sniff-test, I saw negligible packet loss.
I'm waiting to see what the full set of network tests look like before
doing any further adjustments.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
