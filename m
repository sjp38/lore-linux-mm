Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6B73E6B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 03:30:58 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n597wcOj026848
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Jun 2009 16:58:39 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AA4A45DE50
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:58:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 54FBF45DE4F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:58:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B01241DB804B
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:58:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E96DA1DB8043
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:58:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] vmscan: handle may_swap more strictly (Re: [PATCH  mmotm] vmscan: fix may_swap handling for memcg)
In-Reply-To: <28c262360906090048x792fb3f9i6678298b693f6c5a@mail.gmail.com>
References: <20090609161925.DD70.A69D9226@jp.fujitsu.com> <28c262360906090048x792fb3f9i6678298b693f6c5a@mail.gmail.com>
Message-Id: <20090609164850.DD73.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Jun 2009 16:58:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> Hi, KOSAKI.
> 
> As you know, this problem caused by if condition(priority) in shrink_zone.
> Let me have a question.
> 
> Why do we have to prevent scan value calculation when the priority is zero ?
> As I know, before split-lru, we didn't do it.
> 
> Is there any specific issue in case of the priority is zero ?

Yes. 

example:

get_scan_ratio() return anon:80%, file=20%. and the system have
10000 anon pages and 10000 file pages.

shrink_zone() picked up 8000 anon pages and 2000 file pages.
it mean 8000 file pages aren't scanned at all.

Oops, it can makes OOM-killer although system have droppable file cache.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
