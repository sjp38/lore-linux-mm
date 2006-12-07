Date: Thu, 7 Dec 2006 03:19:03 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC][PATCH] Allow Cpuset nodesets to expand under pressure
Message-Id: <20061207031903.e62971f7.pj@sgi.com>
In-Reply-To: <20061207024436.2b24d418.pj@sgi.com>
References: <20061205114513.4D7A63D675D@localhost>
	<20061207024436.2b24d418.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: menage@google.com, akpm@osdl.org, linux-mm@kvack.org, mbligh@google.com, winget@google.com, rohitseth@google.com, nickpiggin@yahoo.com.au, ckrm-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> I can imagine two more per-cpuset files, instead of the four above:
> 
>   memory_expansion_pressure - level, 0-100, at which the callout is called
>   memory_expansion_routine - string name of a registered callout.

These choice of names are too specific to Paul M's expansion patch.

For the more generic module approach I'm suggesting, these names
should be more like:

    memory_pressure - level of current pressure on memory applied by tasks in cpuset
    memory_pressure_trigger - level at which memory_pressure_callout called
    memory_pressure_callout - string name of loadable module callback function

And we need two 'level' files, a read-only one that indicates the current
pressure being imposed on memory, and a read-write one that sets the trigger
level at which the callout is invoked.

The 'memory_pressure' read-only level is an aggregate across all the
tasks in the cpuset.  That much it should continue to be, for API
compatibility.  As to which aggregate, that's open to discussion.

Since it's an aggregate of something that can only be sampled at
discrete events (when the tasks in the cpuset ask for memory) it seems
that we need some sort of filtering that is more than just 'the memory
pressure of the most recent allocation request by any task in this
cpuset.'

The memory_pressure_trigger is evaluated for a particular memory
request by a particular task.  It is not an aggregate.

So I could imagine changing 'memory_pressure' to a filtered average of
the mm/vmscan.c distress values seen in recent allocation requests by
tasks in that cpuset.

But it's still distinct from the instantaneous value that triggers
the callout.

I don't think Andrew gets to remove that single-pole low-pass recursive
(IIR) filter code yet ;).

And as long as it remains a time filtered aggregate, 'memory_pressure'
might as well remain just what it is.  It's not worth the bother of
futzing with it to make what are just hidden internal changes for a
token show of greater commonality with the callout trigger metric.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
