Date: Tue, 10 Sep 2002 09:07:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: oom_killer - Does not perform when stress-tested (system hangs)
Message-ID: <20020910160724.GL18800@holomorphy.com>
References: <OF4556A3DE.CC39A8B4-ON65256C30.00293E54@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <OF4556A3DE.CC39A8B4-ON65256C30.00293E54@in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Srikrishnan Sundararajan <srikrishnan@in.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2002 at 01:05:06PM +0530, Srikrishnan Sundararajan wrote:
> When there are lots of user processes each mallocing 1 MB and sleeping
> forever without freeing, there is a possibility of oom_kill to kill a
> critical system task or other processes run as root as long as such a
> process qualifies with the highest "badness" value. While the algorithm
> does reduce the score for any root process, it does not preclude the
> selection of such a process for killing.

The only exempt process is init (pid 1). root processes may offend the
system just as easily, and their death is survivable.


On Tue, Sep 10, 2002 at 01:05:06PM +0530, Srikrishnan Sundararajan wrote:
> I tried to prevent non-root processes from occupying large amounts of
> virtual memory by setting ulimit for virtual memory. When I go beyond this,
> the user program fails with an a cannot allocate memory error. But this
> limit does not take the actual current status into account. ie. Limit is
> not say 95% of total memory etc.

You may be better off with proper RSS limit enforcement patches such as
are present in -ac kernels. Non-overcommit stuff there may also help.


On Tue, Sep 10, 2002 at 01:05:06PM +0530, Srikrishnan Sundararajan wrote:
> I understand that we can allocate quota for hard disk space, there by
> preventing non-root processes from occupying any more disk space beyond the
> quota limit. For example,  we can set quota such that when the
> hard-disk-space is 95% full, only root can occupy further space. Is there a
> similar way to enforce the same for memory usage. This might ensure that
> errant non-root processes cannot keep on allocating memory, thereby can
> prevent the swap from getting full.

RSS limits are on a per-process basis. This kind of workload management
facility has yet to be implemented for Linux.


On Tue, Sep 10, 2002 at 01:05:06PM +0530, Srikrishnan Sundararajan wrote:
> Another thought is can we exclude root processes from  the "badness"
> calculation. This might ensure that at no time a root process is killed by
> oom_kill. Or we can modify this such that as long as a non-root process is
> there, no root processes will be killed by oom_kill.

It's possible, though it hits corner cases of runaway process running with
uid 0 and so doesn't really perform any better than anything else.


On Tue, Sep 10, 2002 at 01:05:06PM +0530, Srikrishnan Sundararajan wrote:
> Also the current oom_kill does not seem to always identify the offending
> process and kill that.  Is there any way of either identifying a specific
> offending process or identify such a user and kill all his processes?

There is no algorithmic method of defining "offending process". I suspect
for these kinds of scenario's Alan's non-overcommit patches would benefit
you more than trying to make overcommit predictable in its worst cases,
especially since that predictability is precisely the tradeoff of
overcommitting memory.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
