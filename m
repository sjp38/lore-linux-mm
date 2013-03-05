Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id D22586B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 14:47:25 -0500 (EST)
Date: Tue, 5 Mar 2013 20:47:22 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC PATCH v1 01/33] mm: introduce common help functions to
	deal with reserved/managed pages
Message-ID: <20130305194722.GA12225@merkur.ravnborg.org>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com> <1362495317-32682-2-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1362495317-32682-2-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, Anatolij Gustschin <agust@denx.de>, Aurelien Jacquiot <a-jacquiot@ti.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Chen Liqin <liqin.chen@sunplusct.com>, Chris Metcalf <cmetcalf@tilera.com>, Chris Zankel <chris@zankel.net>, David Howells <dhowells@redhat.com>, "David S. Miller" <davem@davemloft.net>, Eric Biederman <ebiederm@xmission.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Heiko Carstens <heiko.carstens@de.ibm.com>, Helge Deller <deller@gmx.de>, Hirokazu Takata <takata@linux-m32r.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jonas Bonn <jonas@southpole.se>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Lennox Wu <lennox.wu@gmail.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Simek <monstr@monstr.eu>, Michel Lespinasse <walken@google.com>, Mikael Starvik <starvik@axis.com>, Mike Frysinger <vapier@gentoo.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, Ralf Baechle <ralf@linux-mips.org>, Richard Henderson <rth@twiddle.net>, Rik van Riel <riel@redhat.com>, Russell King <linux@arm.linux.org.uk>, Rusty Russell <rusty@rustcorp.com.au>, Tang Chen <tangchen@cn.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, x86@kernel.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, virtualization@lists.linux-foundation.org

On Tue, Mar 05, 2013 at 10:54:44PM +0800, Jiang Liu wrote:
> Code to deal with reserved/managed pages are duplicated by many
> architectures, so introduce common help functions to reduce duplicated
> code. These common help functions will also be used to concentrate code
> to modify totalram_pages and zone->managed_pages, which makes the code
> much more clear.
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> ---
>  include/linux/mm.h |   37 +++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c    |   20 ++++++++++++++++++++
>  2 files changed, 57 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7acc9dc..881461c 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1295,6 +1295,43 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
>  		unsigned long zone_start_pfn, unsigned long *zholes_size);
>  extern void free_initmem(void);
>  
> +/* Help functions to deal with reserved/managed pages. */
> +extern unsigned long free_reserved_area(unsigned long start, unsigned long end,
> +					int poison, char *s);
> +
> +static inline void adjust_managed_page_count(struct page *page, long count)
> +{
> +	totalram_pages += count;
> +}

What is the purpose of the unused page argument?

> +
> +static inline void __free_reserved_page(struct page *page)
> +{
> +	ClearPageReserved(page);
> +	init_page_count(page);
> +	__free_page(page);
> +}
This method is useful for architectures which implment HIGHMEM,
like 32 bit x86 and 32 bit sparc.
This calls for a name without underscores.


> +
> +static inline void free_reserved_page(struct page *page)
> +{
> +	__free_reserved_page(page);
> +	adjust_managed_page_count(page, 1);
> +}
> +
> +static inline void mark_page_reserved(struct page *page)
> +{
> +	SetPageReserved(page);
> +	adjust_managed_page_count(page, -1);
> +}
> +
> +static inline void free_initmem_default(int poison)
> +{

Why request user to supply the poison argumet. If this is the default
implmentation then use the default poison value too (POISON_FREE_INITMEM)

> +	extern char __init_begin[], __init_end[];
> +
> +	free_reserved_area(PAGE_ALIGN((unsigned long)&__init_begin) ,
> +			   ((unsigned long)&__init_end) & PAGE_MASK,
> +			   poison, "unused kernel");
> +}


Maybe it is just me how is not used to this area of the kernel.
But a few comments that describe what the purpose is of each
function would have helped me.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
