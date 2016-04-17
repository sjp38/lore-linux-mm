Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 729666B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 09:24:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so49733940wmw.2
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 06:24:06 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id v68si21860945wmd.42.2016.04.17.06.24.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Apr 2016 06:24:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 705711DC110
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 13:24:03 +0000 (UTC)
Date: Sun, 17 Apr 2016 14:23:57 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: FlameGraph of mlx4 early drop with order-0 pages
Message-ID: <20160417132357.GB11792@techsingularity.net>
References: <20160415214034.6ffae9ee@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160415214034.6ffae9ee@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, tom@herbertland.com, alexei.starovoitov@gmail.com, ogerlitz@mellanox.com, daniel@iogearbox.net, eric.dumazet@gmail.com, ecree@solarflare.com, john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net, eranlinuxmellanox@gmail.com

On Fri, Apr 15, 2016 at 09:40:34PM +0200, Jesper Dangaard Brouer wrote:
> Hi Mel,
> 
> I did an experiment that you might find interesting.  Using Brenden's
> early drop with eBPF in the mxl4 driver.  I changed the mlx4 driver to
> use order-0 pages.  It usually use order-3 pages to amortize the cost
> of calling the page allocator (which is problematic for other reasons,
> like memory pin-down, latency spikes and multi CPU scalability)
> 
> With this change I could do around 12Mpps (Mill packet per sec) drops,
> usually does 14.5Mpps (limited due to a HW setup/limit, with idle cycles). 
> 
> Looking at the perf report as a FlameGraph, the page allocator clearly
> show up as the bottleneck: 
> 

Yeah, it's very obvious there. You didn't say if this had the optimisations
included or not but it doesn't really matter. Even halving the cost would
still be a lot.

FWIW, the latest series included an optimisation around the debugging
check. I also have an extreme patch that creates a special fast path for
order-0 pages only when there is plenty of free memory. It halved the
cost of the allocation side even on top of the current optimisations. I'm
not super-happy with it though as it duplicates some code and it requires
node-lru to be merged. Right now, node-lru is colliding very badly with
what's in mmotm so there is legwork required.

I also prototyped something that caches high-order pages on the per-cpu
lists on the flight over. It is at the "it builds so it must be ok"
stage. It's at the horrible hack and the accounting is quesionable but
something like it may be justified for SLUB even if network drivers move
away from high-order pages.

> Signing off, heading for the plane soon... see you at MM-summit!

Indeed and we'll slap some sort of plan together. If there is a slot free,
we might spend 15-30 minutes on it. Failing that, we'll grab a table
somewhere. We'll see how far we can get before considering a page-recycle
layer that preserves cache coherent state.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
