From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [4.4-rc7] spinlock recursion while oom'ing.
Date: Tue, 5 Jan 2016 12:21:36 -0500
Message-ID: <20160105172136.GA28066@codemonkey.org.uk>
References: <20160103222728.GA11973@codemonkey.org.uk>
 <20160105163535.GD15594@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160105163535.GD15594@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-Id: linux-mm.kvack.org

On Tue, Jan 05, 2016 at 05:35:36PM +0100, Michal Hocko wrote:
 > [CCing David]
 > 
 > On Sun 03-01-16 17:27:28, Dave Jones wrote:
 > > This is an odd one..
 > > 
 > > Out of memory: Kill process 5861 (trinity-c10) score 504 or sacrifice child
 > > BUG: spinlock recursion on CPU#1, trinity-c8/8828
 > >  lock: 0xffff8800a3635410, .magic: dead4ead, .owner: trinity-c8/8828, .owner_cpu: 1
 > > CPU: 1 PID: 8828 Comm: trinity-c8 Not tainted 4.4.0-rc7-gelk-debug+ #3 
 > >  00000000000001f8 ffff8800968d7808 ffffffff9a4d4451 ffff8800a3635410
 > >  ffff8800968d7838 ffffffff9a117b36 ffff8800a3635410 ffff8800a3635420
 > >  ffff8800a3635410 ffff8800a3635398 ffff8800968d7870 ffffffff9a117d63
 > > Call Trace:
 > >  [<ffffffff9a4d4451>] dump_stack+0x4e/0x7d
 > >  [<ffffffff9a117b36>] spin_dump+0xc6/0x130
 > >  [<ffffffff9a117d63>] do_raw_spin_lock+0x163/0x1a0
 > >  [<ffffffff9aae15ef>] _raw_spin_lock+0x1f/0x30
 > >  [<ffffffff9a2271cb>] find_lock_task_mm+0x5b/0xd0
 > >  [<ffffffff9a227cc0>] oom_kill_process+0x2a0/0x660
 > >  [<ffffffff9a22855d>] out_of_memory+0x45d/0x4b0
 > 
 > Hmm, this is indeed weird. We are certainly not holding task_lock during
 > the allocation AFAICS (if yes that would be a GFP_KERNEL allocation with
 > a spinlock so I would assume a blow up earlier than when entering OOM).
 > 
 > oom_badness unlocks in all paths AFAICS. oom_kill_process will lock the
 > victim again but it releases the lock as well. dump_tasks the same.

sorry, turned out to be a (broken) leftover debugging patch that I'd had applied
that I thought I'd dropped but hadn't..

	Dave
