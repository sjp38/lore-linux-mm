Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 41E276B0180
	for <linux-mm@kvack.org>; Thu, 14 May 2009 04:20:16 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4E8KXoZ013082
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 May 2009 17:20:33 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 62AA645DE52
	for <linux-mm@kvack.org>; Thu, 14 May 2009 17:20:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4030C45DE4F
	for <linux-mm@kvack.org>; Thu, 14 May 2009 17:20:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 28500E08001
	for <linux-mm@kvack.org>; Thu, 14 May 2009 17:20:33 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E5F8E08002
	for <linux-mm@kvack.org>; Thu, 14 May 2009 17:20:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <4A0ADD88.9080705@redhat.com>
References: <20090513120729.5885.A69D9226@jp.fujitsu.com> <4A0ADD88.9080705@redhat.com>
Message-Id: <20090514170721.9B75.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 May 2009 17:20:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

(cc to Robin)

> KOSAKI Motohiro wrote:
> > Subject: [PATCH] zone_reclaim_mode is always 0 by default
> > 
> > Current linux policy is, if the machine has large remote node distance,
> >  zone_reclaim_mode is enabled by default because we've be able to assume to 
> > large distance mean large server until recently.
> > 
> > Unfrotunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
> > memory controller. IOW it's NUMA from software view.
> > 
> > Some Core i7 machine has large remote node distance and zone_reclaim don't
> > fit desktop and small file server. it cause performance degression.
> > 
> > Thus, zone_reclaim == 0 is better by default. sorry, HPC gusy. 
> > you need to turn zone_reclaim_mode on manually now.
> 
> I'll believe that it causes a performance regression with the
> old zone_reclaim behaviour, however the way you tweaked
> zone_reclaim should make it behave a lot better, no?

Unfortunately no.
zone reclaim has two weakness by design.

1.
zone reclaim don't works well when workingset size > local node size.
but it can happen easily on small machine.
if it happen, zone reclaim drop own process's memory.

Plus, zone reclaim also doesn't fit DB server. its process has large
workingset.


2.
zone reclaim have inter zone balancing issue.

example: x86_64 2node 8G machine has following zone assignment

   zone 0 (DMA32):  3GB
   zone 0 (Normal): 1GB
   zone 1 (Normal): 4GB

if the page is allocated from DMA32, you are lucky. DMA32 isn't reclaimed
so freqently. but if from zone0 Normal, you are unlucky.
it is very frequent reclaimed although it is small than other zone.


I know my patch change large server default. but I believe linux
default kernel parameter adapt to desktop and entry machine.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
