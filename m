Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAE926B000E
	for <linux-mm@kvack.org>; Mon, 28 May 2018 11:53:51 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z5-v6so7564681pfz.6
        for <linux-mm@kvack.org>; Mon, 28 May 2018 08:53:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r8-v6si12297916plj.40.2018.05.28.08.53.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 08:53:50 -0700 (PDT)
Date: Mon, 28 May 2018 09:21:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, page_alloc: do not break __GFP_THISNODE by zonelist
 reset
Message-ID: <20180528072143.GB1517@dhcp22.suse.cz>
References: <20180525130853.13915-1-vbabka@suse.cz>
 <20180525124300.964a1a15d953e8972625bb0f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180525124300.964a1a15d953e8972625bb0f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

On Fri 25-05-18 12:43:00, Andrew Morton wrote:
> On Fri, 25 May 2018 15:08:53 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
> > we might consider this for 4.17 although I don't know if there's anything
> > currently broken. Stable backports should be more important, but will have to
> > be reviewed carefully, as the code went through many changes.
> > BTW I think that also the ac->preferred_zoneref reset is currently useless if
> > we don't also reset ac->nodemask from a mempolicy to NULL first (which we
> > probably should for the OOM victims etc?), but I would leave that for a
> > separate patch.
> 
> Confused.  If nothing is currently broken then why is a backport
> needed?  Presumably because we expect breakage in the future?  Can you
> expand on this?

__GFP_THISNODE is documented to _use_ the given node. Allocating from a
different one is a bug. Maybe the current code can cope with that or at
least doesn't blow up in an obvious way but the bug is still there.

I am still not sure what to do about the zonelist reset. It still seems
like an echo from the past but using numa_node_id for __GFP_THISNODE is
a clear bug because our task could have been migrated to a cpu on a
different than requested node.

Acked-by: Michal Hocko <mhocko@suse.com>

-- 
Michal Hocko
SUSE Labs
