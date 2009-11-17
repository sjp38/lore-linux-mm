Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 464F16B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 06:58:08 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAHBw5is018518
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 20:58:06 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BE75645DE6E
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 20:58:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CBFE45DE60
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 20:58:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 611851DB803A
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 20:58:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 07A51E18001
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 20:58:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/7] mmc: Don't use PF_MEMALLOC
In-Reply-To: <20091117102903.7cb45ff3@lxorguk.ukuu.org.uk>
References: <20091117161711.3DDA.A69D9226@jp.fujitsu.com> <20091117102903.7cb45ff3@lxorguk.ukuu.org.uk>
Message-Id: <20091117200618.3DFF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 20:58:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mmc@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Tue, 17 Nov 2009 16:17:50 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
> > memory, anyone must not prevent it. Otherwise the system cause
> > mysterious hang-up and/or OOM Killer invokation.
> 
> So now what happens if we are paging and all our memory is tied up for
> writeback to a device or CIFS etc which can no longer allocate the memory
> to complete the write out so the MM can reclaim ?

Probably my answer is not so simple. sorry.

reason1: MM reclaim does both dropping clean memory and writing out dirty pages.
reason2: if all memory is exhausted, maybe we can't recover it. it is
fundamental limitation of Virtual Memory subsystem. and, min-watermark is
decided by number of system physcal memory, but # of I/O issue (i.e. # of
pages of used by writeback thread) is mainly decided # of devices. 
then, we can't gurantee min-watermark is sufficient on any systems.
Only reasonable solution is mempool like reservation, I think.
IOW, any reservation memory shouldn't share unrelated subsystem. otherwise
we lost any gurantee.

So, I think we need to hear why many developer don't use mempool,
instead use PF_MEMALLOC.

> Am I missing something or is this patch set not addressing the case where
> the writeback thread needs to inherit PF_MEMALLOC somehow (at least for
> the I/O in question and those blocking it)

Yes, probably my patchset isn't perfect. honestly I haven't understand
why so many developer prefer to use PF_MEMALLOC.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
