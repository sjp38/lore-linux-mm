Date: Wed, 23 Apr 2003 09:57:29 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.68-mm2
Message-ID: <1509100000.1051117049@flay>
In-Reply-To: <1051116646.2756.2.camel@localhost>
References: <20030423012046.0535e4fd.akpm@digeo.com> <20030423095926.GJ8931@holomorphy.com> <1051116646.2756.2.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>, William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> rml and I coordinated to put together a small patch (combining both
>> our own) for properly locking the static variables in out_of_memory().
>> There's not any evidence things are going wrong here now, but it at
>> least addresses the visible lack of locking in out_of_memory().
> 
> Thank you for posting this, wli.
> 
>> -	first = now;
>> +	/*
>> +	 * We dropped the lock above, so check to be sure the variable
>> +	 * first only ever increases to prevent false OOM's.
>> +	 */
>> +	if (time_after(now, first))
>> +		first = now;
> 
> Just thinking... this little bit is actually a bug even on UP sans
> kernel preemption, too, since oom_kill() can sleep.  If it sleeps, and
> another process enters out_of_memory(), 'now' and 'first' will be out of
> sync.
> 
> So I think this patch is a Good Thing in more ways than the obvious SMP
> or kernel preemption issue.

Is this the bug that akpm was seeing, or a different one? The only 
information I've seen (indirectly) is that fsx triggers the oops.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
