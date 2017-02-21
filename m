Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BEB4E6B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 23:10:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 1so120397459pgz.5
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 20:10:40 -0800 (PST)
Received: from out0-156.mail.aliyun.com (out0-156.mail.aliyun.com. [140.205.0.156])
        by mx.google.com with ESMTP id q4si4227142plb.147.2017.02.20.20.10.39
        for <linux-mm@kvack.org>;
        Mon, 20 Feb 2017 20:10:39 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170215092247.15989-1-mgorman@techsingularity.net> <20170215092247.15989-4-mgorman@techsingularity.net> <001501d2881d$242aa790$6c7ff6b0$@alibaba-inc.com> <20170216081039.ukbxl2b4khnwwbic@techsingularity.net> <001f01d2882d$9dd14850$d973d8f0$@alibaba-inc.com> <d4e3317b-5ae8-f61c-4d71-5a74a4014cc7@suse.cz>
In-Reply-To: <d4e3317b-5ae8-f61c-4d71-5a74a4014cc7@suse.cz>
Subject: Re: [PATCH 3/3] mm, vmscan: Prevent kswapd sleeping prematurely due to mismatched classzone_idx
Date: Tue, 21 Feb 2017 12:10:34 +0800
Message-ID: <012701d28bf8$7380d920$5a828b60$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, 'Mel Gorman' <mgorman@techsingularity.net>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Shantanu Goel' <sgoel01@yahoo.com>, 'Chris Mason' <clm@fb.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'LKML' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On February 21, 2017 12:34 AM Vlastimil Babka wrote:
> On 02/16/2017 09:21 AM, Hillf Danton wrote:
> > Right, but the order-3 request can also come up while kswapd is active and
> > gives up order-5.
> 
> "Giving up on order-5" means it will set sc.order to 0, go to sleep (assuming
> order-0 watermarks are OK) and wakeup kcompactd for order-5. There's no way how
> kswapd could help an order-3 allocation at that point - it's up to kcompactd.
> 
	cpu0				cpu1
	give up order-5 
	fall back to order-0
					wake up kswapd for order-3 
					wake up kswapd for order-5
	fall in sleep
					wake up kswapd for order-3
	what order would
	we try?

It is order-5 in the patch. 

Given the fresh new world without hike ban after napping, 
one tenth second or 3 minutes, we feel free IMHO to select
any order and go another round of reclaiming pages.

thanks
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
