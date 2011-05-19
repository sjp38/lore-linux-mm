Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A60916B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 14:25:19 -0400 (EDT)
Date: Thu, 19 May 2011 20:25:15 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: atmel-mci causes kernel panic when CONFIG_DEBUG_VM is set
Message-ID: <20110519182515.GC21172@pengutronix.de>
References: <4DD4CC68.80408@atmel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4DD4CC68.80408@atmel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ludovic Desroches <ludovic.desroches@atmel.com>, linux-mm@kvack.org, linux-mmc@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, "Ferre, Nicolas" <Nicolas.FERRE@atmel.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>

Hello,

On Thu, May 19, 2011 at 09:53:12AM +0200, Ludovic Desroches wrote:
> There is a bug with the atmel-mci driver when the debug feature
> CONFIG_DEBUG_VM is set.
for the new audience: the driver does the following:

	flush_dcache_page(sg_page(sg));

with sg being a struct scatterlist * provided by the caller of the
struct mmc_host_ops.request callback.

> Into the atmci_read_data_pio function we use flush_dcache_page (do
> we really need it?) which call the page_mapping function where we
> can find VM_BUG_ON(PageSlab(Page)). Then a kernel panic happens.
> 
> I don't understand the purpose of the VM_BUG_ON(PageSlab(Page)) (the
> page comes from a scatter list). How could I correct this problem?
I discussed this problem with Steven and Peter on irc and Steven found
two functions in the mmc code (mmc_send_cxd_data and mmc_send_bus_test)
that use the following idiom:

	struct scatterlist sg;
	void *data_buf;

	data_buf = kmalloc(len, GFP_KERNEL);

	sg_init_one(&sg, data_buf, len);

Is that allowed (i.e. pass  kmalloc'd memory to sg_init_one)? That might
be the source of the slub page in the scatterlist, no?

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-Konig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
