Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 289C76B00A6
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 18:26:54 -0500 (EST)
Date: Mon, 4 Feb 2013 15:26:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] acpi, memory-hotplug: Support getting hotplug info
 from SRAT.
Message-Id: <20130204152651.2bca8dba.akpm@linux-foundation.org>
In-Reply-To: <1359106929-3034-4-git-send-email-tangchen@cn.fujitsu.com>
References: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com>
	<1359106929-3034-4-git-send-email-tangchen@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 25 Jan 2013 17:42:09 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> We now provide an option for users who don't want to specify physical
> memory address in kernel commandline.
> 
>         /*
>          * For movablemem_map=acpi:
>          *
>          * SRAT:                |_____| |_____| |_________| |_________| ......
>          * node id:                0       1         1           2
>          * hotpluggable:           n       y         y           n
>          * movablemem_map:              |_____| |_________|
>          *
>          * Using movablemem_map, we can prevent memblock from allocating memory
>          * on ZONE_MOVABLE at boot time.
>          */
> 
> So user just specify movablemem_map=acpi, and the kernel will use hotpluggable
> info in SRAT to determine which memory ranges should be set as ZONE_MOVABLE.
> 
> ...
>  
> +	if (!strncmp(p, "acpi", max(4, strlen(p))))
> +		movablemem_map.acpi = true;

Generates a warning:

mm/page_alloc.c: In function 'cmdline_parse_movablemem_map':
mm/page_alloc.c:5312: warning: comparison of distinct pointer types lacks a cast

due to max(int, size_t).

This is easily fixed, but the code looks rather pointless.  If the
incoming string is supposed to be exactly "acpi" then use strcmp().  If
the incoming string must start with "acpi" then use strncmp(p, "acpi", 4).

IOW, the max is unneeded?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
