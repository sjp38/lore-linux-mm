Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id AAFD16B006C
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 05:48:02 -0500 (EST)
Date: Fri, 11 Jan 2013 11:47:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmots: memory-hotplug: implement
 register_page_bootmem_info_section of sparse-vmemmap fix
Message-ID: <20130111104759.GF7286@dhcp22.suse.cz>
References: <20130111095658.GC7286@dhcp22.suse.cz>
 <20130111101745.GD7286@dhcp22.suse.cz>
 <20130111102924.GE7286@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130111102924.GE7286@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wu Jianguo <wujianguo@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 11-01-13 11:29:24, Michal Hocko wrote:
> On Fri 11-01-13 11:17:45, Michal Hocko wrote:
> [...]
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index be2b90c..59eddff 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -128,6 +128,64 @@ void __ref put_page_bootmem(struct page *page)
> >  
> >  }
> >  
> > +void register_page_bootmem_memmap(unsigned long section_nr,
> > +				  struct page *start_page, unsigned long size)
> > +{
> > +	unsigned long addr = (unsigned long)start_page;
> > +	unsigned long end = (unsigned long)(start_page + size);
> > +	unsigned long next;
> > +	pgd_t *pgd;
> > +	pud_t *pud;
> > +	pmd_t *pmd;
> > +	unsigned int nr_pages;
> > +	struct page *page;
> > +
> > +	for (; addr < end; addr = next) {
> > +		pte_t *pte = NULL;
> > +
> > +		pgd = pgd_offset_k(addr);
> > +		if (pgd_none(*pgd)) {
> > +			next = (addr + PAGE_SIZE) & PAGE_MASK;
> > +			continue;
> > +		}
> > +		get_page_bootmem(section_nr, pgd_page(*pgd), MIX_SECTION_INFO);
> > +
> > +		pud = pud_offset(pgd, addr);
> > +		if (pud_none(*pud)) {
> > +			next = (addr + PAGE_SIZE) & PAGE_MASK;
> > +			continue;
> > +		}
> > +		get_page_bootmem(section_nr, pud_page(*pud), MIX_SECTION_INFO);
> > +
> > +		if (!cpu_has_pse) {
> 
> Darn! And now that I am looking at the patch closer it is too x86
> centric so this cannot be in the generic code. I will try to cook
> something better. Sorry about the noise.

It is more complicated than I thought. One would tell it's a mess.
The patch bellow fixes the compilation issue but I am not sure we want
to include memory_hotplug.h into arch/x86/mm/init_64.c. Moreover

+void register_page_bootmem_memmap(unsigned long section_nr,
+				  struct page *start_page, unsigned long size)
+{
+	/* TODO */
+}

for other archs would suggest that the code is not ready yet. Should
this rather be dropped for now?
---
