Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CB1E86B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 00:55:57 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAI5ttSk029170
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 18 Nov 2009 14:55:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 89B0B45DE4E
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 14:55:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E2B145DE4C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 14:55:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 577791DB8037
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 14:55:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 079B71DB8042
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 14:55:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] Kill PF_MEMALLOC abuse
In-Reply-To: <1258491379.3918.48.camel@laptop>
References: <20091117172802.3DF4.A69D9226@jp.fujitsu.com> <1258491379.3918.48.camel@laptop>
Message-Id: <20091118144418.3E17.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 18 Nov 2009 14:55:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 2009-11-17 at 17:33 +0900, KOSAKI Motohiro wrote:
> > 
> > if there is so such reason. we might need to implement another MM trick.
> > but keeping this strage usage is not a option. All memory freeing activity
> > (e.g. page out, task killing) need some memory. we need to protect its
> > emergency memory. otherwise linux reliability decrease dramatically when
> > the system face to memory stress. 
> 
> In general PF_MEMALLOC is a particularly bad idea, even for the VM when
> not coupled with limiting the consumption. That is one should make an
> upper-bound estimation of the memory needed for a writeout-path per
> page, and reserve a small multiple thereof, and limit the number of
> pages written out so as to never exceed this estimate.
> 
> If the current mempool interface isn't sufficient (not hard to imagine),
> look at the swap over NFS patch-set, that includes a much more able
> reservation scheme, and accounting framework.

Yes, I agree.

In this discussion, some people explained why their subsystem need
emergency memory, but nobody claim sharing memory pool against VM and
surely want to stop reclaim (PF_MEMALLOC's big side effect).

OK. I try to review your patch carefully and remake this patch series on top
your reservation framework in swap-over-nfs patch series.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
