Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 497176B0083
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 04:35:04 -0500 (EST)
Message-ID: <50BDC38C.1060209@cn.fujitsu.com>
Date: Tue, 04 Dec 2012 17:34:04 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch v4 06/12] memory-hotplug: unregister memory section on
 SPARSEMEM_VMEMMAP
References: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com> <1354010422-19648-7-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1354010422-19648-7-git-send-email-wency@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>

On 11/27/2012 06:00 PM, Wen Congyang wrote:
> From: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
>
> Currently __remove_section for SPARSEMEM_VMEMMAP does nothing. But even if
> we use SPARSEMEM_VMEMMAP, we can unregister the memory_section.
>
> So the patch add unregister_memory_section() into __remove_section().
>
> CC: David Rientjes<rientjes@google.com>
> CC: Jiang Liu<liuj97@gmail.com>
> CC: Len Brown<len.brown@intel.com>
> CC: Christoph Lameter<cl@linux.com>
> Cc: Minchan Kim<minchan.kim@gmail.com>
> CC: Andrew Morton<akpm@linux-foundation.org>
> CC: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang<wency@cn.fujitsu.com>

__remove_section() of CONFIG_SPARSEMEM_VMEMMAP will be integrated
into one in [PATCH 08/12], so I think we can merge this patch into
[PATCH 08/12].

Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>

> ---
>   mm/memory_hotplug.c | 13 ++++++++-----
>   1 file changed, 8 insertions(+), 5 deletions(-)
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e741732..171610d 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -279,11 +279,14 @@ static int __meminit __add_section(int nid, struct zone *zone,
>   #ifdef CONFIG_SPARSEMEM_VMEMMAP
>   static int __remove_section(struct zone *zone, struct mem_section *ms)
>   {
> -	/*
> -	 * XXX: Freeing memmap with vmemmap is not implement yet.
> -	 *      This should be removed later.
> -	 */
> -	return -EBUSY;
> +	int ret = -EINVAL;
> +
> +	if (!valid_section(ms))
> +		return ret;
> +
> +	ret = unregister_memory_section(ms);
> +
> +	return ret;
>   }
>   #else
>   static int __remove_section(struct zone *zone, struct mem_section *ms)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
