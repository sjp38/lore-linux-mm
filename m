Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 475C96B0044
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 18:20:10 -0400 (EDT)
Date: Thu, 18 Oct 2012 15:20:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/5] memory-hotplug: update mce_bad_pages when
 removing the memory
Message-Id: <20121018152008.ada8fea5.akpm@linux-foundation.org>
In-Reply-To: <507ECA43.3070402@linux.vnet.ibm.com>
References: <1350475735-26136-1-git-send-email-wency@cn.fujitsu.com>
	<1350475735-26136-3-git-send-email-wency@cn.fujitsu.com>
	<507ECA43.3070402@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Christoph Lameter <cl@linux.com>

On Wed, 17 Oct 2012 08:09:55 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> Hi Wen,
> 
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> > +{
> > +	int i;
> > +
> > +	if (!memmap)
> > +		return;
> 
> I guess free_section_usemap() does the same thing.

What does this observation mean?

> > +	for (i = 0; i < PAGES_PER_SECTION; i++) {
> > +		if (PageHWPoison(&memmap[i])) {
> > +			atomic_long_sub(1, &mce_bad_pages);
> > +			ClearPageHWPoison(&memmap[i]);
> > +		}
> > +	}
> > +}
> > +#endif
> > +
> >  void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
> >  {
> >  	struct page *memmap = NULL;
>
> ..
>
> and keep the #ifdef out of sparse_remove_one_section().

yup.

--- a/mm/sparse.c~memory-hotplug-update-mce_bad_pages-when-removing-the-memory-fix
+++ a/mm/sparse.c
@@ -788,6 +788,10 @@ static void clear_hwpoisoned_pages(struc
 		}
 	}
 }
+#else
+static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
+{
+}
 #endif
 
 void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
@@ -803,10 +807,7 @@ void sparse_remove_one_section(struct zo
 		ms->pageblock_flags = NULL;
 	}
 
-#ifdef CONFIG_MEMORY_FAILURE
 	clear_hwpoisoned_pages(memmap, PAGES_PER_SECTION);
-#endif
-
 	free_section_usemap(memmap, usemap);
 }
 #endif
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
