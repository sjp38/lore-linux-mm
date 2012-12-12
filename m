Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 5D2566B005D
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 04:10:45 -0500 (EST)
Message-ID: <50C849DD.20405@cn.fujitsu.com>
Date: Wed, 12 Dec 2012 17:09:49 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 3/5] page_alloc: Introduce zone_movable_limit[] to
 keep movable limit for nodes
References: <1355193207-21797-1-git-send-email-tangchen@cn.fujitsu.com>  <1355193207-21797-4-git-send-email-tangchen@cn.fujitsu.com>  <50C6A36C.5030606@huawei.com> <50C6A93A.50404@cn.fujitsu.com> <1355225313.1919.1.camel@kernel.cn.ibm.com> <50C7D490.60409@huawei.com>
In-Reply-To: <50C7D490.60409@huawei.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>, Simon Jeons <simon.jeons@gmail.com>
Cc: Jianguo Wu <wujianguo@huawei.com>, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On 12/12/2012 08:49 AM, Jiang Liu wrote:
>>>>> This patch introduces a new array zone_movable_limit[] to store the
>>>>> ZONE_MOVABLE limit from movablecore_map boot option for all nodes.
>>>>> The function sanitize_zone_movable_limit() will find out to which
>>>>> node the ranges in movable_map.map[] belongs, and calculates the
>>>>> low boundary of ZONE_MOVABLE for each node.
>>
>> What's the difference between zone_movable_limit[nid] and
>> zone_movable_pfn[nid]?
> zone_movable_limit[] is a temporary storage for zone_moveable_pfn[].
> It's used to handle a special case if user specifies both movablecore_map
> and movablecore/kernelcore on the kernel command line.
>
Hi Simon, Liu,

Sorry for the late and thanks for your discussion. :)

As Liu said, zone_movable_limit[] is a temporary array for calculation.

If users specified movablecore_map option, zone_movable_limit[] holds
the lowest pfn of ZONE_MOVABLE limited by movablecore_map option. It is 
constant, won't change.

Please refer to find_zone_movable_pfns_for_nodes() in patch4, you will
see that zone_moveable_pfn[] will be changed each time kernel area
increases.

So when kernel area increases on node i, zone_moveable_pfn[i] will
increase. And if zone_moveable_pfn[i] > zone_movable_limit[i], we should
stop allocate memory for kernel on node i. Here, I give movablecore_map 
higher priority than kernelcore/movablecore.

And also, I tried to use zone_moveable_pfn[] to store limits. But when
calculating the kernel area, I still have to store the limits in
temporary variables. I think the code was ugly. So I added an new array.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
