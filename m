Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECE536B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 03:56:37 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id x84so17422226oix.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 00:56:37 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id h125si14714101wme.3.2017.01.11.00.56.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Jan 2017 00:56:37 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 20C9C98E4F
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:56:36 +0000 (UTC)
Date: Wed, 11 Jan 2017 08:56:35 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [patch v2] mm, thp: add new defer+madvise defrag option
Message-ID: <20170111085635.vnou5j537lhqyaam@techsingularity.net>
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
 <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
 <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
 <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
 <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz>
 <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com>
 <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz>
 <alpine.DEB.2.10.1701091818340.61862@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1701101614330.41805@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1701101614330.41805@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 10, 2017 at 04:15:27PM -0800, David Rientjes wrote:
> There is no thp defrag option that currently allows MADV_HUGEPAGE regions 
> to do direct compaction and reclaim while all other thp allocations simply 
> trigger kswapd and kcompactd in the background and fail immediately.
> 
> The "defer" setting simply triggers background reclaim and compaction for 
> all regions, regardless of MADV_HUGEPAGE, which makes it unusable for our 
> userspace where MADV_HUGEPAGE is being used to indicate the application is 
> willing to wait for work for thp memory to be available.
> 
> The "madvise" setting will do direct compaction and reclaim for these
> MADV_HUGEPAGE regions, but does not trigger kswapd and kcompactd in the 
> background for anybody else.
> 
> For reasonable usage, there needs to be a mesh between the two options.  
> This patch introduces a fifth mode, "defer+madvise", that will do direct 
> reclaim and compaction for MADV_HUGEPAGE regions and trigger background 
> reclaim and compaction for everybody else so that hugepages may be 
> available in the near future.
> 
> A proposal to allow direct reclaim and compaction for MADV_HUGEPAGE 
> regions as part of the "defer" mode, making it a very powerful setting and 
> avoids breaking userspace, was offered: 
> http://marc.info/?t=148236612700003.  This additional mode is a 
> compromise.
> 
> A second proposal to allow both "defer" and "madvise" to be selected at
> the same time was also offered: http://marc.info/?t=148357345300001.
> This is possible, but there was a concern that it might break existing
> userspaces the parse the output of the defrag mode, so the fifth option
> was introduced instead.
> 
> This patch also cleans up the helper function for storing to "enabled" 
> and "defrag" since the former supports three modes while the latter 
> supports five and triple_flag_store() was getting unnecessarily messy.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  v2: uses new naming suggested by Vlastimil
>      (defer+madvise order looks better in
>       "... defer defer+madvise madvise ...")
> 
>  v1 was acked by Mel, and it probably could have been preserved but it was
>  removed in case there is an issue with the name change.
> 

There isn't

Acked-by: Mel Gorman <mgorman@techsingularity.net>

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
