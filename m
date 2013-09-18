From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Date: Wed, 18 Sep 2013 14:19:46 -0400
Message-ID: <20130918181946.GE856@cmpxchg.org>
References: <20130916161316.5113F6E7@pobox.sk>
 <20130916145744.GE3674@dhcp22.suse.cz>
 <20130916170543.77F1ECB4@pobox.sk>
 <20130916152548.GF3674@dhcp22.suse.cz>
 <20130916225246.A633145B@pobox.sk>
 <20130917000244.GD3278@cmpxchg.org>
 <20130917131535.94E0A843@pobox.sk>
 <20130917141013.GA30838@dhcp22.suse.cz>
 <20130918160304.6EDF2729@pobox.sk>
 <20130918180455.GD856@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130918180455.GD856-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: azurIt <azurit-Rm0zKEqwvD4@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: linux-mm.kvack.org

On Wed, Sep 18, 2013 at 02:04:55PM -0400, Johannes Weiner wrote:
> On Wed, Sep 18, 2013 at 04:03:04PM +0200, azurIt wrote:
> > > CC: "Johannes Weiner" <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, "Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "David Rientjes" <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, "KOSAKI Motohiro" <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > >On Tue 17-09-13 13:15:35, azurIt wrote:
> > >[...]
> > >> Is something unusual on this stack?
> > >> 
> > >> 
> > >> [<ffffffff810d1a5e>] dump_header+0x7e/0x1e0
> > >> [<ffffffff810d195f>] ? find_lock_task_mm+0x2f/0x70
> > >> [<ffffffff810d1f25>] oom_kill_process+0x85/0x2a0
> > >> [<ffffffff810d24a8>] mem_cgroup_out_of_memory+0xa8/0xf0
> > >> [<ffffffff8110fb76>] mem_cgroup_oom_synchronize+0x2e6/0x310
> > >> [<ffffffff8110efc0>] ? mem_cgroup_uncharge_page+0x40/0x40
> > >> [<ffffffff810d2703>] pagefault_out_of_memory+0x13/0x130
> > >> [<ffffffff81026f6e>] mm_fault_error+0x9e/0x150
> > >> [<ffffffff81027424>] do_page_fault+0x404/0x490
> > >> [<ffffffff810f952c>] ? do_mmap_pgoff+0x3dc/0x430
> > >> [<ffffffff815cb87f>] page_fault+0x1f/0x30
> > >
> > >This is a regular memcg OOM killer. Which dumps messages about what is
> > >going to do. So no, nothing unusual, except if it was like that for ever
> > >which would mean that oom_kill_process is in the endless loop. But a
> > >single stack doesn't tell us much.
> > >
> > >Just a note. When you see something hogging a cpu and you are not sure
> > >whether it might be in an endless loop inside the kernel it makes sense
> > >to take several snaphosts of the stack trace and see if it changes. If
> > >not and the process is not sleeping (there is no schedule on the trace)
> > >then it might be looping somewhere waiting for Godot. If it is sleeping
> > >then it is slightly harder because you would have to identify what it is
> > >waiting for which requires to know a deeper context.
> > >-- 
> > >Michal Hocko
> > >SUSE Labs
> > 
> > 
> > 
> > I was finally able to get stack of problematic process :) I saved it two times from the same process, as Michal suggested (i wasn't able to take more). Here it is:
> > 
> > First (doesn't look very helpfull):
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > 
> > Second:
> > [<ffffffff810e17d1>] shrink_zone+0x481/0x650
> > [<ffffffff810e2ade>] do_try_to_free_pages+0xde/0x550
> > [<ffffffff810e310b>] try_to_free_pages+0x9b/0x120
> > [<ffffffff81148ccd>] free_more_memory+0x5d/0x60
> > [<ffffffff8114931d>] __getblk+0x14d/0x2c0
> > [<ffffffff8114c973>] __bread+0x13/0xc0
> > [<ffffffff811968a8>] ext3_get_branch+0x98/0x140
> > [<ffffffff81197497>] ext3_get_blocks_handle+0xd7/0xdc0
> > [<ffffffff81198244>] ext3_get_block+0xc4/0x120
> > [<ffffffff81155b8a>] do_mpage_readpage+0x38a/0x690
> > [<ffffffff81155ffb>] mpage_readpages+0xfb/0x160
> > [<ffffffff811972bd>] ext3_readpages+0x1d/0x20
> > [<ffffffff810d9345>] __do_page_cache_readahead+0x1c5/0x270
> > [<ffffffff810d9411>] ra_submit+0x21/0x30
> > [<ffffffff810cfb90>] filemap_fault+0x380/0x4f0
> > [<ffffffff810ef908>] __do_fault+0x78/0x5a0
> > [<ffffffff810f2b24>] handle_pte_fault+0x84/0x940
> > [<ffffffff810f354a>] handle_mm_fault+0x16a/0x320
> > [<ffffffff8102715b>] do_page_fault+0x13b/0x490
> > [<ffffffff815cb87f>] page_fault+0x1f/0x30
> > [<ffffffffffffffff>] 0xffffffffffffffff
> 
> Ah, crap.  I'm sorry.  You even showed us this exact trace before in
> another context, but I did not fully realize what __getblk() is doing.
> 
> My subsequent patches made a charge attempt return -ENOMEM without
> reclaim if the memcg is under OOM.  And so the reason you have these
> reclaim livelocks is because __getblk never fails on -ENOMEM.  When
> the allocation returns -ENOMEM, it invokes GLOBAL DIRECT RECLAIM and
> tries again in an endless loop.  The memcg code would previously just
> loop inside the charge, reclaiming and killing, until the allocation
> succeeded.  But the new code relies on the fault stack being unwound
> to complete the OOM kill.  And since the stack is not unwound with
> __getblk() looping around the allocation there is no more memcg
> reclaim AND no memcg OOM kill, thus no chance of exiting.
> 
> That code is weird but really old, so it may take a while to evaluate
> all the callers as to whether this can be changed.
> 
> In the meantime, I would just allow __getblk to bypass the memcg limit
> when it still can't charge after reclaim.  Does the below get your
> machine back on track?

Scratch that.  The idea is reasonable but the implementation is not
fully cooked yet.  I'll send you an update.
