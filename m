Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id D22526B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 22:16:05 -0400 (EDT)
Received: by obcva7 with SMTP id va7so4428833obc.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 19:16:05 -0700 (PDT)
Message-ID: <506659D7.9080904@gmail.com>
Date: Sat, 29 Sep 2012 10:15:51 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v9 PATCH 13/21] memory-hotplug: check page type in get_page_bootmem
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com> <1346837155-534-14-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346837155-534-14-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

On 09/05/2012 05:25 PM, wency@cn.fujitsu.com wrote:
> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>
> The function get_page_bootmem() may be called more than one time to the same
> page. There is no need to set page's type, private if the function is not
> the first time called to the page.
>
> Note: the patch is just optimization and does not fix any problem.

Hi Yasuaki,

this patch is reasonable to me. I have another question associated to 
get_page_bootmem(), the question is from another fujitsu guy's patch 
changelog [commit : 04753278769f3], the changelog said  that:

  1) When the memmap of removing section is allocated on other
      section by bootmem, it should/can be free.
  2) When the memmap of removing section is allocated on the
      same section, it shouldn't be freed. Because the section has to be
      logical memory offlined already and all pages must be isolated against
      page allocater. If it is freed, page allocator may use it which will
      be removed physically soon.

but I don't see his patch guarantee 2), it means that his patch doesn't 
guarantee the memmap of removing section which is allocated on other 
section by bootmem doesn't be freed. Hopefully get your explaination in 
details, thanks in advance. :-)

>
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
>   mm/memory_hotplug.c |   15 +++++++++++----
>   1 files changed, 11 insertions(+), 4 deletions(-)
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d736df3..26a5012 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -95,10 +95,17 @@ static void release_memory_resource(struct resource *res)
>   static void get_page_bootmem(unsigned long info,  struct page *page,
>   			     unsigned long type)
>   {
> -	page->lru.next = (struct list_head *) type;
> -	SetPagePrivate(page);
> -	set_page_private(page, info);
> -	atomic_inc(&page->_count);
> +	unsigned long page_type;
> +
> +	page_type = (unsigned long)page->lru.next;
> +	if (page_type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
> +	    page_type > MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE){
> +		page->lru.next = (struct list_head *)type;
> +		SetPagePrivate(page);
> +		set_page_private(page, info);
> +		atomic_inc(&page->_count);
> +	} else
> +		atomic_inc(&page->_count);
>   }
>   
>   /* reference to __meminit __free_pages_bootmem is valid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
