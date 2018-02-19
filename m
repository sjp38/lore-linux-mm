Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E88BE6B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 08:10:29 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c188so708065wma.7
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 05:10:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w190si6253270wmd.61.2018.02.19.05.10.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 05:10:28 -0800 (PST)
Date: Mon, 19 Feb 2018 13:10:24 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/1] mm, compaction: correct the bounds of
 __fragmentation_index()
Message-ID: <20180219131024.oqonm6ba3pl2l4qa@suse.de>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
 <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
 <20180219094735.g4sm4kxawjnojgyd@suse.de>
 <CB73A16F-5B32-4681-86E3-00786C67ADEF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CB73A16F-5B32-4681-86E3-00786C67ADEF@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Harris <robert.m.harris@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>

On Mon, Feb 19, 2018 at 12:26:39PM +0000, Robert Harris wrote:
> 
> 
> > On 19 Feb 2018, at 09:47, Mel Gorman <mgorman@suse.de> wrote:
> > 
> > On Sun, Feb 18, 2018 at 04:47:55PM +0000, robert.m.harris@oracle.com wrote:
> >> From: "Robert M. Harris" <robert.m.harris@oracle.com>
> >> 
> >> __fragmentation_index() calculates a value used to determine whether
> >> compaction should be favoured over page reclaim in the event of allocation
> >> failure.  The calculation itself is opaque and, on inspection, does not
> >> match its existing description.  The function purports to return a value
> >> between 0 and 1000, representing units of 1/1000.  Barring the case of a
> >> pathological shortfall of memory, the lower bound is instead 500.  This is
> >> significant because it is the default value of sysctl_extfrag_threshold,
> >> i.e. the value below which compaction should be avoided in favour of page
> >> reclaim for costly pages.
> >> 
> >> This patch implements and documents a modified version of the original
> >> expression that returns a value in the range 0 <= index < 1000.  It amends
> >> the default value of sysctl_extfrag_threshold to preserve the existing
> >> behaviour.
> >> 
> >> Signed-off-by: Robert M. Harris <robert.m.harris@oracle.com>
> > 
> > You have to update sysctl_extfrag_threshold as well for the new bounds.
> 
> This patch makes its default value zero.
> 

Sorry, I'm clearly blind.

> > It effectively makes it a no-op but it was a no-op already and adjusting
> > that default should be supported by data indicating it's safe.
> 
> Would it be acceptable to demonstrate using tracing that in both the
> pre- and post-patch cases
> 
>   1. compaction is attempted regardless of fragmentation index,
>      excepting that
> 
>   2. reclaim is preferred even for non-zero fragmentation during
>      an extreme shortage of memory
> 

If you can demonstrate that for both reclaim-intensive and
compaction-intensive workloads then yes. Also include the reclaim and
compaction stats from /proc/vmstat and not just tracepoints to demonstrate
that reclaim doesn't get out of control and reclaim the world in
response to failed high-order allocations such as THP.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
