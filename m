Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id SAA01106
	for <linux-mm@kvack.org>; Sat, 28 Sep 2002 18:32:01 -0700 (PDT)
Message-ID: <3D96580D.A0F803BC@digeo.com>
Date: Sat, 28 Sep 2002 18:31:57 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: suspect list_empty( {NULL, NULL} )
References: <20020928205836.C13817@bitchcake.off.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zach Brown <zab@zabbo.net>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Zach Brown wrote:
> 
> A cute list_head debugging patch seems to have found strange list_entry
> use in vmscan.c in stock 2.5.39.
> 
> page_mapping_inuse:
> 
>         if (!list_empty(&mapping->i_mmap) || !list_empty(&mapping->i_mmap_shared))
> 
> ...
> (gdb) print *mapping
> $22 = {host = 0xc03b6e00

That's swapper_space.


--- 2.5.39/mm/swap_state.c~swapper_space-state	Sat Sep 28 18:30:45 2002
+++ 2.5.39-akpm/mm/swap_state.c	Sat Sep 28 18:31:26 2002
@@ -43,6 +43,8 @@ struct address_space swapper_space = {
 	.a_ops			= &swap_aops,
 	.backing_dev_info	= &swap_backing_dev_info,
 	.i_shared_lock		= SPIN_LOCK_UNLOCKED,
+	.i_mmap			= LIST_HEAD_INIT(swapper_space.i_mmap),
+	.i_mmap_shared		= LIST_HEAD_INIT(swapper_space.i_mmap_shared),
 	.private_lock		= SPIN_LOCK_UNLOCKED,
 	.private_list		= LIST_HEAD_INIT(swapper_space.private_list),
 };

.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
