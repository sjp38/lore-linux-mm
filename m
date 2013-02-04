Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 68DFD6B0002
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 20:46:40 -0500 (EST)
Date: Mon, 4 Feb 2013 10:46:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: next-20130128 lockdep whinge in sys_swapon()
Message-ID: <20130204014638.GC2688@blaptop>
References: <5595.1359657914@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5595.1359657914@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Cc: Shaohua Li <shli@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,


On Thu, Jan 31, 2013 at 01:45:14PM -0500, Valdis Kletnieks wrote:
> Seen in my linux-next dmesg.  I'm suspecting commit ac07b1ffc:
> 
> commit ac07b1ffc27d575013041fb5277dab02c661d9c2
> Author: Shaohua Li <shli@kernel.org>
> Date:   Thu Jan 24 13:13:50 2013 +1100
> 
>     swap: add per-partition lock for swapfile
> 
> as (a) it was OK in -20130117, and (b) 'git blame mm/swapfile.c | grep 2013'
> shows that commit as the vast majority of changes.
> 
> [   42.498669] INFO: trying to register non-static key.
> [   42.498670] the code is fine but needs lockdep annotation.
> [   42.498671] turning off the locking correctness validator.
> [   42.498674] Pid: 1035, comm: swapon Not tainted 3.8.0-rc5-next-20130128 #52
> [   42.498675] Call Trace:
> [   42.498681]  [<ffffffff81073dc8>] register_lock_class+0x103/0x2ad
> [   42.498685]  [<ffffffff812493ad>] ? __list_add_rcu+0xc4/0xdf
> [   42.498688]  [<ffffffff81075573>] __lock_acquire+0x108/0xd63
> [   42.498691]  [<ffffffff810b482b>] ? trace_preempt_on+0x12/0x2f
> [   42.498695]  [<ffffffff81608e6e>] ? sub_preempt_count+0x31/0x43
> [   42.498699]  [<ffffffff810fda36>] ? sys_swapon+0x6f9/0x9d9
> [   42.498701]  [<ffffffff810764f2>] lock_acquire+0xc7/0x14a
> [   42.498703]  [<ffffffff810fda62>] ? sys_swapon+0x725/0x9d9
> [   42.498706]  [<ffffffff81605023>] _raw_spin_lock+0x34/0x41
> [   42.498708]  [<ffffffff810fda62>] ? sys_swapon+0x725/0x9d9
> [   42.498710]  [<ffffffff810fda62>] sys_swapon+0x725/0x9d9
> [   42.498712]  [<ffffffff8107520a>] ? trace_hardirqs_on_caller+0x149/0x165
> [   42.498715]  [<ffffffff8160be92>] system_call_fastpath+0x16/0x1b
> [   42.498719] Adding 2097148k swap on /dev/mapper/vg_blackice-swap.  Priority:-1 extents:1 across:2097148k
> 
> Somebody care to sprinkle the appropriate annotations on that code?

Could you test this patch?
