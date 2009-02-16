Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4D9A36B003D
	for <linux-mm@kvack.org>; Sun, 15 Feb 2009 19:51:58 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1G0puog013698
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 16 Feb 2009 09:51:56 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0AE145DD82
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 09:51:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F66545DD7E
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 09:51:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 69D8FE0800F
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 09:51:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F06DE08007
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 09:51:55 +0900 (JST)
Date: Mon, 16 Feb 2009 09:50:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] clean up for early_pfn_to_nid
Message-Id: <20090216095042.95f4a6d0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090213.221226.264144345.davem@davemloft.net>
References: <20090212161920.deedea35.kamezawa.hiroyu@jp.fujitsu.com>
	<20090212162203.db3f07cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090213142032.09b4a4da.akpm@linux-foundation.org>
	<20090213.221226.264144345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, davem@davemlloft.net, heiko.carstens@de.ibm.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 13 Feb 2009 22:12:26 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Fri, 13 Feb 2009 14:20:32 -0800
> 
> > I queued these as
> > 
> > mm-clean-up-for-early_pfn_to_nid.patch
> > mm-fix-memmap-init-for-handling-memory-hole.patch
> > 
> > and tagged them as needed-in-2.6.28.x.  I don't recall whether they are
> > needed in earlier -stable releases?
> 
> Every kernel going back to at least 2.6.24 has this bug.  It's likely
> been around even longer, I didn't bother checking.
> 

Sparc64's one is broken from this commit.

09337f501ebdd224cd69df6d168a5c4fe75d86fa
sparc64: Kill CONFIG_SPARC32_COMPAT

CONFIG_NODES_SPAN_OTEHR_NODES is set and config allows following kind of NUMA
This is requirements from powerpc.

low address ---<-   max order     ->---- high address
               [Node0][Node1][Node0]
So, nid is checked at memmap init.

But it included this bug in following case.
low address ---<-   max order     ->---- high address
               [Node0][Hole][Node0]

Hmm..I'm not sure how many kind of machines will see this bug. But there may be
some.

[kamezawa@bluextal linux-2.6.28]$ grep  -R CONFIG_NODES_SPAN arch/*
arch/powerpc/configs/celleb_defconfig:CONFIG_NODES_SPAN_OTHER_NODES=y
arch/powerpc/configs/pseries_defconfig:CONFIG_NODES_SPAN_OTHER_NODES=y
arch/powerpc/configs/cell_defconfig:CONFIG_NODES_SPAN_OTHER_NODES=y
arch/sparc64/defconfig:CONFIG_NODES_SPAN_OTHER_NODES=y
arch/x86/configs/x86_64_defconfig:CONFIG_NODES_SPAN_OTHER_NODES=y

powerpc/sparc64/x86 can see this bug.

IMHO, following 2 arch will be safe because..
On x86-64, it seems it doesn't allows above style of memmap. (BUG_ON() will hit)
Powerpc is originator of this CONFIG_NODES_SPAN_OTHER_NODES and they did test.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
