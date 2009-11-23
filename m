Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B24746B006A
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 03:48:47 -0500 (EST)
Subject: Re: [MM] Make mm counters per cpu instead of atomic
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <alpine.DEB.1.10.0911171223460.20360@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
	 <1258440521.11321.32.camel@localhost> <1258443101.11321.33.camel@localhost>
	 <1258450465.11321.36.camel@localhost>
	 <alpine.DEB.1.10.0911171223460.20360@V090114053VZO-1>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 23 Nov 2009 16:51:10 +0800
Message-Id: <1258966270.29789.45.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-11-17 at 12:25 -0500, Christoph Lameter wrote:
> On Tue, 17 Nov 2009, Zhang, Yanmin wrote:
> 
> > The right change above should be:
> >  struct mm_counter *m = per_cpu_ptr(mm->rss, cpu);
> 
> Right.
> 
> > With the change, command 'make oldconfig' and a boot command still
> > hangs.
> 
> Not sure if its worth spending more time on this but if you want I will
> consolidate the fixes so far and put out another patchset.
> 
> Where does it hang during boot?
Definitely faint.

1) In function exec_mmap: in the 2nd 'if (old_mm) {', mm_reader_unlock
should be used. Your patch uses mm_reader_lock. I found it when reviewing your
patch, but forgot to fix it when testing.
2) In function madvise: the last unlock should be mm_reader_unlock. Your
patch uses mm_writer_unlock.

It's easy to hit the issues with normal testing. I'm surprised you didn't
hit them.

Another theoretic issue is below scenario:
Process A get the read lock on cpu 0 and is scheduled to cpu 2 to unlock. Then
it's scheduled back to cpu 0 to repeat the step. eventually, the reader counter
will overflow. Considering multiple thread cases, it might be faster to
overflow than what we imagine. When it overflows, processes will hang there.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
