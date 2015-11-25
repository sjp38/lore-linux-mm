Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1028E6B0253
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 21:57:11 -0500 (EST)
Received: by pacej9 with SMTP id ej9so41814230pac.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 18:57:10 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id 70si30869927pfa.200.2015.11.24.18.57.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 18:57:10 -0800 (PST)
Date: Wed, 25 Nov 2015 11:57:35 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
Message-ID: <20151125025735.GC9563@js1304-P5Q-DELUXE>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.20.1511240934130.20512@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1511240934130.20512@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 24, 2015 at 09:36:09AM -0600, Christoph Lameter wrote:
> On Tue, 24 Nov 2015, Joonsoo Kim wrote:
> 
> > When I tested compaction in low memory condition, I found that
> > my benchmark is stuck in congestion_wait() at shrink_inactive_list().
> > This stuck last for 1 sec and after then it can escape. More investigation
> > shows that it is due to stale vmstat value. vmstat is updated every 1 sec
> > so it is stuck for 1 sec.
> 
> vmstat values are not designed to be accurate and are not guaranteed to be
> accurate. Comparing to specific values should not be done. If you need an
> accurate counter then please use another method of accounting like an
> atomic.

I think that maintaining duplicate counter to guarantee accuracy isn't
reasonable solution. It would cause more overhead to the system.

Although vmstat values aren't designed for accuracy, these are already
used by some sensitive places so it is better to be more accurate.
What this patch does is just adding current cpu's diff to global value
when retrieving in order to get more accurate value and this would not be
expensive. I think that it doesn't break any design principle of vmstat.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
