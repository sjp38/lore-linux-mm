Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA7BC8E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 16:56:42 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id j5so45435008qtk.11
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 13:56:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b20si2838649qvd.185.2019.01.04.13.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 13:56:42 -0800 (PST)
Date: Fri, 4 Jan 2019 16:56:36 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2] mm: page_mapped: don't assume compound page is huge
 or THP
Message-ID: <20190104215636.GM19981@redhat.com>
References: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
 <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, lersek@redhat.com, alex.williamson@redhat.com, rientjes@google.com, kirill@shutemov.name, mgorman@techsingularity.net, mhocko@suse.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

[ CC'ed Andrew for potential inclusion in -mm ]

On Fri, Nov 30, 2018 at 01:06:57PM +0100, Jan Stancek wrote:
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

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks,
Andrea
