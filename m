Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 640096B00C7
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 19:56:49 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n87Nut5R019069
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Sep 2009 08:56:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E62A45DD74
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 08:56:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4245A1F7042
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 08:56:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BC6A3E18001
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 08:56:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 645D91DB8041
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 08:56:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <1252321596.7959.6.camel@laptop>
References: <1252311463.7586.26.camel@marge.simson.net> <1252321596.7959.6.camel@laptop>
Message-Id: <20090908085344.0CBD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Sep 2009 08:56:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kosaki.motohiro@jp.fujitsu.com, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Peter,

> On Mon, 2009-09-07 at 10:17 +0200, Mike Galbraith wrote:
> 
> > [  774.651779] SysRq : Show Blocked State
> > [  774.655770]   task                        PC stack   pid father
> > [  774.655770] evolution.bin D ffff8800bc1575f0     0  7349   6459 0x00000000
> > [  774.676008]  ffff8800bc3c9d68 0000000000000086 ffff8800015d9340 ffff8800bb91b780
> > [  774.676008]  000000000000dd28 ffff8800bc3c9fd8 0000000000013340 0000000000013340
> > [  774.676008]  00000000000000fd ffff8800015d9340 ffff8800bc1575f0 ffff8800bc157888
> > [  774.676008] Call Trace:
> > [  774.676008]  [<ffffffff812c4a11>] schedule_timeout+0x2d/0x20c
> > [  774.676008]  [<ffffffff812c4891>] wait_for_common+0xde/0x155
> > [  774.676008]  [<ffffffff8103f1cd>] ? default_wake_function+0x0/0x14
> > [  774.676008]  [<ffffffff810c0e63>] ? lru_add_drain_per_cpu+0x0/0x10
> > [  774.676008]  [<ffffffff810c0e63>] ? lru_add_drain_per_cpu+0x0/0x10
> > [  774.676008]  [<ffffffff812c49ab>] wait_for_completion+0x1d/0x1f
> > [  774.676008]  [<ffffffff8105fdf5>] flush_work+0x7f/0x93
> > [  774.676008]  [<ffffffff8105f870>] ? wq_barrier_func+0x0/0x14
> > [  774.676008]  [<ffffffff81060109>] schedule_on_each_cpu+0xb4/0xed
> > [  774.676008]  [<ffffffff810c0c78>] lru_add_drain_all+0x15/0x17
> > [  774.676008]  [<ffffffff810d1dbd>] sys_mlock+0x2e/0xde
> > [  774.676008]  [<ffffffff8100bc1b>] system_call_fastpath+0x16/0x1b
> 
> FWIW, something like the below (prone to explode since its utterly
> untested) should (mostly) fix that one case. Something similar needs to
> be done for pretty much all machine wide workqueue thingies, possibly
> also flush_workqueue().

Can you please explain reproduce way and problem detail?

AFAIK, mlock() call lru_add_drain_all() _before_ grab semaphoe. Then,
it doesn't cause any deadlock.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
