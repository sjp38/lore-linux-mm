Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6486B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 02:07:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b68so12452051wme.4
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 23:07:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p72si474619wme.267.2017.09.12.23.07.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Sep 2017 23:07:55 -0700 (PDT)
Date: Wed, 13 Sep 2017 08:07:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] swapon: fix vfree() badness
Message-ID: <20170913060752.6jfmvs7ruipzb6gs@dhcp22.suse.cz>
References: <20170905014051.11112-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170905014051.11112-1-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue 05-09-17 11:40:51, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> The cluster_info structure is allocated with kvzalloc(), which can
> return kmalloc'd or vmalloc'd memory. It must be paired with
> kvfree(), but sys_swapon uses vfree(), resultin in this warning
> from xfstests generic/357:
> 
> [ 1985.294915] swapon: swapfile has holes
> [ 1985.296012] Trying to vfree() bad address (ffff88011569ac00)
> [ 1985.297769] ------------[ cut here ]------------
> [ 1985.299017] WARNING: CPU: 4 PID: 980 at mm/vmalloc.c:1521 __vunmap+0x97/0xb0
> [ 1985.300868] CPU: 4 PID: 980 Comm: swapon Tainted: G        W       4.13.0-dgc #55
> [ 1985.303086] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [ 1985.305421] task: ffff88083599c800 task.stack: ffffc90006d68000
> [ 1985.306896] RIP: 0010:__vunmap+0x97/0xb0
> [ 1985.307866] RSP: 0018:ffffc90006d6be68 EFLAGS: 00010296
> [ 1985.309300] RAX: 0000000000000030 RBX: ffff88011569ac00 RCX: 0000000000000000
> [ 1985.311066] RDX: ffff88013fc949d8 RSI: ffff88013fc8cb98 RDI: ffff88013fc8cb98
> [ 1985.312803] RBP: ffffc90006d6be80 R08: 000000000004844c R09: 0000000000001578
> [ 1985.314672] R10: ffffffff82271b20 R11: ffffffff8256e16d R12: 000000000000000a
> [ 1985.316444] R13: 0000000000000001 R14: 00000000ffffffea R15: ffff880139a96000
> [ 1985.318230] FS:  00007fb23ac0e880(0000) GS:ffff88013fc80000(0000) knlGS:0000000000000000
> [ 1985.320081] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1985.321503] CR2: 0000564cdb0c7000 CR3: 0000000137448000 CR4: 00000000000406e0
> [ 1985.323140] Call Trace:
> [ 1985.323727]  vfree+0x2e/0x70
> [ 1985.324403]  SyS_swapon+0x433/0x1080
> [ 1985.325365]  entry_SYSCALL_64_fastpath+0x1a/0xa5
> 
> Fix this as well as the memory leak caused by a missing kvfree(frontswap_map) in
> the error handling code.

Yes the patch is correct. Darrick has posted a similar fix
http://lkml.kernel.org/r/20170831233515.GR3775@magnolia and it is
sitting in the Andrew's tree already (with the follow up from David to
address frontswap_map)

Thanks!

> 
> cc: <stable@vger.kernel.org>
> Signed-Off-By: Dave Chinner <dchinner@redhat.com>
> ---
>  mm/swapfile.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 6ba4aab2db0b..a8952b6563c6 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -3052,7 +3052,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	p->flags = 0;
>  	spin_unlock(&swap_lock);
>  	vfree(swap_map);
> -	vfree(cluster_info);
> +	kvfree(cluster_info);
> +	kvfree(frontswap_map);
>  	if (swap_file) {
>  		if (inode && S_ISREG(inode->i_mode)) {
>  			inode_unlock(inode);
> -- 
> 2.13.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
