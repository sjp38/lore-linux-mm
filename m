Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id AB88E6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 12:53:57 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id c20so127112022pfc.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:53:57 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id i5si4402994pfj.121.2016.04.11.09.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 09:53:56 -0700 (PDT)
Received: by mail-pa0-x22d.google.com with SMTP id bx7so108427138pad.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:53:56 -0700 (PDT)
Message-ID: <1460393634.6473.560.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Apr 2016 09:53:54 -0700
In-Reply-To: <20160411181907.15fdb8b9@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	 <20160407161715.52635cac@redhat.com> <20160411085819.GE21128@suse.de>
	 <20160411142639.1c5e520b@redhat.com>
	 <20160411130826.GB32073@techsingularity.net>
	 <20160411181907.15fdb8b9@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, James Bottomley <James.Bottomley@HansenPartnership.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Tom Herbert <tom@herbertland.com>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>

On Mon, 2016-04-11 at 18:19 +0200, Jesper Dangaard Brouer wrote:

> Drivers also do tricks where they fallback to smaller order pages. E.g.
> lookup function mlx4_alloc_pages().  I've tried to simulate that
> function here:
> https://github.com/netoptimizer/prototype-kernel/blob/91d323fc53/kernel/mm/bench/page_bench01.c#L69

We use order-0 pages on mlx4 at Google, as order-3 pages are very
dangerous for some kind of attacks...

An out of order TCP packet can hold an order-3 pages, while claiming to
use 1.5 KBvia skb->truesize.

order-0 only pages allow the page recycle trick used by Intel driver,
and we hardly see any page allocations in typical workloads.

While order-3 pages are 'nice' for friendly datacenter kind of traffic,
they also are a higher risk on hosts connected to the wild Internet.

Maybe I should upstream this patch ;)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
