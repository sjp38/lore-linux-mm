Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E8D786B008A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 21:13:06 -0500 (EST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp [192.51.44.36])
	by fgwmail8.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBE2D4j4013593
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 14 Dec 2010 11:13:04 +0900
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBE2D1u7018034
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 14 Dec 2010 11:13:01 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 02D0B45DE58
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 11:13:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 891AE45DE55
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 11:13:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DA02E08004
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 11:13:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AB031DB803C
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 11:13:00 +0900 (JST)
Date: Tue, 14 Dec 2010 11:07:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
Message-Id: <20101214110711.af70b5b0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101213153105.GA2344@barrios-desktop>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com>
	<20101208170504.1750.A69D9226@jp.fujitsu.com>
	<AANLkTikG1EAMm8yPvBVUXjFz1Bu9m+vfwH3TRPDzS9mq@mail.gmail.com>
	<87oc8wa063.fsf@gmail.com>
	<AANLkTin642NFLMubtCQhSVUNLzfdk5ajz-RWe2zT+Lw6@mail.gmail.com>
	<20101213153105.GA2344@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Ben Gamari <bgamari.foss@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 2010 00:31:05 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Test Environment :
> DRAM : 2G, CPU : Intel(R) Core(TM)2 CPU
> Rsync backup directory size : 16G
> 
> rsync version is 3.0.7.
> rsync patch is Ben's fadivse.
> stress scenario do following jobs with parallel.
> 
> 1. make all -j4 linux, git clone linux-kernel
> 2. git clone linux-kernel
> 3. rsync src dst
> 
> nrns : no-patched rsync + no stress
> prns : patched rsync + no stress
> nrs  : no-patched rsync + stress
> prs  : patched rsync + stress
> 
> pginvalidate : the number of dirty/writeback pages which is invalidated by fadvise
> pgreclaim : pages moved PG_reclaim trick in inactive's tail
> 
> In summary, my patch enhances a littie bit about elapsed time in
> memory pressure environment and enhance reclaim effectivness(reclaim/reclaim)
> with x2. It means reclaim latency is short and doesn't evict working set
> pages due to invalidated pages.
> 
> Look at reclaim effectivness. Patched rsync enhances x2 about reclaim
> effectiveness and compared to mmotm-12-03, mmotm-12-03-fadvise enhances
> 3 minute about elapsed time in stress environment. 
> I think it's due to reduce scanning, reclaim overhead.
> 
> In no-stress enviroment, fadivse makes program little bit slow.
> I think because there are many pgfault. I don't know why it happens.
> Could you guess why it happens?
> 
> Before futher work, I hope listen opinions.
> Any comment is welcome.
> 

At first, the improvement seems great. Thank you for your effort.

> In no-stress enviroment, fadivse makes program little bit slow.
> I think because there are many pgfault. I don't know why it happens.
> Could you guess why it happens?
>

Are there no program which accesses a directory rsync'ed ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
