Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 457236B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 00:49:14 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C340B3EE0C0
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:49:11 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E39D45DE9D
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:49:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8025445DE97
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:49:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 63BD1E18003
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:49:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1396EE08003
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:49:11 +0900 (JST)
Message-ID: <4DE4733F.3030207@jp.fujitsu.com>
Date: Tue, 31 May 2011 13:49:03 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system have
 > gigabytes memory  (aka CAI founded issue)
References: <1582158305.317043.1306815272554.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1582158305.317043.1306815272554.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: caiqian@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

> OK, there was also a panic at the end. Is that expected?
> 
> BUG: unable to handle kernel NULL pointer dereference at 00000000000002a8
> IP: [<ffffffff811227d4>] get_mm_counter+0x14/0x30
> PGD 0 
> Oops: 0000 [#1] SMP 
> CPU 7 
> Modules linked in: autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ipv6 dm_mirror dm_region_hash dm_log microcode serio_raw pcspkr cdc_ether usbnet mii i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support sg shpchp ioatdma dca i7core_edac edac_core bnx2 ext4 mbcache jbd2 sd_mod crc_t10dif pata_acpi ata_generic ata_piix mptsas mptscsih mptbase scsi_transport_sas dm_mod [last unloaded: scsi_wait_scan]

My fault. my [1/5] has a bug. please apply following incremental patch.


index 9c7f149..f0e34d4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -448,8 +448,8 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *no
                        task_tgid_nr(task), task_tgid_nr(task->real_parent),
                        task_uid(task),
                        task->mm->total_vm,
-                       get_mm_rss(task->mm) + p->mm->nr_ptes,
-                       get_mm_counter(p->mm, MM_SWAPENTS),
+                       get_mm_rss(task->mm) + task->mm->nr_ptes,
+                       get_mm_counter(task->mm, MM_SWAPENTS),
                        task->signal->oom_score_adj,
                        task->comm);
                task_unlock(task);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
