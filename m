Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AB10B6B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 13:23:25 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p51HNMb7023856
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 10:23:22 -0700
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by hpaq14.eem.corp.google.com with ESMTP id p51HNHE0027162
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 10:23:20 -0700
Received: by pzk27 with SMTP id 27so12637pzk.13
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 10:23:17 -0700 (PDT)
Date: Wed, 1 Jun 2011 10:23:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
In-Reply-To: <BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com> <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com> <BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 1 Jun 2011, Dmitry Eremin-Solenikov wrote:

> I've hit this with IrDA driver on PXA. Also I've seen the report regarding
> other ARM platform (ep-something). Thus I've included Russell in the cc.
> 

So you want to continue to allow the page allocator to return pages from 
anywhere, even when GFP_DMA is specified, just as though it was lowmem?

Why don't you actually address the problem with the driver you're 
complaining about with the patch below, which I already posted to you a 
few days ago?

If this arm driver is going to be using GFP_DMA unconditionally, it better 
require CONFIG_ZONE_DMA for it to actually be meaningful until such time 
as it can be removed if it's truly not needed or generalized to only 
specific pieces of hardware.
---
 drivers/net/irda/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -374,6 +374,7 @@ config VIA_FIR
 config PXA_FICP
 	tristate "Intel PXA2xx Internal FICP"
 	depends on ARCH_PXA && IRDA
+	select ZONE_DMA
 	help
 	  Say Y or M here if you want to build support for the PXA2xx
 	  built-in IRDA interface which can support both SIR and FIR.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
