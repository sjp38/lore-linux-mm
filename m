Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 601106B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 05:51:30 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i131so11379108wma.1
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:51:30 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id k54si488612edd.18.2017.09.26.02.51.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 02:51:29 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 94378F4013
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:51:28 +0000 (UTC)
Date: Tue, 26 Sep 2017 10:51:27 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 0/2] Use HighAtomic against long-term fragmentation
Message-ID: <20170926095127.p5ocg44et2g62gku@techsingularity.net>
References: <1506415604-4310-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1506415604-4310-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, teawater@gmail.com

On Tue, Sep 26, 2017 at 04:46:42PM +0800, Hui Zhu wrote:
> Current HighAtomic just to handle the high atomic page alloc.
> But I found that use it handle the normal unmovable continuous page
> alloc will help to against long-term fragmentation.
> 

This is not wise. High-order atomic allocations do not always have a
smooth recovery path such as network drivers with large MTUs that have no
choice but to drop the traffic and hope for a retransmit. That's why they
have the highatomic reserve. If the reserve is used for normal unmovable
allocations then allocation requests that could have waited for reclaim
may cause high-order atomic allocations to fail. Changing it may allow
improve latencies in some limited cases while causing functional failures
in others.  If there is a special case where there are a large number of
other high-order allocations then I would suggest increasing min_free_kbytes
instead as a workaround.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
