Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 38FAC6B0002
	for <linux-mm@kvack.org>; Fri, 10 May 2013 10:03:50 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 10 May 2013 10:03:49 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 7BB786E8057
	for <linux-mm@kvack.org>; Fri, 10 May 2013 10:03:42 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4AE3jj620971542
	for <linux-mm@kvack.org>; Fri, 10 May 2013 10:03:45 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4AE1ZKO024608
	for <linux-mm@kvack.org>; Fri, 10 May 2013 08:01:35 -0600
Date: Fri, 10 May 2013 09:01:29 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/7] defer clearing of page_private() for swap cache
 pages
Message-ID: <20130510140129.GA8008@cerebellum>
References: <20130507211954.9815F9D1@viggo.jf.intel.com>
 <20130507211955.7DF88A4F@viggo.jf.intel.com>
 <20130509220739.GA14840@cerebellum>
 <20130510092649.GA14968@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130510092649.GA14968@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On Fri, May 10, 2013 at 11:26:49AM +0200, Michal Hocko wrote:
> On Thu 09-05-13 17:07:39, Seth Jennings wrote:
> > On Tue, May 07, 2013 at 02:19:55PM -0700, Dave Hansen wrote:
> > > 
> > > From: Dave Hansen <dave.hansen@linux.intel.com>
> > > 
> > > There are only two callers of swapcache_free() which actually
> > > pass in a non-NULL 'struct page'.  Both of them
> > > (__remove_mapping and delete_from_swap_cache())  create a
> > > temporary on-stack 'swp_entry_t' and set entry.val to
> > > page_private().
> > > 
> > > They need to do this since __delete_from_swap_cache() does
> > > set_page_private(page, 0) and destroys the information.
> > > 
> > > However, I'd like to batch a few of these operations on several
> > > pages together in a new version of __remove_mapping(), and I
> > > would prefer not to have to allocate temporary storage for
> > > each page.  The code is pretty ugly, and it's a bit silly
> > > to create these on-stack 'swp_entry_t's when it is so easy to
> > > just keep the information around in 'struct page'.
> > > 
> > > There should not be any danger in doing this since we are
> > > absolutely on the path of freeing these page.  There is no
> > > turning back, and no other rerferences can be obtained
> > > after it comes out of the radix tree.
> > 
> > I get a BUG on this one:
> > 
> > [   26.114818] ------------[ cut here ]------------
> > [   26.115282] kernel BUG at mm/memcontrol.c:4111!
> > [   26.115282] invalid opcode: 0000 [#1] PREEMPT SMP 
> > [   26.115282] Modules linked in:
> > [   26.115282] CPU: 3 PID: 5026 Comm: cc1 Not tainted 3.9.0+ #8
> > [   26.115282] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> > [   26.115282] task: ffff88007c1cdca0 ti: ffff88001b442000 task.ti: ffff88001b442000
> > [   26.115282] RIP: 0010:[<ffffffff810ed425>]  [<ffffffff810ed425>] __mem_cgroup_uncharge_common+0x255/0x2e0
> > [   26.115282] RSP: 0000:ffff88001b443708  EFLAGS: 00010206
> > [   26.115282] RAX: 4000000000090009 RBX: 0000000000000000 RCX: ffffc90000014001
> > [   26.115282] RDX: 0000000000000000 RSI: 0000000000000002 RDI: ffffea00006e5b40
> > [   26.115282] RBP: ffff88001b443738 R08: 0000000000000000 R09: 0000000000000000
> > [   26.115282] R10: 0000000000000000 R11: 0000000000000000 R12: ffffea00006e5b40
> > [   26.115282] R13: 0000000000000000 R14: ffffea00006e5b40 R15: 0000000000000002
> > [   26.115282] FS:  00007fabd08ee700(0000) GS:ffff88007fd80000(0000) knlGS:0000000000000000
> > [   26.115282] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [   26.115282] CR2: 00007fabce27a000 CR3: 000000001985f000 CR4: 00000000000006a0
> > [   26.115282] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > [   26.115282] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > [   26.115282] Stack:
> > [   26.115282]  ffffffff810dcbae ffff880064a0a500 0000000000000001 ffffea00006e5b40
> > [   26.115282]  ffffea00006e5b40 0000000000000001 ffff88001b443748 ffffffff810f0d05
> > [   26.115282]  ffff88001b443778 ffffffff810ddb3e ffff88001b443778 ffffea00006e5b40
> > [   26.115282] Call Trace:
> > [   26.115282]  [<ffffffff810dcbae>] ? swap_info_get+0x5e/0xe0
> > [   26.115282]  [<ffffffff810f0d05>] mem_cgroup_uncharge_swapcache+0x15/0x20
> > [   26.115282]  [<ffffffff810ddb3e>] swapcache_free+0x4e/0x70
> > [   26.115282]  [<ffffffff810b6e67>] __remove_mapping+0xd7/0x120
> > [   26.115282]  [<ffffffff810b8682>] shrink_page_list+0x5c2/0x920
> > [   26.115282]  [<ffffffff810b780e>] ? isolate_lru_pages.isra.37+0xae/0x120
> > [   26.115282]  [<ffffffff810b8ecf>] shrink_inactive_list+0x13f/0x380
> > [   26.115282]  [<ffffffff810b9350>] shrink_lruvec+0x240/0x4e0
> > [   26.115282]  [<ffffffff810b9656>] shrink_zone+0x66/0x1a0
> > [   26.115282]  [<ffffffff810ba1fb>] do_try_to_free_pages+0xeb/0x570
> > [   26.115282]  [<ffffffff810eb7d9>] ? lookup_page_cgroup_used+0x9/0x20
> > [   26.115282]  [<ffffffff810ba7af>] try_to_free_pages+0x9f/0xc0
> > [   26.115282]  [<ffffffff810b1357>] __alloc_pages_nodemask+0x5a7/0x970
> > [   26.115282]  [<ffffffff810cb2be>] handle_pte_fault+0x65e/0x880
> > [   26.115282]  [<ffffffff810cc7d9>] handle_mm_fault+0x139/0x1e0
> > [   26.115282]  [<ffffffff81027920>] __do_page_fault+0x160/0x460
> > [   26.115282]  [<ffffffff810d176c>] ? do_brk+0x1fc/0x360
> > [   26.115282]  [<ffffffff81212979>] ? lockdep_sys_exit_thunk+0x35/0x67
> > [   26.115282]  [<ffffffff81027c49>] do_page_fault+0x9/0x10
> > [   26.115282]  [<ffffffff813b4a72>] page_fault+0x22/0x30
> > [   26.115282] Code: a9 00 00 08 00 0f 85 43 fe ff ff e9 b8 fe ff ff 66 0f 1f 44 00 00 41 8b 44 24 18 85 c0 0f 89 2b fe ff ff 0f 1f 00 e9 9d fe ff ff <0f> 0b 66 0f 1f 84 00 00 00 00 00 49 89 9c 24 48 0f 00 00 e9 0a 
> > [   26.115282] RIP  [<ffffffff810ed425>] __mem_cgroup_uncharge_common+0x255/0x2e0
> > [   26.115282]  RSP <ffff88001b443708>
> > [   26.171597] ---[ end trace 5e49a21e51452c24 ]---
> > 
> > 
> > mm/memcontrol:4111
> > VM_BUG_ON(PageSwapCache(page));
> > 
> > Seems that mem_cgroup_uncharge_swapcache, somewhat ironically expects the
> > SwapCache flag to be unset already.
> > 
> > Fix might be a simple as removing that VM_BUG_ON() but there might be more to
> > it.  There usually is :)
> 
> This has been already fixed in the -mm tree
> (http://git.kernel.org/cgit/linux/kernel/git/mhocko/mm.git/commit/?h=since-3.9&id=b341f7ffa5fe6ae11afa87e2fecc32c6093541f8)

Ah yes, I even saw this patch come in now I see it again.  I should have known!

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
