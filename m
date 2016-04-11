Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5116B025E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 15:47:45 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id f105so130192788qge.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 12:47:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y201si21545113qka.90.2016.04.11.12.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 12:47:44 -0700 (PDT)
Date: Mon, 11 Apr 2016 21:47:37 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Message-ID: <20160411214737.215c8e66@redhat.com>
In-Reply-To: <1460393634.6473.560.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160411085819.GE21128@suse.de>
	<20160411142639.1c5e520b@redhat.com>
	<20160411130826.GB32073@techsingularity.net>
	<20160411181907.15fdb8b9@redhat.com>
	<1460393634.6473.560.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: lsf@lists.linux-foundation.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Tom Herbert <tom@herbertland.com>, lsf-pc@lists.linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, brouer@redhat.com, Alexander Duyck <alexander.duyck@gmail.com>, "Waskiewicz, PJ" <PJ.Waskiewicz@netapp.com>

On Mon, 11 Apr 2016 09:53:54 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2016-04-11 at 18:19 +0200, Jesper Dangaard Brouer wrote:
> 
> > Drivers also do tricks where they fallback to smaller order pages. E.g.
> > lookup function mlx4_alloc_pages().  I've tried to simulate that
> > function here:
> > https://github.com/netoptimizer/prototype-kernel/blob/91d323fc53/kernel/mm/bench/page_bench01.c#L69  
> 
> We use order-0 pages on mlx4 at Google, as order-3 pages are very
> dangerous for some kind of attacks...

Interesting!

> An out of order TCP packet can hold an order-3 pages, while claiming to
> use 1.5 KBvia skb->truesize.
> 
> order-0 only pages allow the page recycle trick used by Intel driver,
> and we hardly see any page allocations in typical workloads.

Yes, I looked at the Intel ixgbe drivers page recycle trick. 

It is actually quite cool, but code wise it is a little hard to
follow.  I started to look at the variant in i40e, specifically
function i40e_clean_rx_irq_ps() explains it a bit more explicit.
 

> While order-3 pages are 'nice' for friendly datacenter kind of
> traffic, they also are a higher risk on hosts connected to the wild
> Internet.
> 
> Maybe I should upstream this patch ;)

Definitely!

Does this patch also include a page recycle trick?  Else how do you get
around the cost of allocating a single order-0 page?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
