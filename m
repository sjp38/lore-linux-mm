Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D30E66B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:05:42 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f23so18864732pgn.15
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 12:05:42 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id s11si6430551plj.782.2017.08.15.12.05.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 12:05:41 -0700 (PDT)
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <20170815022743.GB28715@tassilo.jf.intel.com>
 <CA+55aFyHVV=eTtAocUrNLymQOCj55qkF58+N+Tjr2YS9TrqFow@mail.gmail.com>
 <20170815031524.GC28715@tassilo.jf.intel.com>
 <CA+55aFw1A1C8qUeKPUzACrsqn97UDxTP3M2SRs80aEztfU=Qbg@mail.gmail.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <0b7b6132-a374-9636-53f9-c2e1dcec230f@linux.intel.com>
Date: Tue, 15 Aug 2017 12:05:40 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFw1A1C8qUeKPUzACrsqn97UDxTP3M2SRs80aEztfU=Qbg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 08/14/2017 08:28 PM, Linus Torvalds wrote:
> On Mon, Aug 14, 2017 at 8:15 PM, Andi Kleen <ak@linux.intel.com> wrote:
>> But what should we do when some other (non page) wait queue runs into the
>> same problem?
> 
> Hopefully the same: root-cause it.
> 
> Once you have a test-case, it should generally be fairly simple to do
> with profiles, just seeing who the caller is when ttwu() (or whatever
> it is that ends up being the most noticeable part of the wakeup chain)
> shows up very heavily.

We have a test case but it is a customer workload.  We'll try to get
a bit more info.

> 
> And I think that ends up being true whether the "break up long chains"
> patch goes in or not. Even if we end up allowing interrupts in the
> middle, a long wait-queue is a problem.
> 
> I think the "break up long chains" thing may be the right thing
> against actual malicious attacks, but not for any actual real
> benchmark or load.

This is a concern from our customer as we could trigger the watchdog timer
by running user space workloads.  

> 
> I don't think we normally have cases of long wait-queues, though. At
> least not the kinds that cause problems. The real (and valid)
> thundering herd cases should already be using exclusive waiters that
> only wake up one process at a time.
> 
> The page bit-waiting is hopefully special. As mentioned, we used to
> have some _really_ special code for it for other reasons, and I
> suspect you see this problem with them because we over-simplified it
> from being a per-zone dynamically sized one (where the per-zone thing
> caused both performance problems and actual bugs) to being that
> "static small array".
> 
> So I think/hope that just re-introducing some dynamic sizing will help
> sufficiently, and that this really is an odd and unusual case.

I agree that dynamic sizing makes a lot of sense.  We'll check to
see if additional size to the hash table helps, assuming that the
waiters are distributed among different pages for our test case.  

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
