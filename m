Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 79FE46B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 15:28:44 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so3884305obc.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 12:28:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <506E46B6.3060502@jp.fujitsu.com>
References: <506E43E0.70507@jp.fujitsu.com> <506E46B6.3060502@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 12 Oct 2012 15:28:23 -0400
Message-ID: <CAHGf_=raSH5C8ye90F1PLZ8mGQUGggB=J0HYU8UhkKVDTV5JXQ@mail.gmail.com>
Subject: Re: [PATCH 5/10] memory-hotplug : memory-hotplug: check page type in get_page_bootmem
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, wency@cn.fujitsu.com

On Thu, Oct 4, 2012 at 10:32 PM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
> The function get_page_bootmem() may be called more than one time to the same
> page. There is no need to set page's type, private if the function is not
> the first time called to the page.
>
> Note: the patch is just optimization and does not fix any problem.
>
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
>  mm/memory_hotplug.c |   15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
>
> Index: linux-3.6/mm/memory_hotplug.c
> ===================================================================
> --- linux-3.6.orig/mm/memory_hotplug.c  2012-10-04 18:29:58.284676075 +0900
> +++ linux-3.6/mm/memory_hotplug.c       2012-10-04 18:30:03.454680542 +0900
> @@ -95,10 +95,17 @@ static void release_memory_resource(stru
>  static void get_page_bootmem(unsigned long info,  struct page *page,
>                              unsigned long type)
>  {
> -       page->lru.next = (struct list_head *) type;
> -       SetPagePrivate(page);
> -       set_page_private(page, info);
> -       atomic_inc(&page->_count);
> +       unsigned long page_type;
> +
> +       page_type = (unsigned long)page->lru.next;

If I understand correctly, page->lru.next might be uninitialized yet.

Moreover, I have no seen any good effect in this patch. I don't understand
why we need to increase code complexity.



> +       if (page_type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
> +           page_type > MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE){
> +               page->lru.next = (struct list_head *)type;
> +               SetPagePrivate(page);
> +               set_page_private(page, info);
> +               atomic_inc(&page->_count);
> +       } else
> +               atomic_inc(&page->_count);
>  }
>
>  /* reference to __meminit __free_pages_bootmem is valid
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
