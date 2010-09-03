Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C10986B0047
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 22:38:03 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o832c0ex023837
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 3 Sep 2010 11:38:00 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8011A45DE51
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 11:38:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 57F2945DE4F
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 11:38:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 368681DB8044
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 11:38:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D9167E38001
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 11:37:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Add trace points to mmap, munmap, and brk
In-Reply-To: <20100902134827.GA6957@mgebm.net>
References: <20100727201644.2F46.A69D9226@jp.fujitsu.com> <20100902134827.GA6957@mgebm.net>
Message-Id: <20100903112920.B65F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  3 Sep 2010 11:37:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 27 Jul 2010, KOSAKI Motohiro wrote:
> 
> > > On Wed, 21 Jul 2010, KOSAKI Motohiro wrote:
> > > 
> > > > > This patch adds trace points to mmap, munmap, and brk that will report
> > > > > relevant addresses and sizes before each function exits successfully.
> > > > > 
> > > > > Signed-off-by: Eric B Munson <emunson@mgebm.net>
> > > > 
> > > > I don't think this is good idea. if you need syscall result, you should 
> > > > use syscall tracer. IOW, This tracepoint bring zero information.
> > > > 
> > > > Please see perf_event_mmap() usage. Our kernel manage adress space by
> > > > vm_area_struct. we need to trace it if we need to know what kernel does.
> > > > 
> > > > Thanks.
> > > 
> > > The syscall tracer does not give you the address and size of the mmaped areas
> > > so this does provide information above simply tracing the enter/exit points
> > > for each call.
> > 
> > Why don't you fix this?
> > 
> > 
> 
> Sorry for the long delay, 

no problem.

> the enter/exit routines are not compatible with the
> information that these new trace points provides.  When tracing mmap, for
> instance, the addr and len arguments can be altered by the function.  If you
> use the enter/exit trace points you would not see this as the arguments are
> sampled at function entrance and not given again on exit.  

Current output is here. It has rich output than yours. Also you can bind enter and exit output by pid.


            less-2130  [001]  3779.915324: sys_mmap(addr: 0, len: 1000, prot: 3, flags: 22, fd: ffffffff, off: 0)
            less-2130  [001]  3779.915331: sys_mmap -> 0x7fee22b17000
            less-2130  [001]  3779.915350: sys_mmap(addr: 38e8c00000, len: 3788a8, prot: 5, flags: 802, fd: 3, off: 0)
            less-2130  [001]  3779.915357: sys_mmap -> 0x38e8c00000
            less-2130  [001]  3779.915368: sys_mmap(addr: 38e8f6f000, len: 5000, prot: 3, flags: 812, fd: 3, off: 16f000)
            less-2130  [001]  3779.915380: sys_mmap -> 0x38e8f6f000
            less-2130  [001]  3779.915411: sys_mmap(addr: 38e8f74000, len: 48a8, prot: 3, flags: 32, fd: ffffffff, off: 0)
            less-2130  [001]  3779.915421: sys_mmap -> 0x38e8f74000
            less-2130  [001]  3779.915464: sys_mmap(addr: 0, len: 1000, prot: 3, flags: 22, fd: ffffffff, off: 0)
            less-2130  [001]  3779.915468: sys_mmap -> 0x7fee22b16000


> Also, the new
> trace points are only hit on function success, the exit trace point happens
> any time you leave the system call.

Special purpose filtering is no good design. That makes narrowing the feature usefulness.
It should be done on userland.



> I will send out a new series after a rebase.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
