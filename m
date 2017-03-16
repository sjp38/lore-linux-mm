Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B59EF6B038B
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 14:34:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n11so12045885wma.5
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:34:34 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h26si7730926wrb.231.2017.03.16.11.34.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 11:34:33 -0700 (PDT)
Date: Thu, 16 Mar 2017 14:34:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 0/8] try to reduce fragmenting fallbacks
Message-ID: <20170316183422.GA1461@cmpxchg.org>
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170308164631.GA12130@cmpxchg.org>
 <fbc47cf0-2f8f-defc-cd79-50395e9985a7@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fbc47cf0-2f8f-defc-cd79-50395e9985a7@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com

On Wed, Mar 08, 2017 at 08:17:39PM +0100, Vlastimil Babka wrote:
> On 8.3.2017 17:46, Johannes Weiner wrote:
> > Is there any other data you would like me to gather?
> 
> If you can enable the extfrag tracepoint, it would be nice to have graphs of how
> unmovable allocations falling back to movable pageblocks, etc.

Okay, here we go. I recorded 24 hours worth of the extfrag tracepoint,
filtered to fallbacks from unmovable requests to movable blocks. I've
uploaded the plot here:

http://cmpxchg.org/antifrag/fallbackrate.png

but this already speaks for itself:

11G     alloc-mtfallback.trace
3.3G    alloc-mtfallback-patched.trace

;)

> Possibly also /proc/pagetypeinfo for numbers of pageblock types.

After a week of uptime, the patched (b) kernel has more movable blocks
than vanilla 4.10-rc8 (a):

   Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic          CMA      Isolate

a: Node 1, zone   Normal         2017        29763          987            1            0            0
b: Node 1, zone   Normal         1264        30850          653            1            0            0

I sampled this somewhat sporadically over the week and it's been
reading reliably this way.

The patched kernel also consistently beats vanilla in terms of peak
job throughput.

Overall very cool!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
