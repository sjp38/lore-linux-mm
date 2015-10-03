Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id E983044030A
	for <linux-mm@kvack.org>; Sat,  3 Oct 2015 02:02:41 -0400 (EDT)
Received: by oibi136 with SMTP id i136so68555309oib.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 23:02:41 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id nb5si7716037obb.38.2015.10.02.23.02.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 Oct 2015 23:02:40 -0700 (PDT)
Subject: Can't we use timeout based OOM warning/killing?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
	<201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
	<201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
In-Reply-To: <20151002123639.GA13914@dhcp22.suse.cz>
Message-Id: <201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
Date: Sat, 3 Oct 2015 15:02:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Michal Hocko wrote:
> On Tue 29-09-15 01:18:00, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > The point I've tried to made is that oom unmapper running in a detached
> > > context (e.g. kernel thread) vs. directly in the oom context doesn't
> > > make any difference wrt. lock because the holders of the lock would loop
> > > inside the allocator anyway because we do not fail small allocations.
> >
> > We tried to allow small allocations to fail. It resulted in unstable system
> > with obscure bugs.
>
> Have they been reported/fixed? All kernel paths doing an allocation are
> _supposed_ to check and handle ENOMEM. If they are not then they are
> buggy and should be fixed.
>

Kernel developers are not interested in testing OOM cases. I proposed a
SystemTap-based mandatory memory allocation failure injection for testing
OOM cases, but there was no response. Most of memory allocation failure
paths in the kernel remain untested. Unless you persuade all kernel
developers to test OOM cases and add a gfp flag which bypasses memory
allocation failure injection test (e.g. __GFP_FITv1_PASSED) and change
any !__GFP_FITv1_PASSED && !__GFP_NOFAIL allocations always fail, we can't
check that "all kernel paths doing an allocation are _supposed_ to check
and handle ENOMEM".

> > We tried to allow small !__GFP_FS allocations to fail. It failed to fail by
> > effectively __GFP_NOFAIL allocations.
>
> What do you mean by that? An opencoded __GFP_NOFAIL?
>  

Yes. XFS livelock is an example I can trivially reproduce.
Loss of reliability of buffered write()s is another example.

  [ 1721.405074] buffer_io_error: 36 callbacks suppressed
  [ 1721.406263] Buffer I/O error on dev sda1, logical block 34652401, lost async page write
  [ 1721.406996] Buffer I/O error on dev sda1, logical block 34650278, lost async page write
  [ 1721.407125] Buffer I/O error on dev sda1, logical block 34652330, lost async page write
  [ 1721.407197] Buffer I/O error on dev sda1, logical block 34653485, lost async page write
  [ 1721.407203] Buffer I/O error on dev sda1, logical block 34652398, lost async page write
  [ 1721.407232] Buffer I/O error on dev sda1, logical block 34650494, lost async page write
  [ 1721.407356] Buffer I/O error on dev sda1, logical block 34652361, lost async page write
  [ 1721.407386] Buffer I/O error on dev sda1, logical block 34653484, lost async page write
  [ 1721.407481] Buffer I/O error on dev sda1, logical block 34652396, lost async page write
  [ 1721.407504] Buffer I/O error on dev sda1, logical block 34650291, lost async page write
  [ 1723.369963] XFS: a.out(8241) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [ 1723.810033] XFS: a.out(7788) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [ 1725.434057] XFS: a.out(8171) possible memory allocation deadlock in kmem_alloc (mode:0x8250)
  [ 1725.448049] XFS: a.out(7810) possible memory allocation deadlock in kmem_alloc (mode:0x8250)
  [ 1725.470757] XFS: a.out(8122) possible memory allocation deadlock in kmem_alloc (mode:0x8250)
  [ 1725.474061] XFS: a.out(7881) possible memory allocation deadlock in kmem_alloc (mode:0x8250)
  [ 1725.586610] XFS: a.out(8241) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [ 1726.026702] XFS: a.out(7770) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [ 1726.043988] XFS: a.out(7788) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [ 1727.682001] XFS: a.out(8122) possible memory allocation deadlock in kmem_alloc (mode:0x8250)
  [ 1727.688661] XFS: a.out(8171) possible memory allocation deadlock in kmem_alloc (mode:0x8250)
  [ 1727.785214] XFS: a.out(8241) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [ 1728.226640] XFS: a.out(7770) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [ 1728.290648] XFS: a.out(7788) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  [ 1729.930028] XFS: a.out(8171) possible memory allocation deadlock in kmem_alloc (mode:0x8250)

> > We are now trying to allow zapping OOM victim's mm. Michal is already
> > skeptical about this approach due to lock dependency.
>
> I am not sure where this came from. I am all for this approach. It will
> not solve the problem completely for sure but it can help in many cases
> already.
>

Sorry. This was my misunderstanding. But I still think that we need to be
prepared for cases where zapping OOM victim's mm approach fails.
( http://lkml.kernel.org/r/201509242050.EHE95837.FVFOOtMQHLJOFS@I-love.SAKURA.ne.jp )

> > We already spent 9 months on this OOM livelock. No silver bullet yet.
> > Proposed approaches are too drastic to backport for existing users.
> > I think we are out of bullet.
>
> Not at all. We have this problem since ever basically. And we have a lot
> of legacy issues to care about. But nobody could reasonably expect this
> will be solved in a short time period.
>

What people generally imagine with OOM killer is that OOM killer is invoked
when the system is out of memory. But we know that there are many possible
cases where OOM killer messages are not printed. We did not make effort to
break people free from the belief that OOM killer is invoked when the system
is out of memory, nor make effort to provide people a mean to warn OOM
situation, after we recognized the "too small to fail" memory-allocation rule
( https://lwn.net/Articles/627419/ ) which was 9 months ago.

> > Until we complete adding/testing __GFP_NORETRY (or __GFP_KILLABLE) to most
> > of callsites,
>
> This is simply not doable. There are thousand of allocation sites all
> over the kernel.

But changing the default behavior (i.e. implicitly behave like __GFP_NORETRY
inside memory allocator unless __GFP_NOFAIL is passed) is also not doable.
You will need to ask for ACKs from thousand of allocation sites all over
the kernel but that is not realistic.

An example. I proposed a patch which changes the default behavior in XFS and
got a feedback ( http://marc.info/?l=linux-mm&m=144279862227010 ) that
fundamentally changing the allocation behavior of the filesystem requires
some indication of the testing and characterization of how the change has
impacted low memory balance and performance of the filesystem.
You will need to ask for ACKs from all filesystem developers.

Another example. I don't like that permission checks for access requests from
user space start failing with ENOMEM error when memory is tight. It is not
happy that access requests by critical processes are failed by inconsequential
process's memory consumption.
( https://www.mail-archive.com/tomoyo-users-en@lists.osdn.me/msg00008.html )
This problem is not limited to permission checks. If a process executed a
program using execve() and that process reached the point of no return in
the execve() operation, any memory allocation failure before reaching the
point of handling ENOMEM errors (e.g. failing to load shared libraries before
calling the main() function of the new program), the process will be killed.
If the process were the global init process, the system will panic().

Despite we mean to simply enforce only "all kernel paths doing an allocation
are _supposed_ to check and handle ENOMEM", we have a period where memory
allocation failure in the user space results in an unrecoverable failure.
We depend on /proc/$pid/oom_score_adj for protecting critical processes from
inconsequential process.

I'm happy to give up memory allocation upon SIGKILL, but I'm not happy to
give up upon ENOMEM without making effort to solve OOM situation.

>
> > timeout based workaround will be the only bullet we can use.
>
> Those are the last resort which only paper over real bugs which should
> be fixed. I would agree with your urging if this was something that can
> easily happen on a _properly_ configured system. System which can blow
> into an OOM storm is far from being configured properly. If you have an
> untrusted users running on your system you should better put them into a
> highly restricted environment and limit as much as possible.

People are reporting hang up problems. I'm suspecting that some of them are
caused by silent OOM. I showed you that there are many possible paths which
can lead to silent hang up. But we are forcing people to use kernels without
means to find out what was happening. Therefore, "there is no report" does
not mean that "we are not hitting OOM livelock problems".

Without means to find out what was happening, we will "overlook real bugs"
before "paper over real bugs". The means are expected to work without
knowledge to use trace points functionality, are expected to run without
memory allocation, are expected to dump output without administrator's
operation, are expected to work before power reset by watchdog timers.

>
> I can completely understand your frustration about the pace of the
> progress here but this is nothing new and we should strive for long term
> vision which would be much less fragile than what we have right now. No
> timeout based solution is the way in that direction.

Can we stop randomly setting TIF_MEMDIE to only one task and staying silent
forever in the hope that the task can make a quick exit? As long as small
allocations do not fail, this TIF_MEMDIE logic is prone to livelock.

We won't be able to change small allocations to fail (like Linus said at
http://lkml.kernel.org/r/CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com
and I said in this post) in the near future.

Like I said at http://lkml.kernel.org/r/201510012113.HEA98301.SVFQOFtFOHLMOJ@I-love.SAKURA.ne.jp ,
can't we start adding a mean to emit some diagnostic kernel messages
automatically?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
