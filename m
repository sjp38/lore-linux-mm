Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6746B0254
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 10:55:01 -0500 (EST)
Received: by wmvv187 with SMTP id v187so62322221wmv.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 07:55:00 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hy2si9565502wjb.141.2015.11.11.07.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 07:55:00 -0800 (PST)
Date: Wed, 11 Nov 2015 10:54:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
Message-ID: <20151111155446.GA24431@cmpxchg.org>
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Nov 11, 2015 at 02:48:17PM +0100, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __GFP_NOFAIL is a big hammer used to ensure that the allocation
> request can never fail. This is a strong requirement and as such
> it also deserves a special treatment when the system is OOM. The
> primary problem here is that the allocation request might have
> come with some locks held and the oom victim might be blocked
> on the same locks. This is basically an OOM deadlock situation.
> 
> This patch tries to reduce the risk of such a deadlocks by giving
> __GFP_NOFAIL allocations a special treatment and let them dive into
> memory reserves after oom killer invocation. This should help them
> to make a progress and release resources they are holding. The OOM
> victim should compensate for the reserves consumption.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> this has been posted previously as a part of larger GFP_NOFS related
> patch set (http://lkml.kernel.org/r/1438768284-30927-1-git-send-email-mhocko%40kernel.org)
> but Andrea was asking basically the same thing at LSF early this year
> (I cannot seem to find it in any public archive though). I think the
> patch makes some sense on its own.

I sent this right after LSF based on Andrea's suggestion:

https://lkml.org/lkml/2015/3/25/37

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
