Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6DDF26B005C
	for <linux-mm@kvack.org>; Fri, 15 May 2009 11:20:15 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090515110119.0588e120@binnacle.cx>
Date: Fri, 15 May 2009 11:02:02 -0400
From: starlight@binnacle.cx
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of
  process with hugepage shared memory segments attached
In-Reply-To: <20090515145502.GA9032@csn.ul.ie>
References: <6.2.5.6.2.20090515012125.057a9c88@binnacle.cx>
 <20090515145502.GA9032@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

At 03:55 PM 5/15/2009 +0100, Mel Gorman wrote:
>On Fri, May 15, 2009 at 01:32:38AM -0400, starlight@binnacle.cx 
>wrote:
>> Whacked at a this, attempting to build a testcase from a 
>> combination of the original daemon strace in the bug report
>> and knowledge of what the daemon is doing.
>> 
>> What emerged is something that will destroy RHEL5 
>> 2.6.18-128.1.6.el5 100% every time.  Completely fills the kernel
>> message log with "bad pmd" errors and wrecks hugepages.
>
>Ok, I can confirm that more or less. I reproduced the problem on 
>2.6.18-92.el5 on x86-64 running RHEL 5.2. I didn't have access 
>to a machine with enough memory though so I dropped the 
>requirements slightly. It still triggered a failure though.
>
>However, when I ran 2.6.18, 2.6.19 and 2.6.29.1 on the same 
>machine, I could not reproduce the problem, nor could I cause 
>hugepages to leak so I'm leaning towards believing this is a 
>distribution bug at the moment.
>
>On the plus side, due to your good work, there is enough 
>available for them to bisect this problem hopefully.

Good to hear that the testcase works on other machines.

>> Unfortunately it only occasionally breaks 2.6.29.1.  Haven't
>> been able to produce "bad pmd" messages, but did get the
>> kernel to think it's out of large page memory when in
>> theory it was not.  Saw a lot of really strange accounting
>> in the hugepage section of /proc/meminfo.
>>

>What sort of strange accounting? The accounting has changed 
>since 2.6.18 so I want to be sure you're really seeing something 
>weird. When I was testing, I didn't see anything out of the 
>ordinary but maybe I'm looking in a different place.

Saw things like both free and used set to zero, used set to 2048 
when it should not have been (in association with the failure).  
Often the counters would correct themselves after segments were 
removed with 'ipcs'.  Sometimes not--usually when it broke.  
Also saw some truly insane usage counts like 32520 and less 
egregious off-by-one-or-two inaccuracies.

>> For what it's worth, the testcase code is attached.
>> 
>I cleaned the test up a bit and wrote a wrapper script to run 
>this multiple times while checking for hugepage leaks. I've it 
>running in a loop while the machine runs sysbench as a stress 
>test to see can I cause anything out of the ordinary to happen. 
>Nothing so far though.
>
>> Note that hugepages=2048 is assumed--the bug seems to require 
>> use of more than 50% of large page memory.
>> 
>> Definately will be posted under the RHEL5 bug report, which is 
>> the more pressing issue here than far-future kernel support.
>> 
>If you've filed a RedHat bug, this modified testcase and wrapper 
>script might help them. The program exists and cleans up after 
>itself and the memory requirements are less. The script sets the 
>machine up in a way that breaks for me where the breakage is bad 
>pmd messages and hugepages leaking.

Thank you for your efforts.  Could you post to the RH bug along 
with a back-reference to this?  Might improve the chances 
someone will pay attention to it.  It's at

https://bugzilla.redhat.com/show_bug.cgi?id=497653

In a week or two I'll see if I can make time to turn the 100% 
failure scenario into a testcase.  This is just the run of a
segment loader followed by running a status checker three times. 
In 2.6.29.1 I'm wondering if the "bad pmd" I saw was just a bit 
of bad memory, so might as well focus on the thing that fails 
with certainty.  Possibly the "bad pmd" case requires a few hours 
of live data runtime before it emerges--a tougher nut.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
