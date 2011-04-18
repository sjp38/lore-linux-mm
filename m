Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 94845900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 04:18:15 -0400 (EDT)
Date: Mon, 18 Apr 2011 16:18:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/12] IO-less dirty throttling v7
Message-ID: <20110418081808.GA10374@localhost>
References: <20110416132546.765212221@intel.com>
 <BANLkTimY3t6Kc-+=00k3QR+AK2uqJpph4g@mail.gmail.com>
 <20110417014430.GA9419@localhost>
 <BANLkTik+Bcw7uz9aMi6OrAzwg1rJZmJL0Q@mail.gmail.com>
 <20110417041003.GA17032@localhost>
 <20110418001333.GA8890@localhost>
 <BANLkTinQoTgQR_hPGo6vEHbS-rGypkAmZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Content-Disposition: inline
In-Reply-To: <BANLkTinQoTgQR_hPGo6vEHbS-rGypkAmZw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

> Unfortunately, this "v2" patch still breaks with gcc-4.6 here:
> 
>   LD      .tmp_vmlinux1
> mm/built-in.o: In function `calc_period_shift.part.10':
> page-writeback.c:(.text+0x6458): undefined reference to `____ilog2_NaN'
> make[4]: *** [.tmp_vmlinux1] Error 1
> 
> My patchset against next-20110415 looks like this:
> 
>   (+) OK   writeback-dirty-throttling-v7/writeback-dirty-throttling-v7.patch
>   (+) OK   writeback-dirty-throttling-post-v7/0001-writeback-i386-compile-fix.patch
>   (+) OK   writeback-dirty-throttling-post-v7/0002-writeback-quick-CONFIG_BLK_DEV_THROTTLING-n-compile-.patch
>   (+) OK   writeback-dirty-throttling-post-v7/0003-Revert-writeback-scale-dirty-proportions-period-with.patch
>   (+) OK   writeback-dirty-throttling-v7-fix/writeback-scale-dirty-proportions-period-with-writeout-bandwidth-v2.patch
> 
> Attached are the disasm of mm/page-writeback.o (v2, gcc-4.6) and the
> disasm of yesterday's experiments with gcc-4.5.
> 
> [ gcc-4.5 ]
> 
> 00006574 <calc_period_shift>:
>     6574:       a1 90 00 00 00          mov    0x90,%eax        6575:
> R_386_32  default_backing_dev_info
>     6579:       55                      push   %ebp
>     657a:       89 e5                   mov    %esp,%ebp
>     657c:       e8 02 f8 ff ff          call   5d83 <__ilog2_u32>
>     6581:       5d                      pop    %ebp
>     6582:       83 c0 02                add    $0x2,%eax
>     6585:       c3                      ret

gcc-4.5 is generating the right code, while the below silly macro
expansion seems like __builtin_constant_p(n) wrongly evaluating to true.
I wonder if the attached patch will workaround the gcc's bug. It adds a
local variable in calc_period_shift() for passing to ilog2().

Thanks,
Fengguang

> [ gcc-4.6 ]
> 
> 000008c9 <calc_period_shift.part.10>:
>      8c9:       8b 15 90 00 00 00       mov    0x90,%edx        8cb:
> R_386_32   default_backing_dev_info
>      8cf:       55                      push   %ebp
>      8d0:       89 e5                   mov    %esp,%ebp
>      8d2:       85 d2                   test   %edx,%edx
>      8d4:       0f 88 46 01 00 00       js     a20
> <calc_period_shift.part.10+0x157>
>      8da:       f7 c2 00 00 00 40       test   $0x40000000,%edx
>      8e0:       b8 20 00 00 00          mov    $0x20,%eax
>      8e5:       0f 85 3a 01 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      8eb:       f7 c2 00 00 00 20       test   $0x20000000,%edx
>      8f1:       b0 1f                   mov    $0x1f,%al
>      8f3:       0f 85 2c 01 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      8f9:       f7 c2 00 00 00 10       test   $0x10000000,%edx
>      8ff:       b0 1e                   mov    $0x1e,%al
>      901:       0f 85 1e 01 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      907:       f7 c2 00 00 00 08       test   $0x8000000,%edx
>      90d:       b0 1d                   mov    $0x1d,%al
>      90f:       0f 85 10 01 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      915:       f7 c2 00 00 00 04       test   $0x4000000,%edx
>      91b:       b0 1c                   mov    $0x1c,%al
>      91d:       0f 85 02 01 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      923:       f7 c2 00 00 00 02       test   $0x2000000,%edx
>      929:       b0 1b                   mov    $0x1b,%al
>      92b:       0f 85 f4 00 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      931:       f7 c2 00 00 00 01       test   $0x1000000,%edx
>      937:       b0 1a                   mov    $0x1a,%al
>      939:       0f 85 e6 00 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      93f:       f7 c2 00 00 80 00       test   $0x800000,%edx
>      945:       b0 19                   mov    $0x19,%al
>      947:       0f 85 d8 00 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      94d:       f7 c2 00 00 40 00       test   $0x400000,%edx
>      953:       b0 18                   mov    $0x18,%al
>      955:       0f 85 ca 00 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      95b:       f7 c2 00 00 20 00       test   $0x200000,%edx
>      961:       b0 17                   mov    $0x17,%al
>      963:       0f 85 bc 00 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      969:       f7 c2 00 00 10 00       test   $0x100000,%edx
>      96f:       b0 16                   mov    $0x16,%al
>      971:       0f 85 ae 00 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      977:       f7 c2 00 00 08 00       test   $0x80000,%edx
>      97d:       b0 15                   mov    $0x15,%al
>      97f:       0f 85 a0 00 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      985:       f7 c2 00 00 04 00       test   $0x40000,%edx
>      98b:       b0 14                   mov    $0x14,%al
>      98d:       0f 85 92 00 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      993:       f7 c2 00 00 02 00       test   $0x20000,%edx
>      999:       b0 13                   mov    $0x13,%al
>      99b:       0f 85 84 00 00 00       jne    a25
> <calc_period_shift.part.10+0x15c>
>      9a1:       f7 c2 00 00 01 00       test   $0x10000,%edx
>      9a7:       b0 12                   mov    $0x12,%al
>      9a9:       75 7a                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9ab:       f6 c6 80                test   $0x80,%dh
>      9ae:       b0 11                   mov    $0x11,%al
>      9b0:       75 73                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9b2:       f6 c6 40                test   $0x40,%dh
>      9b5:       b0 10                   mov    $0x10,%al
>      9b7:       75 6c                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9b9:       f6 c6 20                test   $0x20,%dh
>      9bc:       b0 0f                   mov    $0xf,%al
>      9be:       75 65                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9c0:       f6 c6 10                test   $0x10,%dh
>      9c3:       b0 0e                   mov    $0xe,%al
>      9c5:       75 5e                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9c7:       f6 c6 08                test   $0x8,%dh
>      9ca:       b0 0d                   mov    $0xd,%al
>      9cc:       75 57                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9ce:       f6 c6 04                test   $0x4,%dh
>      9d1:       b0 0c                   mov    $0xc,%al
>      9d3:       75 50                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9d5:       f6 c6 02                test   $0x2,%dh
>      9d8:       b0 0b                   mov    $0xb,%al
>      9da:       75 49                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9dc:       f6 c6 01                test   $0x1,%dh
>      9df:       b0 0a                   mov    $0xa,%al
>      9e1:       75 42                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9e3:       f6 c2 80                test   $0x80,%dl
>      9e6:       b0 09                   mov    $0x9,%al
>      9e8:       75 3b                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9ea:       f6 c2 40                test   $0x40,%dl
>      9ed:       b0 08                   mov    $0x8,%al
>      9ef:       75 34                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9f1:       f6 c2 20                test   $0x20,%dl
>      9f4:       b0 07                   mov    $0x7,%al
>      9f6:       75 2d                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9f8:       f6 c2 10                test   $0x10,%dl
>      9fb:       b0 06                   mov    $0x6,%al
>      9fd:       75 26                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      9ff:       f6 c2 08                test   $0x8,%dl
>      a02:       b0 05                   mov    $0x5,%al
>      a04:       75 1f                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      a06:       f6 c2 04                test   $0x4,%dl
>      a09:       b0 04                   mov    $0x4,%al
>      a0b:       75 18                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      a0d:       f6 c2 02                test   $0x2,%dl
>      a10:       b0 03                   mov    $0x3,%al
>      a12:       75 11                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      a14:       80 e2 01                and    $0x1,%dl
>      a17:       b0 02                   mov    $0x2,%al
>      a19:       75 0a                   jne    a25
> <calc_period_shift.part.10+0x15c>
>      a1b:       e8 fc ff ff ff          call   a1c
> <calc_period_shift.part.10+0x153>    a1c: R_386_PC32 ____ilog2_NaN
>      a20:       b8 21 00 00 00          mov    $0x21,%eax
>      a25:       5d                      pop    %ebp
>      a26:       c3                      ret
> 
> 00000a27 <calc_period_shift>:
>      a27:       55                      push   %ebp
>      a28:       83 ca ff                or     $0xffffffff,%edx
>      a2b:       89 e5                   mov    %esp,%ebp
>      a2d:       0f bd 05 90 00 00 00    bsr    0x90,%eax        a30:
> R_386_32   default_backing_dev_info
>      a34:       0f 44 c2                cmove  %edx,%eax
>      a37:       5d                      pop    %ebp
>      a38:       83 c0 02                add    $0x2,%eax
>      a3b:       c3                      ret
> 
> - EOT -
> 
> - Sedat -




--vtzGhvizbBRQ85DL
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="writeback-adaptive-proportions-shift.patch"

Subject: writeback: scale dirty proportions period with writeout bandwidth
Date: Sat Apr 16 18:38:41 CST 2011

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-04-17 20:52:13.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-18 16:06:03.000000000 +0800
@@ -121,20 +121,15 @@ static struct prop_descriptor vm_complet
 static struct prop_descriptor vm_dirties;
 
 /*
- * couple the period to the dirty_ratio:
+ * couple the period to global write throughput:
  *
- *   period/2 ~ roundup_pow_of_two(dirty limit)
+ *   period/2 ~ roundup_pow_of_two(write IO throughput)
  */
 static int calc_period_shift(void)
 {
-	unsigned long dirty_total;
+	unsigned long bw = default_backing_dev_info.avg_write_bandwidth;
 
-	if (vm_dirty_bytes)
-		dirty_total = vm_dirty_bytes / PAGE_SIZE;
-	else
-		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
-				100;
-	return 2 + ilog2(dirty_total - 1);
+	return 2 + ilog2(bw);
 }
 
 /*
@@ -143,6 +138,14 @@ static int calc_period_shift(void)
 static void update_completion_period(void)
 {
 	int shift = calc_period_shift();
+
+	if (shift > PROP_MAX_SHIFT)
+		shift = PROP_MAX_SHIFT;
+
+	if (shift <= vm_completions.pg[0].shift &&
+	    shift >  vm_completions.pg[0].shift / 4)
+		return;
+
 	prop_change_shift(&vm_completions, shift);
 	prop_change_shift(&vm_dirties, shift);
 }
@@ -180,7 +183,6 @@ int dirty_ratio_handler(struct ctl_table
 
 	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
-		update_completion_period();
 		vm_dirty_bytes = 0;
 	}
 	return ret;
@@ -196,7 +198,6 @@ int dirty_bytes_handler(struct ctl_table
 
 	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write && vm_dirty_bytes != old_bytes) {
-		update_completion_period();
 		vm_dirty_ratio = 0;
 	}
 	return ret;
@@ -1044,6 +1045,8 @@ snapshot:
 	bdi->bw_time_stamp = now;
 unlock:
 	spin_unlock(&dirty_lock);
+	if (gbdi->bw_time_stamp == now)
+		update_completion_period();
 }
 
 static unsigned long max_pause(struct backing_dev_info *bdi,

--vtzGhvizbBRQ85DL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
