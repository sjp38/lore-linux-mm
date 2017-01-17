Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB066B0069
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:49:45 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t18so16507784wmt.7
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:49:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y14si24132949wry.225.2017.01.16.23.49.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 23:49:44 -0800 (PST)
Date: Tue, 17 Jan 2017 08:49:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 0/9] mm/swap: Regular page swap optimizations
Message-ID: <20170117074939.GA19699@dhcp22.suse.cz>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
 <20170116120236.GG13641@dhcp22.suse.cz>
 <878tqapkar.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878tqapkar.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Tue 17-01-17 09:06:04, Huang, Ying wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > Hi,
> > I am seeing a lot of preempt unsafe warnings with the current mmotm and
> > I assume that this patchset has introduced the issue. I haven't checked
> > more closely but get_swap_page didn't use this_cpu_ptr before "mm/swap:
> > add cache for swap slots allocation"
> >
> > [   57.812314] BUG: using smp_processor_id() in preemptible [00000000] code: kswapd0/527
> > [   57.814360] caller is debug_smp_processor_id+0x17/0x19
> > [   57.815237] CPU: 1 PID: 527 Comm: kswapd0 Tainted: G        W 4.9.0-mmotm-00135-g4e9a9895ebef #1042
> > [   57.816019] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1 04/01/2014
> > [   57.816019]  ffffc900001939c0 ffffffff81329c60 0000000000000001 ffffffff81a0ce06
> > [   57.816019]  ffffc900001939f0 ffffffff81343c2a 00000000000137a0 ffffea0000dfd2a0
> > [   57.816019]  ffff88003c49a700 ffffc90000193b10 ffffc90000193a00 ffffffff81343c53
> > [   57.816019] Call Trace:
> > [   57.816019]  [<ffffffff81329c60>] dump_stack+0x68/0x92
> > [   57.816019]  [<ffffffff81343c2a>] check_preemption_disabled+0xce/0xe0
> > [   57.816019]  [<ffffffff81343c53>] debug_smp_processor_id+0x17/0x19
> > [   57.816019]  [<ffffffff8115f06f>] get_swap_page+0x19/0x183
> > [   57.816019]  [<ffffffff8114e01d>] shmem_writepage+0xce/0x38c
> > [   57.816019]  [<ffffffff81148916>] shrink_page_list+0x81f/0xdbf
> > [   57.816019]  [<ffffffff81149652>] shrink_inactive_list+0x2ab/0x594
> > [   57.816019]  [<ffffffff8114a22f>] shrink_node_memcg+0x4c7/0x673
> > [   57.816019]  [<ffffffff8114a49f>] shrink_node+0xc4/0x282
> > [   57.816019]  [<ffffffff8114a49f>] ? shrink_node+0xc4/0x282
> > [   57.816019]  [<ffffffff8114b8cb>] kswapd+0x656/0x834
> > [   57.816019]  [<ffffffff8114b275>] ? mem_cgroup_shrink_node+0x2e1/0x2e1
> > [   57.816019]  [<ffffffff81069fb4>] ? call_usermodehelper_exec_async+0x124/0x12d
> > [   57.816019]  [<ffffffff81073621>] kthread+0xf9/0x101
> > [   57.816019]  [<ffffffff81660198>] ? _raw_spin_unlock_irq+0x2c/0x4a
> > [   57.816019]  [<ffffffff81073528>] ? kthread_park+0x5a/0x5a
> > [   57.816019]  [<ffffffff81069e90>] ? umh_complete+0x25/0x25
> > [   57.816019]  [<ffffffff81660b07>] ret_from_fork+0x27/0x40
> 
> Sorry for bothering, we should have tested this before.

I am always running my tests with CONFIG_DEBUG_PREEMPT=y which is what
has caught this one.

[...]
> > would be a way to go but the function takes a sleeping lock so disabling
> > the preemption is not a way forward. So this is either preempt safe
> > for some reason - which should be IMHO documented in a comment - and
> > raw_cpu_ptr can be used or this needs a deeper thought.
> 
> Thanks for pointing out this.
> 
> We think this is preempt safe.  During the development, we have
> considered the possible preemption between getting the per-CPU pointer
> and its usage, and implemented the code to make it work at that
> situation.  We will change the code to use raw_cpu_ptr() and add a
> comment for it.

FWIW s@this_cpu_ptr@raw_cpu_ptr@ which I am using as a workaround now
hasn't seemed to cause any issue. At least nothing observable like a
crash.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
