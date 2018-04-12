Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8BE6B0009
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 09:23:30 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f4-v6so3788956plm.12
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 06:23:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p7-v6si3400106plk.159.2018.04.12.06.23.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Apr 2018 06:23:29 -0700 (PDT)
Date: Thu, 12 Apr 2018 15:23:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] vmscan: Support multiple kswapd threads per node
Message-ID: <20180412132324.GG23400@dhcp22.suse.cz>
References: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
 <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
 <20180403133115.GA5501@dhcp22.suse.cz>
 <502E8C16-DEA1-40A5-85CB-923E3ABE0B45@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <502E8C16-DEA1-40A5-85CB-923E3ABE0B45@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Buddy Lumpkin <buddy.lumpkin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org

On Tue 10-04-18 20:10:24, Buddy Lumpkin wrote:
[...]
> > Also please note that the direct reclaim is a way to throttle overly
> > aggressive memory consumers. The more we do in the background context
> > the easier for them it will be to allocate faster. So I am not really
> > sure that more background threads will solve the underlying problem.
> 
> A single kswapd thread used to keep up with all of the demand you could
> create on a Linux system quite easily provided it didna??t have to scan a lot
> of pages that were ineligible for eviction.

Well, what do you mean by ineligible for eviction? Could you be more
specific? Are we talking about pages on LRU list or metadata and
shrinker based reclaim.

> 10 years ago, Fibre Channel was
> the popular high performance interconnect and if you were lucky enough
> to have the latest hardware rated at 10GFC, you could get 1.2GB/s per host
> bus adapter. Also, most high end storage solutions were still using spinning
> rust so it took an insane number of spindles behind each host bus adapter
> to saturate the channel if the access patterns were random. There really
> wasna??t a reason to try to thread kswapd, and I am pretty sure there hasna??t
> been any attempts to do this in the last 10 years.

I do not really see your point. Yeah you can get a faster storage today.
So what? Pagecache has always been bound by the RAM speed.

> > It is just a matter of memory hogs tunning to end in the very same
> > situtation AFAICS. Moreover the more they are going to allocate the more
> > less CPU time will _other_ (non-allocating) task get.
> 
> Please describe the scenario a bit more clearly. Once you start constructing
> the workload that can create this scenario, I think you will find that you end
> up with a mix that is rarely seen in practice.

What I meant is that the more you reclaim in the background to more you
allow memory hogs to allocate because they will not get throttled. All
that on behalf of other workload which is not memory bound and cannot
use CPU cycles additional kswapd would consume. Think of any computation
intensive workload spreading over most CPUs and a memory hungry data
processing.
-- 
Michal Hocko
SUSE Labs
