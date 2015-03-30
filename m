Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id AC8F16B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 08:02:17 -0400 (EDT)
Received: by obbps3 with SMTP id ps3so6198033obb.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 05:02:17 -0700 (PDT)
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com. [209.85.218.52])
        by mx.google.com with ESMTPS id z134si6010480oig.26.2015.03.30.05.02.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 05:02:16 -0700 (PDT)
Received: by oigz129 with SMTP id z129so81284691oig.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 05:02:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150329102440.GC32047@worktop.ger.corp.intel.com>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
	<20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
	<CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
	<20150327091613.GE27490@worktop.programming.kicks-ass.net>
	<20150327093023.GA32047@worktop.ger.corp.intel.com>
	<CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
	<20150328095322.GH27490@worktop.programming.kicks-ass.net>
	<55169723.3070006@linaro.org>
	<20150328134457.GK27490@worktop.programming.kicks-ass.net>
	<20150329102440.GC32047@worktop.ger.corp.intel.com>
Date: Mon, 30 Mar 2015 17:32:16 +0530
Message-ID: <CAKohpon2GSpk+6pNuHEsDC55hHtowwfGJivPM0Gh0wt1A2cd-w@mail.gmail.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On 29 March 2015 at 15:54, Peter Zijlstra <peterz@infradead.org> wrote:
> On Sat, Mar 28, 2015 at 02:44:57PM +0100, Peter Zijlstra wrote:
>> > Now there are few issues I see here (Sorry if they are all imaginary):
>> > - In case a timer re-arms itself from its handler and is migrated from CPU A to B, what
>> >   happens if the re-armed timer fires before the first handler finishes ? i.e. timer->fn()
>> >   hasn't finished running on CPU A and it has fired again on CPU B. Wouldn't this expose
>> >   us to a lot of other problems? It wouldn't be serialized to itself anymore ?
>>
>> What I said above.
>
> What I didn't say, but had thought of is that __run_timer() should skip
> any timer that has RUNNING set -- for obvious reasons :-)

Below is copied from your first reply, and so you probably already
said that ? :)

> Also, once you have tbase_running, we can take base->running_timer out
> altogether.

I wanted to clarify if I understood it correctly..

Are you saying that:

Case 1.) if we find tbase_running on cpuY (because it was rearmed
from its handler on cpuX and has got migrated to cpuY), then we should drop the
timer from the list without calling its handler (as that is already
running in parallel) ?

Or

Case 2.) we keep retrying for it, until the time the other handler finishes?


I have few queries for both the cases.

Case 1.) Will that be fair to the timer user as the timer may get lost
completely.
If we skip the timer on cpuY here, it wouldn't be enqueued again and
so will be lost.

Case 2.) We kept waiting for the first handler to finish ..
- cpuY may waste some cycles as it kept waiting for handler to finish on cpuX ..
- We may need to perform base unlock/lock on cpuY, so that cpuX can take cpuY's
lock to reset tbase_running. And that might be racy, not sure.

--
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
