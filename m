Date: Wed, 27 Aug 2003 12:41:20 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Some errors with 2.6.0-test4-mm2
Message-Id: <20030827124120.2f93c976.akpm@osdl.org>
In-Reply-To: <200308271047.47794.mafteah@mafteah.co.il>
References: <200308271047.47794.mafteah@mafteah.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Okrain Genady <mafteah@mafteah.co.il>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Okrain Genady <mafteah@mafteah.co.il> wrote:
>
> This error started with -mm2:
> 
> # lilo
> <1>Unable to handle kernel NULL pointer dereference at virtual address 
> 00000000
>  printing eip:
> c029f9b2
> *pde = 00000000
> Oops: 0000 [#4]
> PREEMPT
> CPU:    0
> EIP:    0060:[<c029f9b2>]    Tainted: PF  VLI
> EFLAGS: 00010246
> EIP is at generic_ide_ioctl+0x352/0x8b0
> eax: 00000000   ebx: bfffec70   ecx: 0000e7a2   edx: 00000000
> esi: bfffec68   edi: c87ca000   ebp: c87cbf68   esp: c87cbf2c
> ds: 007b   es: 007b   ss: 0068
> Process lilo (pid: 5503, threadinfo=c87ca000 task=c8eac080)
> Stack: c03c76db 0000064e c7853200 fffffff2 00000000 00000000 e7a20003 c04ccb8c
>        cfa7e000 c87cbf9c c0153b66 cf5ae6c0 cfd33e40 c02a3a60 cf619680 c87cbf90
>        c0268235 cfd33e40 00000301 bfffec68 bfffec68 00000001 00000301 c7853200
> Call Trace:
>  [<c0153b66>] filp_open+0x66/0x70
>  [<c02a3a60>] idedisk_ioctl+0x0/0x30

Al has sent through a fix for this.


diff -puN include/linux/genhd.h~large-dev_t-12-fix include/linux/genhd.h
--- 25/include/linux/genhd.h~large-dev_t-12-fix	2003-08-27 10:36:32.000000000 -0700
+++ 25-akpm/include/linux/genhd.h	2003-08-27 10:36:32.000000000 -0700
@@ -197,7 +197,7 @@ extern void rand_initialize_disk(struct 
 
 static inline sector_t get_start_sect(struct block_device *bdev)
 {
-	return bdev->bd_part->start_sect;
+	return bdev->bd_contains == bdev ? 0 : bdev->bd_part->start_sect;
 }
 static inline sector_t get_capacity(struct gendisk *disk)
 {

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
