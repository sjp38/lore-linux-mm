Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A48EC900144
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 14:56:47 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 13 Sep 2011 14:56:40 -0400
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8DIuYZ0266996
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 14:56:34 -0400
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8DIuXUm007254
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 12:56:33 -0600
Message-ID: <4E6FA75A.8060308@linux.vnet.ibm.com>
Date: Tue, 13 Sep 2011 13:56:26 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [REVERT for 3.1-rc7] staging: zcache: revert "fix crash on high
 memory swap"
References: <2ca31b06-eef9-49e4-beba-4959471b45d2@default>
In-Reply-To: <2ca31b06-eef9-49e4-beba-4959471b45d2@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg KH <greg@kroah.com>, Francis Moreau <francis.moro@gmail.com>, gregkh@suse.de, devel@driverdev.osuosl.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org

On 09/13/2011 12:37 PM, Dan Magenheimer wrote:
> Hi Greg --
> 
> Please revert the following commit, hopefully before 3.1 is released.
> Although it fixes a crash in 32-bit systems with high memory,
> the fix apparently *causes* crashes on 64-bit systems.  Not sure why
> my testing didn't catch it before but it has now been observed in
> the wild in 3.1-rc4 and I can reproduce it now fairly easily.
> 3.1-rc3 works fine, 3.1-rc4 fails, and 3.1-rc3 plus only this
> commit fails.  Let's revert it before 3.1 and Seth and Nitin and I
> will sort out a better fix later.
> 

I found it:
------------[ cut here ]------------
[  203.889026] kernel BUG at arch/x86/mm/physaddr.c:20!
[  203.889026] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  203.889026] CPU 0 
[  203.889026] Modules linked in:
[  203.889026] 
[  203.889026] Pid: 1170, comm: cat Not tainted 3.1.0-rc3+ #25 Bochs Bochs
[  203.889026] RIP: 0010:[<ffffffff810686bf>]  [<ffffffff810686bf>] __phys_addr+0x5f/0x70
[  203.889026] RSP: 0018:ffff8800091ab7e8  EFLAGS: 00010002
[  203.889026] RAX: 0000620000237680 RBX: ffff880008c4b078 RCX: 0000000000000028
[  203.889026] RDX: 0000000000000062 RSI: ffff8800091ab900 RDI: ffffea0000237680
[  203.889026] RBP: ffff8800091ab7e8 R08: ffff880009680000 R09: ffff8800091ab8e8
[  203.889026] R10: 0000000000000000 R11: 0000000000000001 R12: ffff880009680000
[  203.889026] R13: 0000000000001397 R14: ffff880008c4b078 R15: 0000000000000001
[  203.889026] FS:  00007f3ae749e700(0000) GS:ffff88000fc00000(0000) knlGS:0000000000000000
[  203.889026] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  203.889026] CR2: 00007fe7bc3e8cd1 CR3: 00000000091fb000 CR4: 00000000000006f0
[  203.889026] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  203.889026] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  203.889026] Process cat (pid: 1170, threadinfo ffff8800091aa000, task ffff880009582040)
[  203.889026] Stack:
[  203.889026]  ffff8800091ab838 ffffffff81352d2f 0000000000000001 0000000000000001
[  203.889026]  ffff8800091ab838 ffff8800091ab8e8 ffff880009680000 0000000000001397
[  203.889026]  ffff880008c4b078 0000000000000001 ffff8800091ab8c8 ffffffff81353ab2
[  203.889026] Call Trace:
[  203.889026]  [<ffffffff81352d2f>] zcache_pampd_get_data_and_free+0x2f/0x150
[  203.889026]  [<ffffffff81353ab2>] tmem_get+0x152/0x210
[  203.889026]  [<ffffffff81352044>] zcache_cleancache_get_page+0xa4/0xc0
...

Missed a virt_to_page() in zcache_pampd_get_data_and_free().  I only exercised frontswap
and this path is only called with cleancache.  I'll remember this.

Standby for patch...

> Reported-by: Francis Moreau <francis.moro@gmail.com>
> Reproduced-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> 
> Thanks,
> Dan
> 
> commit c5f5c4db393837ebb2ae47bf061d70e498f48f8c
> Author: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Date:   Wed Aug 10 12:56:49 2011 -0500
> 
>     staging: zcache: fix crash on high memory swap
>     
>     zcache_put_page() was modified to pass page_address(page) instead of the
>     actual page structure. In combination with the function signature changes
>     to tmem_put() and zcache_pampd_create(), zcache_pampd_create() tries to
>     (re)derive the page structure from the virtual address.  However, if the
>     original page is a high memory page (or any unmapped page), this
>     virt_to_page() fails because the page_address() in zcache_put_page()
>     returned NULL.
>     
>     This patch changes zcache_put_page() and zcache_get_page() to pass
>     the page structure instead of the page's virtual address, which
>     may or may not exist.
>     
>     Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>     Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>     Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> 
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 855a5bb..a3f5162 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1158,7 +1158,7 @@ static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
>  	size_t clen;
>  	int ret;
>  	unsigned long count;
> -	struct page *page = virt_to_page(data);
> +	struct page *page = (struct page *)(data);
>  	struct zcache_client *cli = pool->client;
>  	uint16_t client_id = get_client_id_from_client(cli);
>  	unsigned long zv_mean_zsize;
> @@ -1227,7 +1227,7 @@ static int zcache_pampd_get_data(char *data, size_t *bufsize, bool raw,
>  	int ret = 0;
>  
>  	BUG_ON(is_ephemeral(pool));
> -	zv_decompress(virt_to_page(data), pampd);
> +	zv_decompress((struct page *)(data), pampd);
>  	return ret;
>  }
>  
> @@ -1539,7 +1539,7 @@ static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
>  		goto out;
>  	if (!zcache_freeze && zcache_do_preload(pool) == 0) {
>  		/* preload does preempt_disable on success */
> -		ret = tmem_put(pool, oidp, index, page_address(page),
> +		ret = tmem_put(pool, oidp, index, (char *)(page),
>  				PAGE_SIZE, 0, is_ephemeral(pool));
>  		if (ret < 0) {
>  			if (is_ephemeral(pool))
> @@ -1572,7 +1572,7 @@ static int zcache_get_page(int cli_id, int pool_id, struct tmem_oid *oidp,
>  	pool = zcache_get_pool_by_id(cli_id, pool_id);
>  	if (likely(pool != NULL)) {
>  		if (atomic_read(&pool->obj_count) > 0)
> -			ret = tmem_get(pool, oidp, index, page_address(page),
> +			ret = tmem_get(pool, oidp, index, (char *)(page),
>  					&size, 0, is_ephemeral(pool));
>  		zcache_put_pool(pool);
>  	}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
