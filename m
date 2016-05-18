Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D808C6B025E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 12:34:40 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d62so114170724iof.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 09:34:40 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0085.outbound.protection.outlook.com. [157.55.234.85])
        by mx.google.com with ESMTPS id r9si3776034otd.249.2016.05.18.09.34.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 May 2016 09:34:40 -0700 (PDT)
Subject: Re: [PATCH v12 04/13] task_isolation: add initial support
References: <1459877922-15512-1-git-send-email-cmetcalf@mellanox.com>
 <1459877922-15512-5-git-send-email-cmetcalf@mellanox.com>
 <20160518133420.GG3193@twins.programming.kicks-ass.net>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <8e8b24ec-abc6-e599-ad50-218e350213ce@mellanox.com>
Date: Wed, 18 May 2016 12:34:22 -0400
MIME-Version: 1.0
In-Reply-To: <20160518133420.GG3193@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Gilad Ben Yossef <giladb@ezchip.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On 5/18/2016 9:34 AM, Peter Zijlstra wrote:
> On Tue, Apr 05, 2016 at 01:38:33PM -0400, Chris Metcalf wrote:
>> diff --git a/kernel/signal.c b/kernel/signal.c
>> index aa9bf00749c1..53e4e62f2778 100644
>> --- a/kernel/signal.c
>> +++ b/kernel/signal.c
>> @@ -34,6 +34,7 @@
>>   #include <linux/compat.h>
>>   #include <linux/cn_proc.h>
>>   #include <linux/compiler.h>
>> +#include <linux/isolation.h>
>>   
>>   #define CREATE_TRACE_POINTS
>>   #include <trace/events/signal.h>
>> @@ -2213,6 +2214,9 @@ relock:
>>   		/* Trace actually delivered signals. */
>>   		trace_signal_deliver(signr, &ksig->info, ka);
>>   
>> +		/* Disable task isolation when delivering a signal. */
> Why !? Changelog is quiet on this.

There are really two reasons.

1. If the task is receiving a signal, it will know it's not isolated
    any more, so we don't need to worry about notifying it explicitly.
    This behavior is easy to document and allows the application to decide
    if the signal is unexpected and it should go straight to its error
    handling path (likely outcome, and in that case you want task isolation
    off anyway) or if it thinks it can plausibly re-enable isolation and
    return to where the signal interrupted you at (hard to imagine how this
    would ever make sense, but you could if you wanted to).

2. When we are delivering a signal we may already be holding the lock
    for the signal subsystem, and it gets hard to figure out whether it's
    safe to send another signal to the application as a "task isolation
    broken" notification.  For example, sending a signal to a task on
    another core involves doing an IPI to that core to kick it; the IPI
    normally is a generic point for notifying the remote core of broken
    task isolation and sending a signal - except that at the point where
    we would do that on the signal path we are already holding the lock,
    so we end up deadlocked.  We could no doubt work around that, but it
    seemed cleaner to decouple the existing signal mechanism from the
    signal delivery for task isolation.

I will add more discussion of the rationale to the commit message.

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
