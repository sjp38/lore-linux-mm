Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C1D7C6B000D
	for <linux-mm@kvack.org>; Mon, 28 May 2018 11:42:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x203-v6so3249782wmg.8
        for <linux-mm@kvack.org>; Mon, 28 May 2018 08:42:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t49-v6si6389572edb.202.2018.05.28.08.42.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 08:42:17 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: do not break __GFP_THISNODE by zonelist
 reset
References: <20180525130853.13915-1-vbabka@suse.cz>
 <20180525124300.964a1a15d953e8972625bb0f@linux-foundation.org>
 <20180528072143.GB1517@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e97d2e81-652b-2762-44c8-303dfaf5333b@suse.cz>
Date: Mon, 28 May 2018 12:00:58 +0200
MIME-Version: 1.0
In-Reply-To: <20180528072143.GB1517@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

On 05/28/2018 09:21 AM, Michal Hocko wrote:
> On Fri 25-05-18 12:43:00, Andrew Morton wrote:
>> On Fri, 25 May 2018 15:08:53 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>>> we might consider this for 4.17 although I don't know if there's anything
>>> currently broken. Stable backports should be more important, but will have to
>>> be reviewed carefully, as the code went through many changes.
>>> BTW I think that also the ac->preferred_zoneref reset is currently useless if
>>> we don't also reset ac->nodemask from a mempolicy to NULL first (which we
>>> probably should for the OOM victims etc?), but I would leave that for a
>>> separate patch.
>>
>> Confused.  If nothing is currently broken then why is a backport
>> needed?  Presumably because we expect breakage in the future?  Can you
>> expand on this?
> 
> __GFP_THISNODE is documented to _use_ the given node. Allocating from a
> different one is a bug. Maybe the current code can cope with that or at
> least doesn't blow up in an obvious way but the bug is still there.
> 
> I am still not sure what to do about the zonelist reset. It still seems
> like an echo from the past

Hmm actually it seems that even at the time of commit 183f6371aac2
introduced the reset, the per-policy zonelists for MPOL_BIND policies
were gone for years. Mempolicy only affects which node's zonelist is
used, but that always contains all the nodes (unless __GFP_THISNODE) so
there's no reason to get another node's zonelist to escape mempolicy
restrictions.

Mempolicy restrictions are given as nodemask, so if we want to ignore
them for OOM victims etc, we have to reset nodemask instead. But again
we have to be careful in case the nodemask doesn't come from mempolicy,
but from somebody who might be broken if we ignore it.

> but using numa_node_id for __GFP_THISNODE is
> a clear bug because our task could have been migrated to a cpu on a
> different than requested node.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
