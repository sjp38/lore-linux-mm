Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C20AC6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 01:21:15 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAA6LD9k010601
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Nov 2009 15:21:13 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E482345DE50
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 15:21:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C4F4445DE4F
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 15:21:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AB0961DB803E
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 15:21:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 618981DB803F
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 15:21:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu counter instead
In-Reply-To: <alpine.DEB.1.10.0911061249170.5187@V090114053VZO-1>
References: <20091106174439.GB819@basil.fritz.box> <alpine.DEB.1.10.0911061249170.5187@V090114053VZO-1>
Message-Id: <20091110151145.3615.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Nov 2009 15:21:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

> On Fri, 6 Nov 2009, Andi Kleen wrote:
> 
> > On Fri, Nov 06, 2009 at 12:08:54PM -0500, Christoph Lameter wrote:
> > > On Fri, 6 Nov 2009, Andi Kleen wrote:
> > >
> > > > Yes but all the major calls still take mmap_sem, which is not ranged.
> > >
> > > But exactly that issue is addressed by this patch!
> >
> > Major calls = mmap, brk, etc.
> 
> Those are rare. More frequently are for faults, get_user_pages and
> the like operations that are frequent.
> 
> brk depends on process wide settings and has to be
> serialized using a processor wide locks.
> 
> mmap and other address space local modification may be able to avoid
> taking mmap write lock by taking the read lock and then locking the
> ptls in the page struct relevant to the address space being modified.
> 
> This is also enabled by this patchset.

Andi, Why do you ignore fork? fork() hold mmap_sem write-side lock and
it is one of critical path.
Ah yes, I know HPC workload doesn't call fork() so frequently, I mean
typical desktop and small server case.

I agree with cristoph halfly. if the issue is only in mmap, it isn't
so important.

Probably, I haven't catch your mention.


Plus, most critical mmap_sem issue is not locking cost itself. In stree workload,
the procss grabbing mmap_sem frequently sleep. and fair rw-semaphoe logic
frequently prevent reader side locking.
At least, this improvement doesn't help google like workload.

Thanks.


> > Only for page faults, not for anything that takes it for write.
> >
> > Anyways the better reader lock is a step in the right direction, but
> > I have my doubts it's a good idea to make write really slow here.
> 
> The bigger the system the larger the problems with mmap. This is one key
> scaling issue important for the VM. We can work on that. I have a patch
> here that restricts the per cpu checks to only those cpus on which the
> process has at some times run before.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
