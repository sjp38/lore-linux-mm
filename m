Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9A7D76B0071
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 07:06:56 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o68B6sIw029217
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 8 Jul 2010 20:06:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AAFA45DE57
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 20:06:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 22CC845DE56
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 20:06:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CB4441DB8043
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 20:06:53 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DE0F1DB805A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 20:06:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: FYI: mmap_sem OOM patch
In-Reply-To: <1278586921.1900.67.camel@laptop>
References: <20100708195421.CD48.A69D9226@jp.fujitsu.com> <1278586921.1900.67.camel@laptop>
Message-Id: <20100708200324.CD4B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu,  8 Jul 2010 20:06:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> On Thu, 2010-07-08 at 19:57 +0900, KOSAKI Motohiro wrote:
> > > On Thu, 2010-07-08 at 03:39 -0700, Michel Lespinasse wrote:
> > > > 
> > > > 
> > > >         One way to fix this is to have T4 wake from the oom queue and return an
> > > >         allocation failure instead of insisting on going oom itself when T1
> > > >         decides to take down the task.
> > > > 
> > > > How would you have T4 figure out the deadlock situation ? T1 is taking down T2, not T4... 
> > > 
> > > If T2 and T4 share a mmap_sem they belong to the same process. OOM takes
> > > down the whole process by sending around signals of sorts (SIGKILL?), so
> > > if T4 gets a fatal signal while it is waiting to enter the oom thingy,
> > > have it abort and return an allocation failure.
> > > 
> > > That alloc failure (along with a pending fatal signal) will very likely
> > > lead to the release of its mmap_sem (if not, there's more things to
> > > cure).
> > > 
> > > At which point the cycle is broken an stuff continues as it was
> > > intended.
> > 
> > Now, I've reread current code. I think mmotm already have this.
> 
> <snip code>
> 
> [ small note on that we really should kill __GFP_NOFAIL, its utter
> deadlock potential ]

I disagree. __GFP_NOFAIL mean this allocation failure can makes really
dangerous result. Instead, OOM-Killer should try to kill next process.
I think.

> > Thought?
> 
> So either its not working or google never tried that code?

Michel?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
