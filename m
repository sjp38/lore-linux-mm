Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF2F6B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 03:39:21 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so8703166wic.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 00:39:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cp4si12737966wib.53.2015.05.14.00.39.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 00:39:19 -0700 (PDT)
Message-ID: <55545124.7090804@suse.cz>
Date: Thu, 14 May 2015 09:39:16 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Interacting with coherent memory on external devices
References: <20150424150829.GA3840@gmail.com>	 <alpine.DEB.2.11.1504241052240.9889@gentwo.org>	 <20150424164325.GD3840@gmail.com>	 <alpine.DEB.2.11.1504241148420.10475@gentwo.org>	 <20150424171957.GE3840@gmail.com>	 <alpine.DEB.2.11.1504241353280.11285@gentwo.org>	 <20150424192859.GF3840@gmail.com>	 <alpine.DEB.2.11.1504241446560.11700@gentwo.org>	 <20150425114633.GI5561@linux.vnet.ibm.com>	 <alpine.DEB.2.11.1504271004240.28895@gentwo.org>	 <20150427154728.GA26980@gmail.com>	 <alpine.DEB.2.11.1504271113480.29515@gentwo.org>	 <553E6405.1060007@redhat.com>	 <alpine.DEB.2.11.1504271147020.29735@gentwo.org>	 <1430178843.16571.134.camel@kernel.crashing.org> <55535B6E.5090700@suse.cz> <1431560326.20218.94.camel@kernel.crashing.org>
In-Reply-To: <1431560326.20218.94.camel@kernel.crashing.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Jerome Glisse <j.glisse@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On 05/14/2015 01:38 AM, Benjamin Herrenschmidt wrote:
> On Wed, 2015-05-13 at 16:10 +0200, Vlastimil Babka wrote:
>> Sorry for reviving oldish thread...
>
> Well, that's actually appreciated since this is constructive discussion
> of the kind I was hoping to trigger initially :-) I'll look at

I hoped so :)

> ZONE_MOVABLE, I wasn't aware of its existence.
>
> Don't we still have the problem that ZONEs must be somewhat contiguous
> chunks ? Ie, my "CAPI memory" will be interleaved in the physical
> address space somewhat.. This is due to the address space on some of
> those systems where you'll basically have something along the lines of:
>
> [ node 0 mem ] [ node 0 CAPI dev ] .... [ node 1 mem] [ node 1 CAPI dev] ...

Oh, I see. The VM code should cope with that, but some operations would 
be inefficiently looping over the holes in the CAPI zone by 2MB 
pageblock per iteration. This would include compaction scanning, which 
would suck if you need those large contiguous allocations as you said. 
Interleaving works better if it's done with a smaller granularity.

But I guess you could just represent the CAPI as multiple NUMA nodes, 
each with single ZONE_MOVABLE zone. Especially if "node 0 CAPI dev" and 
"node 1 CAPI dev" differs in other characteristics than just using a 
different range of PFNs... otherwise what's the point of this split anyway?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
