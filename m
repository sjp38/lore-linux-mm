Date: Tue, 13 Nov 2007 13:46:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Sparsemem: Do not reserve section flags if VMEMMAP is in use
Message-Id: <20071113134603.5b4b0f24.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0711121944400.30269@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711121944400.30269@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Nov 2007 19:47:06 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h	2007-11-12 19:36:39.472347109 -0800
> +++ linux-2.6/include/linux/mm.h	2007-11-12 19:37:05.197064250 -0800
> @@ -378,7 +378,7 @@ static inline void set_compound_order(st
>   * with space for node: | SECTION | NODE | ZONE | ... | FLAGS |
>   *   no space for node: | SECTION |     ZONE    | ... | FLAGS |
>   */
> -#ifdef CONFIG_SPARSEMEM
> +#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
>  #define SECTIONS_WIDTH		SECTIONS_SHIFT
>  #else
>  #define SECTIONS_WIDTH		0
> 
I like this. but it may safe to add this definition to do this..

==
#if SECTIONS_WIDTH > 0
static inline page_to_section(struct page *page)
{
	return pfn_to_section(page_to_pfn(page));
}
else
....
#endif
==

page_to_section is used in page_to_nid() if NODE_NOT_IN_PAGE_FLAGS=y.
(I'm not sure exact config dependency.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
