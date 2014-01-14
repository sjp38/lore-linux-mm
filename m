Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f172.google.com (mail-gg0-f172.google.com [209.85.161.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA566B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 07:21:39 -0500 (EST)
Received: by mail-gg0-f172.google.com with SMTP id x14so77846ggx.3
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 04:21:39 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id t7si450986qar.123.2014.01.14.04.21.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 04:21:38 -0800 (PST)
Message-ID: <52D538FD.8010907@ti.com>
Date: Tue, 14 Jan 2014 15:17:49 +0200
From: Grygorii Strashko <grygorii.strashko@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 2/2] mm/memblock: Add support for excluded memory areas
References: <1389618217-48166-1-git-send-email-phacht@linux.vnet.ibm.com> <1389618217-48166-3-git-send-email-phacht@linux.vnet.ibm.com>
In-Reply-To: <1389618217-48166-3-git-send-email-phacht@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, qiuxishi@huawei.com, dhowells@redhat.com, daeseok.youn@gmail.com, liuj97@gmail.com, yinghai@kernel.org, zhangyanfei@cn.fujitsu.com, santosh.shilimkar@ti.com, tangchen@cn.fujitsu.com

Hi Philipp,

On 01/13/2014 03:03 PM, Philipp Hachtmann wrote:
> Add a new memory state "nomap" to memblock. This can be used to truncate
> the usable memory in the system without forgetting about what is really
> installed.


Sorry, but this solution looks a bit complex (and probably wrong - from design point of view))
if you need just to fix memblock_start_of_DRAM()/memblock_end_of_DRAM() APIs.

More over, other arches use at least below APIs: 
- memblock_is_region_memory() !!!
- for_each_memblock(memory, reg) !!!
- __next_mem_pfn_range() !!!
- memblock_phys_mem_size()
- memblock_mem_size()
- memblock_start_of_DRAM()
- memblock_end_of_DRAM()
with assumption that "memory" regions array have been updated
when mem block is stolen (no-mapped), as result this change may
have unpredictable side effects :( if these new APIs
will be re-used (for ARM arch, as example).

You can take a look on how ARM is using arm_memblock_steal() - 
the stolen memory is not accounted any more.

Seems, it would be safer to track separately memory, available
for Linux ("memory" regions), and real phys memory. For example:
- add memblock type "phys_memory" and update it each time
 memblock_add()/memblock_remove() are called,
but don't update, if memblock_nomap()/memblock_remap() are called?

Another question is - Should the real phys memory configuration data be
a part of memblock or not?

Also, I like more memblock_steal()/memblock_reclaim() names for new APIs )

regards,
-grygorii

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
