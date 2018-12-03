Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE7766B6892
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 05:24:08 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id t18so13033005qtj.3
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 02:24:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u37si9434653qtu.230.2018.12.03.02.24.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 02:24:07 -0800 (PST)
Subject: Re: [PATCH v2] mm: page_mapped: don't assume compound page is huge or
 THP
References: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
 <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com>
From: Laszlo Ersek <lersek@redhat.com>
Message-ID: <35a664c0-6dab-bb32-811e-65250200d195@redhat.com>
Date: Mon, 3 Dec 2018 11:23:58 +0100
MIME-Version: 1.0
In-Reply-To: <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, alex.williamson@redhat.com, aarcange@redhat.com, rientjes@google.com, kirill@shutemov.name, mgorman@techsingularity.net, mhocko@suse.com
Cc: linux-kernel@vger.kernel.org

On 11/30/18 13:06, Jan Stancek wrote:
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
> (COMPOUND_PAGE_DTOR), then following loop can keep running
> (for HPAGE_PMD_NR iterations) until it tries to read from memory
> that isn't mapped and triggers a panic:
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
> - call to page_mapped(COPY) now triggers fault on access to 2nd
>   COPY page at offset 0x30 (_mapcount)
> 
> [1] https://github.com/jstancek/reproducers/blob/master/kernel/page_mapped_crash/repro.c
> 
> Fix the loop to iterate for "1 << compound_order" pages.
> 
> Debugged-by: Laszlo Ersek <lersek@redhat.com>
> Suggested-by: "Kirill A. Shutemov" <kirill@shutemov.name>
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> ---
>  mm/util.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Changes in v2:
> - change the loop instead so we check also mapcount of subpages
> 
> diff --git a/mm/util.c b/mm/util.c
> index 8bf08b5b5760..5c9c7359ee8a 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -478,7 +478,7 @@ bool page_mapped(struct page *page)
>  		return true;
>  	if (PageHuge(page))
>  		return false;
> -	for (i = 0; i < hpage_nr_pages(page); i++) {
> +	for (i = 0; i < (1 << compound_order(page)); i++) {
>  		if (atomic_read(&page[i]._mapcount) >= 0)
>  			return true;
>  	}
> 

Totally uninformed side-question:

how large can the return value of compound_order() be? MAX_ORDER?

Apparently, MAX_ORDER can be defined as CONFIG_FORCE_MAX_ZONEORDER.

"config FORCE_MAX_ZONEORDER" is listed in a number of Kconfig files.
Among those, "arch/mips/Kconfig" permits "ranges" (?) that extend up to
64. Same applies to "arch/powerpc/Kconfig" and "arch/sh/mm/Kconfig".

If we left-shift "1" -- a signed int, which I assume in practice will
always have two's complement representation, 1 sign bit, 31 value bits,
and 0 padding bits --, by 31 or more bit positions, we get undefined
behavior (as part of the left-shift operation).

Is this a practical concern?

Thanks,
Laszlo
