Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0168A6008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 02:30:08 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o736Zc54031400
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 3 Aug 2010 15:35:38 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F80845DE7A
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 15:35:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1773545DE6F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 15:35:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E7D781DB8042
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 15:35:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AFDA1DB803F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 15:35:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Bug 12309 - Large I/O operations result in poor interactive performance and high iowait times
In-Reply-To: <20100802115748.GA5308@localhost>
References: <20100802171954.4F95.A69D9226@jp.fujitsu.com> <20100802115748.GA5308@localhost>
Message-Id: <20100803153420.39FD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  3 Aug 2010 15:35:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Clayton <andrew@digital-domain.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "pvz@pvz.pp.se" <pvz@pvz.pp.se>, "bgamari@gmail.com" <bgamari@gmail.com>, "larppaxyz@gmail.com" <larppaxyz@gmail.com>, "seanj@xyke.com" <seanj@xyke.com>, "kernel-bugs.dev1world@spamgourmet.com" <kernel-bugs.dev1world@spamgourmet.com>, "akatopaz@gmail.com" <akatopaz@gmail.com>, "frankrq2009@gmx.com" <frankrq2009@gmx.com>, "thomas.pi@arcor.de" <thomas.pi@arcor.de>, "spawels13@gmail.com" <spawels13@gmail.com>, "vshader@gmail.com" <vshader@gmail.com>, "rockorequin@hotmail.com" <rockorequin@hotmail.com>, "ylalym@gmail.com" <ylalym@gmail.com>, "theholyettlz@googlemail.com" <theholyettlz@googlemail.com>, "hassium@yandex.ru" <hassium@yandex.ru>
List-ID: <linux-mm.kvack.org>

> > It mean congestion ignorerance is happend when followings
> >   (1) the task is kswapd
> >   (2) the task is flusher thread
> >   (3) this reclaim is called from zone reclaim (note: I'm thinking this is bug)
> >   (4) this reclaim is called from __generic_file_aio_write()
> > 
> > (4) is root cause of this latency issue. this behavior was introduced
> > by following.
> 
> Yes and no.
> 
> (1)-(4) are good summaries for regular files. However !bdi_write_congested(bdi)
> is now unconditionally true for the swapper_space, which means any process can
> do swap out to a congested queue and block there.

Oops. I missed that. thanks correct me!




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
