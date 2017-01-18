Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25D2F6B0261
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:46:17 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id ez4so1471767wjd.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:46:17 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id l190si1765062wmb.49.2017.01.18.01.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 01:46:16 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 9AD761C151A
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 09:46:15 +0000 (GMT)
Date: Wed, 18 Jan 2017 09:46:15 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 2/4] mm, page_alloc: fix fast-path race with cpuset update
 or removal
Message-ID: <20170118094615.eif2xez65hpmvdnr@techsingularity.net>
References: <20170117221610.22505-1-vbabka@suse.cz>
 <20170117221610.22505-3-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170117221610.22505-3-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ganapatrao Kulkarni <gpkulkarni@gmail.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 17, 2017 at 11:16:08PM +0100, Vlastimil Babka wrote:
> Ganapatrao Kulkarni reported that the LTP test cpuset01 in stress mode triggers
> OOM killer in few seconds, despite lots of free memory. The test attemps to
> repeatedly fault in memory in one process in a cpuset, while changing allowed
> nodes of the cpuset between 0 and 1 in another process.
> 
> One possible cause is that in the fast path we find the preferred zoneref
> according to current mems_allowed, so that it points to the middle of the
> zonelist, skipping e.g. zones of node 1 completely. If the mems_allowed is
> updated to contain only node 1, we never reach it in the zonelist, and trigger
> OOM before checking the cpuset_mems_cookie.
> 
> This patch fixes the particular case by redoing the preferred zoneref search
> if we switch back to the original nodemask. The condition is also slightly
> changed so that when the last non-root cpuset is removed, we don't miss it.
> 
> Note that this is not a full fix, and more patches will follow.
> 
> Reported-by: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
> Fixes: 682a3385e773 ("mm, page_alloc: inline the fast path of the zonelist iterator")
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
