Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id C7B1C6B0044
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 11:11:36 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 17 Oct 2012 09:11:35 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 9E3963E40055
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 09:11:01 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9HFAtNK037236
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 09:10:56 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9HFA4gj032365
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 09:10:05 -0600
Message-ID: <507ECA43.3070402@linux.vnet.ibm.com>
Date: Wed, 17 Oct 2012 08:09:55 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/5] memory-hotplug: update mce_bad_pages when removing
 the memory
References: <1350475735-26136-1-git-send-email-wency@cn.fujitsu.com> <1350475735-26136-3-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1350475735-26136-3-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Christoph Lameter <cl@linux.com>

Hi Wen,

> +#ifdef CONFIG_MEMORY_FAILURE
> +static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> +{
> +	int i;
> +
> +	if (!memmap)
> +		return;

I guess free_section_usemap() does the same thing.

> +	for (i = 0; i < PAGES_PER_SECTION; i++) {
> +		if (PageHWPoison(&memmap[i])) {
> +			atomic_long_sub(1, &mce_bad_pages);
> +			ClearPageHWPoison(&memmap[i]);
> +		}
> +	}
> +}
> +#endif
> +
>  void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
>  {
>  	struct page *memmap = NULL;
> @@ -786,6 +803,10 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
>  		ms->pageblock_flags = NULL;
>  	}
> 
> +#ifdef CONFIG_MEMORY_FAILURE
> +	clear_hwpoisoned_pages(memmap, PAGES_PER_SECTION);
> +#endif
> +
>  	free_section_usemap(memmap, usemap);
>  }
>  #endif

But why put the call outside the  "if (ms->section_mem_map)" block?  If
you put it inside, then you don't have to check for !memmap in
clear_hwpoisoned_pages().

Also, we really frown on #ifdefs scattered throughout code.  I'd suggest
either:

+static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
+{
+#ifdef CONFIG_MEMORY_FAILURE
... existing code
+#endif /* CONFIG_MEMORY_FAILURE */
+}

or

+#ifdef CONFIG_MEMORY_FAILURE
+static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
+{
... existing code
+}
+#else
+static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
+{}
+#endif /* CONFIG_MEMORY_FAILURE */

and keep the #ifdef out of sparse_remove_one_section().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
