Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF9136B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:08:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r126so2087167wmr.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 02:08:55 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id c48si28517077wra.290.2017.01.18.02.08.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 02:08:54 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 4FBF7990D5
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:08:54 +0000 (UTC)
Date: Wed, 18 Jan 2017 10:08:53 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 4/4] mm, page_alloc: fix premature OOM when racing with
 cpuset mems update
Message-ID: <20170118100853.gop3iia4sq5xk3t2@techsingularity.net>
References: <20170117221610.22505-1-vbabka@suse.cz>
 <20170117221610.22505-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170117221610.22505-5-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ganapatrao Kulkarni <gpkulkarni@gmail.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 17, 2017 at 11:16:10PM +0100, Vlastimil Babka wrote:
> Ganapatrao Kulkarni reported that the LTP test cpuset01 in stress mode triggers
> OOM killer in few seconds, despite lots of free memory. The test attemps to
> repeatedly fault in memory in one process in a cpuset, while changing allowed
> nodes of the cpuset between 0 and 1 in another process.
> 
> The problem comes from insufficient protection against cpuset changes, which
> can cause get_page_from_freelist() to consider all zones as non-eligible due to
> nodemask and/or current->mems_allowed. This was masked in the past by
> sufficient retries, but since commit 682a3385e773 ("mm, page_alloc: inline the
> fast path of the zonelist iterator") we fix the preferred_zoneref once, and
> don't iterate the whole zonelist in further attempts.
> 
> A previous patch fixed this problem for current->mems_allowed. However, cpuset
> changes also update the policy nodemasks. The fix has two parts. We have to
> repeat the preferred_zoneref search when we detect cpuset update by way of
> seqcount, and we have to check the seqcount before considering OOM.
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
