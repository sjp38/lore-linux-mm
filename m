Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id E6BA36B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 08:37:02 -0500 (EST)
Received: by wevl61 with SMTP id l61so1508185wev.2
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 05:37:02 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id hj5si46718191wjc.209.2015.02.20.05.37.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 05:37:01 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id x12so13133183wgg.11
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 05:37:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150220091326.GD21248@dhcp22.suse.cz>
References: <20150218104859.GM12722@dastard>
	<20150218121602.GC4478@dhcp22.suse.cz>
	<20150219110124.GC15569@phnom.home.cmpxchg.org>
	<20150219122914.GH28427@dhcp22.suse.cz>
	<20150219125844.GI28427@dhcp22.suse.cz>
	<201502200029.DEG78137.QFVLHFFOJMtOOS@I-love.SAKURA.ne.jp>
	<20150220091326.GD21248@dhcp22.suse.cz>
Date: Fri, 20 Feb 2015 14:37:00 +0100
Message-ID: <CAAxjCEzWJy4+VoJ51A46ioF7NJqumy+RtCRRHnSVN0_1=gi7yQ@mail.gmail.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Stefan Ring <stefanrin@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, dchinner@redhat.com, oleg@redhat.com, Linux fs XFS <xfs@oss.sgi.com>, hannes@cmpxchg.org, linux-mm@kvack.org, mgorman@suse.de, rientjes@google.com, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fernando_b1@lab.ntt.co.jp, torvalds@linux-foundation.org

>> We don't know how many callers will pass __GFP_NOFAIL. But if 1000
>> threads are doing the same operation which requires __GFP_NOFAIL
>> allocation with a lock held, wouldn't memory reserves deplete?
>
> We shouldn't have an unbounded number of GFP_NOFAIL allocations at the
> same time. This would be even more broken. If a load is known to use
> such allocations excessively then the administrator can enlarge the
> memory reserves.
>
>> This heuristic can't continue if memory reserves depleted or
>> continuous pages of requested order cannot be found.
>
> Once memory reserves are depleted we are screwed anyway and we might
> panic.

This discussion reminds me of a situation I've seen somewhat
regularly, which I have described here:
http://oss.sgi.com/pipermail/xfs/2014-April/035793.html

I've actually seen it more often on another box with OpenVZ and
VirtualBox installed, where it would almost always happen during
startup of a VirtualBox guest machine. This other machine is also
running XFS. I blamed it on OpenVZ or VirtualBox originally, but
having seen the same thing happen on the other machine with neither of
them, the next candidate for taking blame is XFS.

Is this behavior something that can be attributed to these memory
allocation retry loops?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
