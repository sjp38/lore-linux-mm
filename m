Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7DBA26B0071
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 11:11:21 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0TGBI03023670
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 30 Jan 2010 01:11:18 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4422F45DE4F
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:11:18 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A17445DE4E
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:11:18 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 11CFFE08001
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:11:18 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C29D61DB8038
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:11:17 +0900 (JST)
Message-ID: <f8c9aca9c98db8ae7df3ac2d7ac8d922.squirrel@webmail-b.css.fujitsu.com>
Date: Sat, 30 Jan 2010 01:11:17 +0900 (JST)
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: vedran.furac@gmail.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
>> off by default. Problem is that it breaks java and some other stuff that
>> allocates much more memory than it needs. Very quickly Committed_AS hits
>> CommitLimit and one cannot allocate any more while there is plenty of
>> memory still unused.
>
> So how about you go and have a complain at the people who are causing
> your problem, rather than the kernel.
>
Alan, please allow me to talk about my concern.

At first, I think all OOM-killer are bad and there are no chance
to implement innocent, good OOM-Killer. The best way we can do is
"never cause OOM-Kill". But we're human being, OOM-Killer can happen
by _mistake_....

For example, a customer runs 1000+ process of Oracle without using
HugeTLB and the total size of page table goes up to 10GByes. Hahaha.
(Of course, We asked him  to use Hugetlb ;) We can't ask him to
 use overcommit memory if much proprietaty applications runs on it.)

So, I believe there is a cirtial situation OOM-Killer has to run even
if it's bad. Even in corner case.
Now, in OOM situaion, sshd or X-server or some task launcher is killed at
first if oom_adj is not tweaked. IIUC, OOM-Killer is for giving a chance
to administrator to recover his system, safe reboot. But if sshd/X is
kiiled, this is no help.

My first purpose was to prevent killing some daemons or task launchers.
The first patch was nacked ;).

On that way, I tried to add lowmem counting because it was also
my concern. This was nacked ;(

I stop this because of my personal reason. For my enviroment,
panic_on_oom=1 works enough well.For Vedran's, overcommit memory will work
well. But oom-killer kills very bad process if not tweaked.
So, I think some improvement should be done.

And we have memcg even if it's called as ugly workaround.
Sorry for all the noise.

Bye,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
