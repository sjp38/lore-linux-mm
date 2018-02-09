Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 852EE6B0006
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 09:44:24 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id l2so4251904vki.18
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 06:44:24 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z185si847230vkf.110.2018.02.09.06.44.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 06:44:23 -0800 (PST)
Subject: Re: [Resend] Possible bug in __fragmentation_index()
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
From: Robert Harris <robert.m.harris@oracle.com>
In-Reply-To: <20180202174721.f63gume3klxevkbj@suse.de>
Date: Fri, 9 Feb 2018 14:43:50 +0000
Content-Transfer-Encoding: 7bit
Message-Id: <AA7930B9-1E4D-400C-89EA-FC2FC6A7E1E4@oracle.com>
References: <83AECC32-77A4-427D-9043-DE6FC48AD3FC@oracle.com> <20180202174721.f63gume3klxevkbj@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Kemi Wang <kemi.wang@intel.com>, ying.huang@intel.com, David Rientjes <rientjes@google.com>, Vinayak Menon <vinmenon@codeaurora.org>


On 2 Feb 2018, at 17:47, Mel Gorman wrote:

> On Fri, Feb 02, 2018 at 02:16:39PM +0000, Robert Harris wrote:
>> I was planning to annotate the opaque calculation in
>> __fragmentation_index() but on closer inspection I think there may be a
>> bug.  I could use some feedback.

A belated thank you for the reply.

> It's intentional but could be fixed to give a real bound of 0 to 1 instead
> of half the range as it currently give. The sysctl_extfrag_threshold should
> also be adjusted at that time. After that, the real work is determining
> if it's safe to strike a balance between reclaim/compaction that avoids
> unnecessary compaction while not being too aggressive about reclaim or
> having kswapd enter a runaway loop with a reintroduction of the "kswapd
> stuck at 100% CPU time" problems.

In my (incomplete) view, striking the balance is a case of determining the
cost of memory regeneration through compaction versus reclaim and choosing
the cheaper.  I'm reasonably confident that this could be achieved for
compaction, which is why the calculation in __fragmentation_index() caught
my eye in the first place, but reclaim/swapping is probably significantly
harder to quantify.  Similarly, a cost function for allocation failure
is also necessary but not obvious.

All of the above is just a nebulous plan for now;  in the meantime, I'll
change __fragmentation_index() and the threshold as you suggest.

Robert  Harris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
