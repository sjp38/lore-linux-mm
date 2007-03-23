Message-ID: <46033311.1000101@yahoo.com.au>
Date: Fri, 23 Mar 2007 12:53:21 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Subject: [PATCH RESEND 1/1] cpusets/sched_domain reconciliation
References: <20070322231559.GA22656@sgi.com>
In-Reply-To: <20070322231559.GA22656@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Cliff Wickman wrote:
> Submission #2: This patch was diffed against 2.6.21-rc4
>                (first submission was against 2.6.20-rc6)
> 
> 
> This patch reconciles cpusets and sched_domains that get out of sync
> due to disabling and re-enabling of cpu's.
> 
> Dinakar Guniguntala (IBM) is working on his own version of fixing this.
> But as of this date that fix doesn't seem to be ready.
> 
> Here is an example of how the problem can occur:
> 
>    system of cpu's 0-31
>    create cpuset /x  16-31
>    create cpuset /x/y  16-23
>    all cpu_exclusive
> 
>    disable cpu 17
>      x is now    16,18-31
>      x/y is now 16,18-23
>    enable cpu 17
>      x and x/y are unchanged
> 
>    to restore the cpusets:
>      echo 16-31 > /dev/cpuset/x
>      echo 16-23 > /dev/cpuset/x/y
> 
>    At the first echo, update_cpu_domains() is called for cpuset x/.
> 
>    The system is partitioned between:
>         its parent, the root cpuset of 0-31, minus its
>                                     children (x/ is 16-31): 0-15
>         and x/ (16-31), minus its children (x/y/ 16,18-23): 17,24-31
> 
>    The sched_domain's for parent 0-15 are updated.
>    The sched_domain's for current 17,24-31 are updated.
> 
>    But 16 has been untouched.
>    As a result, 17's SD points to sched_group_phys[17] which is the only
>    sched_group_phys on 17's list.  It points to itself.
>    But 16's SD points to sched_group_phys[16], which still points to
>    sched_group_phys[17].
>    When cpu 16 executes find_busiest_group() it will hang on the non-
>    circular sched_group list.
> 
> This solution is to update the sched_domain's for the cpuset
> whose cpu's were changed and, in addition, all its children.
> The update_cpu_domains() will end with a (recursive) call to itself
> for each child.

I had a patch for doing "something" that I thought was right here,
and IIRC it didn't use any recursive call.

The problem was that Paul didn't think it followed cpus_exclusive
correctly, and I don't think we ever got to the point of giving it
a rigourous definition.

Can we start with getting some useful definition? My suggestion was
something like that if cpus_exclusive is set, then no other sets
except descendants and ancestors could have overlapping cpus. That
didn't go down well, for reasons I don't think I quit understood...

> The extra sched_domain reconstruction is overhead, but only at the
> frequency of administrative change to the cpusets.
> 
> This patch also includes checks in find_busiest_group() and
> find_idlest_group() that break from their loops on a sched_group that
> points to itself.  This is needed because other cpu's are going through
> load balancing while the sched_domains are being reconstructed.

This is not really allowed, to make locking simpler. You have to go
through the full detach and reattach.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
