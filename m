Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 133796B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 10:42:28 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so1926564pde.32
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 07:42:27 -0700 (PDT)
Message-ID: <51AF4E3F.1010102@gmail.com>
Date: Wed, 05 Jun 2013 22:42:07 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: mmots: mm-correctly-update-zone-managed_pages-fix.patch breaks
 compilation
References: <20130605111607.GM15997@dhcp22.suse.cz>
In-Reply-To: <20130605111607.GM15997@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, "Michael S. Tsirkin" <mst@redhat.com>, sworddragon2@aol.com, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, David Howells <dhowells@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ingo Molnar <mingo@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jiang Liu <jiang.liu@huawei.com>, Jianguo Wu <wujianguo@huawei.com>, Joonsoo Kim <js1304@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <rmk@arm.linux.org.uk>, Rusty Russell <rusty@rustcorp.com.au>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Wen Congyang <wency@cn.fujitsu.com>, Will Deacon <will.deacon@arm.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 06/05/2013 07:16 PM, Michal Hocko wrote:
> Hi Andrew,
> the above patch breaks compilation:
> mm/page_alloc.c: In function a??adjust_managed_page_counta??:
> mm/page_alloc.c:5226: error: lvalue required as left operand of assignment
> 
> Could you drop the mm/page_alloc.c hunk, please? Not all versions of gcc
> are able to cope with this obviously (mine is 4.3.4).
> 
> Thanks
> 
Hi Andrew,

When CONFIG_HIGHMEM is undefined, totalhigh_pages is defined as:
#define totalhigh_pages 0UL
Thus statement "totalhigh_pages += count" will cause build failure as:
  CC      mm/page_alloc.o
mm/page_alloc.c: In function a??adjust_managed_page_counta??:
mm/page_alloc.c:5262:19: error: lvalue required as left operand of
assignment
make[1]: *** [mm/page_alloc.o] Error 1
make: *** [mm/page_alloc.o] Error 2

So we still need to use CONFIG_HIGHMEM to guard the statement.
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3437f7a..860d639 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5258,8 +5258,10 @@ void adjust_managed_page_count(struct page *page,
long count)
        spin_lock(&managed_page_count_lock);
        page_zone(page)->managed_pages += count;
        totalram_pages += count;
+#ifdef CONFIG_HIGHMEM
        if (PageHighMem(page))
                totalhigh_pages += count;
+#endif
        spin_unlock(&managed_page_count_lock);
 }
 EXPORT_SYMBOL(adjust_managed_page_count);
---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
