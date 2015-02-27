Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id A63D16B006E
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 17:19:47 -0500 (EST)
Received: by wesk11 with SMTP id k11so22955101wes.11
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:19:47 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cv7si9701084wjc.104.2015.02.27.14.19.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 14:19:46 -0800 (PST)
Message-ID: <54F0ED7E.6010900@suse.cz>
Date: Fri, 27 Feb 2015 23:19:42 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch 1/2] mm: remove GFP_THISNODE
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <54EED9A7.5010505@suse.cz> <alpine.DEB.2.10.1502261902580.24302@chino.kir.corp.google.com> <54F01E02.1090007@suse.cz> <alpine.DEB.2.10.1502271335520.4718@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1502271335520.4718@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, dev@openvswitch.org

On 02/27/2015 11:03 PM, David Rientjes wrote:
>> With both
>> patches they won't bail out and __GFP_NO_KSWAPD will prevent most of the stuff
>> described above, including clearing ALLOC_CPUSET.
> 
> Yeah, ALLOC_CPUSET is never cleared for thp allocations because atomic == 
> false for thp, regardless of this series.
> 
>> But __cpuset_node_allowed()
>> will allow it to allocate anywhere anyway thanks to the newly passed
>> __GFP_THISNODE, which would be a regression of what b104a35d32 fixed... unless
>> I'm missing something else that prevents it, which wouldn't surprise me at all.
>> 
>> There's this outdated comment:
>> 
>>  * The __GFP_THISNODE placement logic is really handled elsewhere,
>>  * by forcibly using a zonelist starting at a specified node, and by
>>  * (in get_page_from_freelist()) refusing to consider the zones for
>>  * any node on the zonelist except the first.  By the time any such
>>  * calls get to this routine, we should just shut up and say 'yes'.
>> 
>> AFAIK the __GFP_THISNODE zonelist contains *only* zones from the single node and
>> there's no other "refusing".
> 
> Yes, __cpuset_node_allowed() is never called for a zone from any other 
> node when __GFP_THISNODE is passed because of node_zonelist().  It's 
> pointless to iterate over those zones since the allocation wants to fail 
> instead of allocate on them.
> 
> Do you see any issues with either patch 1/2 or patch 2/2 besides the 
> s/GFP_TRANSHUGE/GFP_THISNODE/ that is necessary on the changelog?

Well, my point is, what if the node we are explicitly trying to allocate
hugepage on, is in fact not allowed by our cpuset? This could happen in the page
fault case, no? Although in a weird configuration when process can (and really
gets scheduled to run) on a node where it is not allowed to allocate from...

>> And I don't really see why __GFP_THISNODE should
>> have this exception, it feels to me like "well we shouldn't reach this but we
>> are not sure, so let's play it safe". So maybe we could just remove this
>> exception? I don't think any other user of __GFP_THISNODE | __GFP_WAIT user
>> relies on this allowed memset violation?
>> 
> 
> Since this function was written, there were other callers to 
> cpuset_{node,zone}_allowed_{soft,hard}wall() that may have required it.  I 
> looked at all the current callers of cpuset_zone_allowed() and they don't 
> appear to need this "exception" (slub calls node_zonelist() itself for the 
> iteration and slab never calls it for __GFP_THISNODE).  So, yeah, I think 
> it can be removed.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
