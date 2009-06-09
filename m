Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A1CFF6B005D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 03:55:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n598OCUM029472
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Jun 2009 17:24:12 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D3AF945DD78
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:24:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AF39445DD7E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:24:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CF9A1DB803E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:24:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EFE8A1DB8046
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:24:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] vmscan: handle may_swap more strictly (Re: [PATCH  mmotm] vmscan: fix may_swap handling for memcg)
In-Reply-To: <28c262360906090119r6e881caq9b74028ba43567a7@mail.gmail.com>
References: <20090609164850.DD73.A69D9226@jp.fujitsu.com> <28c262360906090119r6e881caq9b74028ba43567a7@mail.gmail.com>
Message-Id: <20090609172035.DD7C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Jun 2009 17:24:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Jun 9, 2009 at 4:58 PM, KOSAKI
> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> >> Hi, KOSAKI.
> >>
> >> As you know, this problem caused by if condition(priority) in shrink_zone.
> >> Let me have a question.
> >>
> >> Why do we have to prevent scan value calculation when the priority is zero ?
> >> As I know, before split-lru, we didn't do it.
> >>
> >> Is there any specific issue in case of the priority is zero ?
> >
> > Yes.
> >
> > example:
> >
> > get_scan_ratio() return anon:80%, file=20%. and the system have
> > 10000 anon pages and 10000 file pages.
> >
> > shrink_zone() picked up 8000 anon pages and 2000 file pages.
> > it mean 8000 file pages aren't scanned at all.
> >
> > Oops, it can makes OOM-killer although system have droppable file cache.
> >
> Hmm..Can that problem be happen in real system ?
> The file ratio is big means that file lru list scanning is so big but
> rotate is small.
> It means file lru have few reclaimable page.
> 
> Isn't it ? I am confusing.
> Could you elaborate, please if you don't mind ?

hm, ok, my example was wrong.
I intention is, if there are droppable file-back pages (althout only 1 page), 
OOM-killer shouldn't occuer.

many or few is unrelated.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
