Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 32A576B0062
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 12:11:37 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id c13so1654316eek.3
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 09:11:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d41si15981815eep.29.2014.01.16.09.11.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 09:11:36 -0800 (PST)
Date: Thu, 16 Jan 2014 17:11:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH RESEND part2 v2 1/8] x86: get pg_data_t's memory from
 other node
Message-ID: <20140116171112.GB24740@suse.de>
References: <529D3FC0.6000403@cn.fujitsu.com>
 <529D4048.9070000@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <529D4048.9070000@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

On Tue, Dec 03, 2013 at 10:22:00AM +0800, Zhang Yanfei wrote:
> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> If system can create movable node which all memory of the node is allocated
> as ZONE_MOVABLE, setup_node_data() cannot allocate memory for the node's
> pg_data_t. So, invoke memblock_alloc_nid(...MAX_NUMNODES) again to retry when
> the first allocation fails. Otherwise, the system could failed to boot.
> (We don't use memblock_alloc_try_nid() to retry because in this function,
> if the allocation fails, it will panic the system.)
> 

This implies that it is possible to ahve a configuration with a big ratio
difference between Normal:Movable memory. In such configurations there
would be a risk that the system will reclaim heavily or go OOM because
the kernrel cannot allocate memory due to a relatively small Normal
zone. What protects against that? Is the user ever warned if the ratio
between Normal:Movable very high? The movable_node boot parameter still
turns the feature on and off, there appears to be no way of controlling
the ratio of memory other than booting with the minimum amount of memory
and manually hot-adding the sections to set the appropriate ratio.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
