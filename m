Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 619196B0258
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 04:15:26 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so7473216wic.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 01:15:25 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id gz6si402861wjc.171.2015.07.14.01.15.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 01:15:24 -0700 (PDT)
Received: by wiga1 with SMTP id a1so91759577wig.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 01:15:23 -0700 (PDT)
Date: Tue, 14 Jul 2015 10:15:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [BUG REPORT] OOM Killer is invoked while the system still has
 much memory
Message-ID: <20150714081521.GA17711@dhcp22.suse.cz>
References: <6D317A699782EA4DB9A0E6266C9219696CA2B3BC@SZXEMA501-MBX.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6D317A699782EA4DB9A0E6266C9219696CA2B3BC@SZXEMA501-MBX.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xuzhichuang <xuzhichuang@huawei.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Songjiangtao (mygirlsjt)" <songjiangtao.song@huawei.com>, "Zhangwei (FF)" <zw.zhang@huawei.com>, Qiuxishi <qiuxishi@huawei.com>

On Tue 14-07-15 07:11:34, Xuzhichuang wrote:
> Hi, all
> 
> Description of problem:
> 
> Recently, one of my Linux system invoked oom-killer, but the system
> still has much memory, I don't know why the system still invoked
> oom-killer, anybody can help me to see it, thanks.
> 
> Linux kernel version: 3.0.58
> 
> Following is the message:
> 
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138764] iostat invoked oom-killer: gfp_mask=0xd0, order=2, oom_adj=0, oom_score_adj=0
[...]
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138945] DMA free:984kB min:36kB low:44kB high:52kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:16160kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138949] lowmem_reserve[]: 0 3014 3014 3014
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138955] DMA32 free:990352kB min:7004kB low:8752kB high:10504kB active_anon:908444kB inactive_anon:41528kB active_file:812kB inactive_file:756kB unevictable:381580kB isolated(anon):0kB isolated(file):188kB present:3025264kB mlocked:381580kB dirty:0kB writeback:0kB mapped:45940kB shmem:44668kB slab_reclaimable:72748kB slab_unreclaimable:215412kB kernel_stack:12456kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:192 all_unreclaimable? no

You are well above watermarks but note that you have basically no
pages on the file LRU and you have _no swap_ so the anon memory is
unreclaimable. There is still around 72M of reclaimable slab but that
could be hard to reclaim due to internal fragmentation. The allocation
request is GFP_KERNEL so the slab shrinkers shouldn't back off due to
__GFP_FS restrictions.

> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138960] lowmem_reserve[]: 0 0 0 0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138962] DMA: 2*4kB 4*8kB 3*16kB 4*32kB 2*64kB 1*128kB 2*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 984kB
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138968] DMA32: 188513*4kB 29459*8kB 2*16kB 2*32kB 1*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 990396kB

Moreover your allocation request was oreder 2 and you do not have much
memory there because most of the free memory is in order-0-2.

> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138974] 12622 total pagecache pages
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138976] 0 pages in swap cache
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138977] Swap cache stats: add 0, delete 0, find 0/0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138978] Free swap  = 0kB
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138979] Total swap = 0kB
						      ^^^^^^^^^^^^^^^^
So I am not surprised about the oom killer much.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
