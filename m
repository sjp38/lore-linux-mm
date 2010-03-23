Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AF1956B01C2
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 17:19:26 -0400 (EDT)
Received: by bwz19 with SMTP id 19so5617363bwz.6
        for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:19:24 -0700 (PDT)
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge regression in performance
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <20100323111351.756c8752.akpm@linux-foundation.org>
Date: Tue, 23 Mar 2010 22:19:21 +0100
Content-Transfer-Encoding: 7bit
Message-Id: <7FF95EC7-EF76-4321-A7A0-E9018F1B1A90@gmail.com>
References: <bug-15618-10286@https.bugzilla.kernel.org/> <20100323102208.512c16cc.akpm@linux-foundation.org> <20100323173409.GA24845@elte.hu> <20100323111351.756c8752.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Although case is solved, I will post description for testcase program.
Just in case someone wonder or would like to keep it for some later tests.

------------------------------------------------------------------------
It is a parallel model checker. The command line you used does reachability
on the state space of mode anderson.6, meaning that it searches through all
possible states (int vectors). Each thread gets a vector from the queue,
calculates its successor states and puts them in a lock-less static hash
table (pseudo BFS exploration because the threads each have there own
queue).

How did ingo run the binary? Because the static table size should be chosen
to fit into memory. "-s 27" allocates 2^27 * (|vector| + 1 ) * sizeof(int)
bytes. |vector| is equal to 19 for anderson.6, ergo the table size is 10GB.
This could explain the huge number of page faults ingo gets.

But anyway, you can imagine that the code is quiet jumpy and has a big
memory footprint, so the page faults may also be normal.
------------------------------------------------------------------------

On Mar 23, 2010, at 7:13 PM, Andrew Morton wrote:

> Anton, we have an executable binary in the bugzilla report but it would
> be nice to also have at least a description of what that code is
> actually doing.  A quick strace shows quite a lot of mprotect activity.
> A pseudo-code walkthrough, perhaps?
> 
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
