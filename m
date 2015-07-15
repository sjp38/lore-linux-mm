Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2E7280276
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 21:57:17 -0400 (EDT)
Received: by iggp10 with SMTP id p10so111439769igg.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 18:57:17 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id u84si2284101ioi.167.2015.07.14.18.57.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 18:57:16 -0700 (PDT)
Received: by igcqs7 with SMTP id qs7so96068276igc.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 18:57:16 -0700 (PDT)
Date: Tue, 14 Jul 2015 18:57:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: =?UTF-8?Q?Re=3A_=E7=AD=94=E5=A4=8D=3A_=5BBUG_REPORT=5D_OOM_Killer_is_invoked_while_the_system_still_has_much_memory?=
In-Reply-To: <6D317A699782EA4DB9A0E6266C9219696CA2B45B@SZXEMA501-MBX.china.huawei.com>
Message-ID: <alpine.DEB.2.10.1507141855200.6993@chino.kir.corp.google.com>
References: <6D317A699782EA4DB9A0E6266C9219696CA2B3BC@SZXEMA501-MBX.china.huawei.com> <alpine.DEB.2.10.1507141701290.16182@chino.kir.corp.google.com> <6D317A699782EA4DB9A0E6266C9219696CA2B45B@SZXEMA501-MBX.china.huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xuzhichuang <xuzhichuang@huawei.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Songjiangtao (mygirlsjt)" <songjiangtao.song@huawei.com>, "Zhangwei (FF)" <zw.zhang@huawei.com>, Qiuxishi <qiuxishi@huawei.com>

On Wed, 15 Jul 2015, Xuzhichuang wrote:

> Hi,
> 
> Thanks for your replying.
> 
> According to the OOM message, OOM killer is invoked by the function seq_read, I found two patches in the latest kernel which can be avoid or fixed this problem.
> 
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/fs/seq_file.c?id=058504edd02667eef8fac9be27ab3ea74332e9b4
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/fs/seq_file.c?id=5cec38ac866bfb8775638e71a86e4d8cac30caae
> 
> As the patches said, it changed the seq_file code fallback to vmalloc allocations if kmalloc failed, instead of OOM kill processes.
> 

Yes, we use those two patches as well internally.  You may want to give 
them a try if this is the only source of oom killer issues, but keep in 
mind that other subsystems like the tcp layer will often do high-order 
allocations as well.  If you can free up some of that ZONE_DMA memory that 
is unneeded with lowmem_reserve_ratio, you might get a little more room.  

Good luck!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
