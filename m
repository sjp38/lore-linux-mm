Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ADC646B57AB
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 05:20:00 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id m16so3228865pgd.0
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 02:20:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x21-v6sor6312566pln.20.2018.11.30.02.19.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 02:19:59 -0800 (PST)
Date: Fri, 30 Nov 2018 13:19:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: page_mapped: don't assume compound page is huge or
 THP
Message-ID: <20181130101953.u4owfaqmaq2osuod@kshutemo-mobl1>
References: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, lersek@redhat.com, alex.williamson@redhat.com, aarcange@redhat.com, rientjes@google.com, mgorman@techsingularity.net, mhocko@suse.com, linux-kernel@vger.kernel.org

On Thu, Nov 29, 2018 at 10:53:48PM +0100, Jan Stancek wrote:
> LTP proc01 testcase has been observed to rarely trigger crashes
> on arm64:
>     page_mapped+0x78/0xb4
>     stable_page_flags+0x27c/0x338
>     kpageflags_read+0xfc/0x164
>     proc_reg_read+0x7c/0xb8
>     __vfs_read+0x58/0x178
>     vfs_read+0x90/0x14c
>     SyS_read+0x60/0xc0
> 
> Issue is that page_mapped() assumes that if compound page is not
> huge, then it must be THP. But if this is 'normal' compound page
> (COMPOUND_PAGE_DTOR), then following loop can keep running until
> it tries to read from memory that isn't mapped and triggers a panic:
>         for (i = 0; i < hpage_nr_pages(page); i++) {
>                 if (atomic_read(&page[i]._mapcount) >= 0)
>                         return true;
> 	}
> 
> I could replicate this on x86 (v4.20-rc4-98-g60b548237fed) only
> with a custom kernel module [1] which:
> - allocates compound page (PAGEC) of order 1
> - allocates 2 normal pages (COPY), which are initialized to 0xff
>   (to satisfy _mapcount >= 0)
> - 2 PAGEC page structs are copied to address of first COPY page
> - second page of COPY is marked as not present
> - call to page_mapped(COPY) now triggers fault on access to 2nd COPY
>   page at offset 0x30 (_mapcount)
> 
> [1] https://github.com/jstancek/reproducers/blob/master/kernel/page_mapped_crash/repro.c
> 
> This patch modifies page_mapped() to check for 'normal'
> compound pages (COMPOUND_PAGE_DTOR).
> 
> Debugged-by: Laszlo Ersek <lersek@redhat.com>
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> ---
>  include/linux/mm.h | 9 +++++++++
>  mm/util.c          | 2 ++
>  2 files changed, 11 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5411de93a363..18b0bb953f92 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -700,6 +700,15 @@ static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
>  	return compound_page_dtors[page[1].compound_dtor];
>  }
>  
> +static inline int PageNormalCompound(struct page *page)
> +{
> +	if (!PageCompound(page))
> +		return 0;
> +
> +	page = compound_head(page);
> +	return page[1].compound_dtor == COMPOUND_PAGE_DTOR;
> +}
> +
>  static inline unsigned int compound_order(struct page *page)
>  {
>  	if (!PageHead(page))
> diff --git a/mm/util.c b/mm/util.c
> index 8bf08b5b5760..06c1640cb7b3 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -478,6 +478,8 @@ bool page_mapped(struct page *page)
>  		return true;
>  	if (PageHuge(page))
>  		return false;
> +	if (PageNormalCompound(page))
> +		return false;
>  	for (i = 0; i < hpage_nr_pages(page); i++) {
>  		if (atomic_read(&page[i]._mapcount) >= 0)
>  			return true;

Thanks for catching this.

But I think the right fix would be to change the loop condition:

	for (i = 0; i < (1 << compund_order(page)); i++) {

Non-THP compound page also can be mapped and we need to check mapcount of
subpages.

Any objections?

If not, please update the patch.

-- 
 Kirill A. Shutemov
