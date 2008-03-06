Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m26HqHfi011374
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 12:52:17 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m26Hr1pH200848
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 10:53:01 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m26Hr0p4007233
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 10:53:01 -0700
Date: Thu, 6 Mar 2008 09:53:11 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [BUG] 2.6.25-rc4 hang/softlockups after freeing hugepages
Message-ID: <20080306175311.GA14567@us.ibm.com>
References: <1204824183.5294.62.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1204824183.5294.62.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On 06.03.2008 [12:23:03 -0500], Lee Schermerhorn wrote:
> Test platform:  HP Proliant DL585 server - 4 socket, dual core AMD with
> 32GB memory.
> 
> I first saw this on 25-rc2-mm1 with Mel's zonelist patches, while
> investigating the interaction of hugepages and cpusets.  Thinking that
> it might be caused by the zonelist patches, I went back to 25-rc2-mm1
> w/o the patches and saw the same thing.  It sometimes takes a while for
> the softlockups to start appearing, and I wanted to find a fairly
> minimal duplicator.  Meanwhile 25-rc3 and rc4 have come out, so I tried
> the latest upstream kernel and see the same thing.

So, does 2.6.25-rc2 show the problem? Or was it something introduced in
that -mm which has since gone upstream?

> To duplicate the problem, I need only:
> 
> + log into the platform as root in one window and:
> 
> 	echo N >/proc/sys/vm/nr_hugepages
> 	echo 0 >proc/sys/vm/nr_hugepages
> 
> In my case, N=64.  If I look, before echoing 0, I see 16 hugepages
> allocated on each of the 4 nodes, as expected.
> 
> + then in another window, log in again.  
> 
> Sometimes it will hang during the 2nd login and I'll never see a shell
> prompt.  Other times, I make it all the way to editing a file or
> starting a kernel build.  The task in the 2nd login hangs and on the
> console I see--e.g.,
> 
> BUG: soft lockup - CPU#1 stuck for 61s! [runkbuild:3320]
> CPU 1:
> Modules linked in: sunrpc ipv6 dm_mirror dm_mod parport_pc lp parport ide_cd_mod cdrom button tg3 hpwdt serio_raw amd_rng pata_acpi libata i2c_amd756 i2c_core pcspkr mptspi mptscsih sym53c8xx scsi_transport_spi sd_mod scsi_mod mptbase ext3 jbd ehci_hcd ohci_hcd uhci_hcd
> Pid: 3320, comm: runkbuild Not tainted 2.6.25-rc4 #1
> RIP: 0010:[<ffffffff803341f5>]  [<ffffffff803341f5>] copy_page_c+0x5/0x10
> RSP: 0000:ffff8103fe56fe00  EFLAGS: 00010286
> RAX: ffff810000000000 RBX: ffff8103fe56fe68 RCX: 0000000000000200
> RDX: ffffffff805d6c00 RSI: ffff8103fdada000 RDI: ffff8103fe200000
> RBP: ffff8103fe56fe68 R08: ffffe20017fc3a68 R09: 00003ffffffff000
> R10: 0000000000000002 R11: 0000000000000246 R12: ffffe2000ff6b680
> R13: ffffe2000ff88000 R14: ffff8103fe08c160 R15: ffff8103fe08fb10
> FS:  00007f20b83996f0(0000) GS:ffff8103ff028000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: ffff8103fe200000 CR3: 00000007fe0c7000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> 
> Call Trace:
>  [<ffffffff8027b693>] ? do_wp_page+0x103/0x570
>  [<ffffffff8027e4cf>] handle_mm_fault+0x5cf/0x7f0
>  [<ffffffff804a1cdf>] do_page_fault+0x26f/0x8d0
>  [<ffffffff8049fbd9>] error_exit+0x0/0x51
> 
> ---------------------------------------------------------------------------
> 
> This one is from starting a shell script 'runkbuild' to run parallel
> kernel builds in a loop.  Never got to start any make.  Dont' know
> whether I can trust the RIP.  
> 
> I have also seen hangs in get_page_from_freelist() which make more sense
> to me.  Perhaps failure to unlock a zone lru_lock?

Hrm, interesting. Barring an obvious thinko, can you bisect it at all?
If it's in mainline for 2.6.25-rc2 to -rc3, that shouldn't take too
long.

> I've been looking through the hugepage allocation/freeing functions and
> haven't seen anything that jumps out at me.

I don't see anything obvious either. You don't get any softlockups
without first growing and shrinking the pool? How about only growing it?

> I took a look at the recent hugetlb patches from Adam and Nish, but none
> seemed to address this symptom.  I don't think I'm dealing with surplus
> pages here.

If /proc/sys/vm/nr_overcommit_hugepages = 0, then no, you're not.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
