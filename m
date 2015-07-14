Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 493BB9003C8
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 04:46:18 -0400 (EDT)
Received: by oibn4 with SMTP id n4so2016247oib.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 01:46:18 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id pk8si279131oeb.91.2015.07.14.01.46.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jul 2015 01:46:17 -0700 (PDT)
Message-ID: <55A4CB68.5060906@huawei.com>
Date: Tue, 14 Jul 2015 16:42:16 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [BUG REPORT] OOM Killer is invoked while the system still has
 much memory
References: <6D317A699782EA4DB9A0E6266C9219696CA2B3BC@SZXEMA501-MBX.china.huawei.com> <20150714081521.GA17711@dhcp22.suse.cz>
In-Reply-To: <20150714081521.GA17711@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Xuzhichuang <xuzhichuang@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Songjiangtao (mygirlsjt)" <songjiangtao.song@huawei.com>, "Zhangwei (FF)" <zw.zhang@huawei.com>

On 2015/7/14 16:15, Michal Hocko wrote:

> On Tue 14-07-15 07:11:34, Xuzhichuang wrote:
>> Hi, all
>>
>> Description of problem:
>>
>> Recently, one of my Linux system invoked oom-killer, but the system
>> still has much memory, I don't know why the system still invoked
>> oom-killer, anybody can help me to see it, thanks.
>>
>> Linux kernel version: 3.0.58
>>
>> Following is the message:
>>
>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138764] iostat invoked oom-killer: gfp_mask=0xd0, order=2, oom_adj=0, oom_score_adj=0
> [...]
>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138945] DMA free:984kB min:36kB low:44kB high:52kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:16160kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138949] lowmem_reserve[]: 0 3014 3014 3014
>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138955] DMA32 free:990352kB min:7004kB low:8752kB high:10504kB active_anon:908444kB inactive_anon:41528kB active_file:812kB inactive_file:756kB unevictable:381580kB isolated(anon):0kB isolated(file):188kB present:3025264kB mlocked:381580kB dirty:0kB writeback:0kB mapped:45940kB shmem:44668kB slab_reclaimable:72748kB slab_unreclaimable:215412kB kernel_stack:12456kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:192 all_unreclaimable? no
> 
> You are well above watermarks but note that you have basically no
> pages on the file LRU and you have _no swap_ so the anon memory is
> unreclaimable. There is still around 72M of reclaimable slab but that
> could be hard to reclaim due to internal fragmentation. The allocation
> request is GFP_KERNEL so the slab shrinkers shouldn't back off due to
> __GFP_FS restrictions.
> 
>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138960] lowmem_reserve[]: 0 0 0 0
>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138962] DMA: 2*4kB 4*8kB 3*16kB 4*32kB 2*64kB 1*128kB 2*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 984kB
>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138968] DMA32: 188513*4kB 29459*8kB 2*16kB 2*32kB 1*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 990396kB
> 
> Moreover your allocation request was oreder 2 and you do not have much
> memory there because most of the free memory is in order-0-2.
> 

Hi Michal,

order=2 -> alloc 16kb memory, and DMA32 still has 2*16kB 2*32kB 1*64kB 1*512kB, 
so you mean this large buddy block was reclaimed during the moment of oom and 
print, right?

Thanks,
Xishi Qiu

>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138974] 12622 total pagecache pages
>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138976] 0 pages in swap cache
>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138977] Swap cache stats: add 0, delete 0, find 0/0
>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138978] Free swap  = 0kB
>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138979] Total swap = 0kB
> 						      ^^^^^^^^^^^^^^^^
> So I am not surprised about the oom killer much.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
