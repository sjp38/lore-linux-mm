Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 79F548D0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 19:39:58 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 096EC3EE0D1
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:39:57 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD91645DEBB
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:39:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BB1AE45DEB7
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:39:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ABDE41DB8042
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:39:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FB1B1DB803F
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:39:56 +0900 (JST)
Message-ID: <50DCEA3D.1030501@jp.fujitsu.com>
Date: Fri, 28 Dec 2012 09:39:25 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 2/8] Make TestSetPageDirty and dirty page accounting
 in one func
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com> <1356456156-14535-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1356456156-14535-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

(2012/12/26 2:22), Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Commit a8e7d49a(Fix race in create_empty_buffers() vs __set_page_dirty_buffers())
> extracts TestSetPageDirty from __set_page_dirty and is far away from
> account_page_dirtied. But it's better to make the two operations in one single
> function to keep modular. So in order to avoid the potential race mentioned in
> commit a8e7d49a, we can hold private_lock until __set_page_dirty completes.
> There's no deadlock between ->private_lock and ->tree_lock after confirmation.
> It's a prepare patch for following memcg dirty page accounting patches.
> 
> 
> Here is some test numbers that before/after this patch:
> Test steps(Mem-4g, ext4):
> drop_cache; sync
> fio (ioengine=sync/write/buffered/bs=4k/size=1g/numjobs=2/group_reporting/thread)
> 
> We test it for 10 times and get the average numbers:
> Before:
> write: io=2048.0MB, bw=254117KB/s, iops=63528.9 , runt=  8279msec
> lat (usec): min=1 , max=742361 , avg=30.918, stdev=1601.02
> After:
> write: io=2048.0MB, bw=254044KB/s, iops=63510.3 , runt=  8274.4msec
> lat (usec): min=1 , max=856333 , avg=31.043, stdev=1769.32
> 
> Note that the impact is little(<1%).
> 
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hmm,..this change should be double-checked by vfs, I/O guys...

increasing hold time of mapping->private_lock doesn't affect performance ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
