Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0A56005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 23:48:55 -0500 (EST)
Date: Mon, 4 Jan 2010 20:48:23 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
Message-ID: <alpine.LFD.2.00.1001042038110.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>  <20100104182813.753545361@chello.nl>  <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Tue, 5 Jan 2010, Minchan Kim wrote:
> 
> Isn't it protected by get_file and iget?

When the vma is mapped, yes.

> Am I miss something?

remove_vma() will have done a

	fput(vma->vm_file);

and other house-keeping (removing the executable info, doing 
vm_ops->close() etc). 

And that is _not_ done delayed by RCU, and as outlined in my previous 
email I think that if the code really _does_ delay it, then munmap() (and 
exit) need to wait for the RCU callbacks to have been done, because 
otherwise the file may end up being busy "asynchronously" in ways that 
break existing semantics.

Just as an example: imagine a script that does "fork()+execve()" on a 
temporary file, and then after waiting for it all to finish with wait4() 
does some re-write of the file. It currently works. But what if the 
open-for-writing gets ETXTBUSY because the file is still marked as being 
VM_DENYWRITE, and RCU hasn't done all the callbacks?

Or if you do the i_writecount handling synchronously (which is likely fine 
- it really is just for ETXTBUSY handling, and I don't think speculative 
page faults matter), what about a shutdown sequence (or whatever) that 
wants to unmount the filesystem, but the file is still open - as it has to 
be - because the actual close is delayed by RCU.

So the patch-series as-is is fundamentally buggy - and trying to fix it 
seems painful.

I'm also not entirely clear on how the race with page table tear-down vs 
page-fault got handled, but I didn't read the whole patch-series very 
carefully. I skimmed through it and got rather nervous about it all. It 
doesn't seem too large, but it _does_ seem rather cavalier about all the 
object lifetimes.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
