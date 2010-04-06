Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC3D6B0208
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 17:48:10 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o36Lm4Bw030293
	for <linux-mm@kvack.org>; Tue, 6 Apr 2010 23:48:05 +0200
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by wpaz9.hot.corp.google.com with ESMTP id o36Llqr3000715
	for <linux-mm@kvack.org>; Tue, 6 Apr 2010 14:48:03 -0700
Received: by pzk9 with SMTP id 9so385660pzk.19
        for <linux-mm@kvack.org>; Tue, 06 Apr 2010 14:48:03 -0700 (PDT)
Date: Tue, 6 Apr 2010 14:47:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <20100406201645.7E69.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
References: <20100405154923.23228529.akpm@linux-foundation.org> <alpine.DEB.2.00.1004051552400.27040@chino.kir.corp.google.com> <20100406201645.7E69.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 2010, KOSAKI Motohiro wrote:

> Many people reviewed these patches, but following four patches got no ack.
> 
> oom-badness-heuristic-rewrite.patch

Do you have any specific feedback that you could offer on why you decided 
to nack this?

> oom-default-to-killing-current-for-pagefault-ooms.patch

Same, what is the specific concern that you have with this patch?

If you don't believe we should kill current first, could you please submit 
patches for all other architectures like powerpc that already do this as 
their only course of action for VM_FAULT_OOM and then make pagefault oom 
killing consistent amongst architectures?

> oom-deprecate-oom_adj-tunable.patch

Alan had a concern about removing /proc/pid/oom_adj, or redefining it with 
different semantics as I originally did, and then I updated the patchset 
to deprecate the old tunable as Andrew suggested.

My somewhat arbitrary time of removal was approximately 18 months from 
the date of deprecation which would give us 5-6 major kernel releases in 
between.  If you think that's too early of a deadline, then I'd happily 
extend it by 6 months or a year.

Keeping /proc/pid/oom_adj around indefinitely isn't very helpful if 
there's a finer grained alternative available already unless you want 
/proc/pid/oom_adj to actually mean something in which case you'll never be 
able to seperate oom badness scores from bitshifts.  I believe everyone 
agrees that a more understood and finer grained tunable is necessary as 
compared to the current implementation that has very limited functionality 
other than polarizing tasks.

> oom-replace-sysctls-with-quick-mode.patch
> 
> IIRC, alan and nick and I NAKed such patch. everybody explained the reason.

Which patch of the four you listed are you referring to here?

> We don't hope join loudly voice contest nor help to making flame. but it
> doesn't mean explicit ack.
> 

If someone has a concern with a patch and then I reply to it and the reply 
goes unanswered, what exactly does that imply?  Do we want to stop 
development because discussion occurred on a patch yet no rebuttal was 
made that addressed specific points that I raised?

Arguing to keep /proc/pid/oom_kill_allocating_task means that we should 
also not enable /proc/pid/oom_dump_tasks by default since the same systems 
that use the former will need to now disable the latter to avoid costly 
tasklist scans.  So are you suggesting that we should not enable 
oom_dump_tasks like the rewrite does even though it provides very useful 
information to 99.9% (or perhaps 100%) of users to understand the memory 
usage of their tasks because you believe systems out there would flake out 
with the tasklist scan it requires, even though you can't cite a single 
example?

Now instead of not replying to these questions and insisting that your 
nack stand based solely on the fact that you nacked it, please get 
involved in the development process.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
