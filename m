Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7E30F82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 19:32:13 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so102887483pab.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 16:32:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tt9si11765857pbc.91.2015.11.05.16.32.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 16:32:12 -0800 (PST)
Date: Thu, 5 Nov 2015 16:32:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: prepare page_referenced() and page_idle to new
 THP refcounting
Message-Id: <20151105163211.608eec970de21a95faf6e156@linux-foundation.org>
In-Reply-To: <1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>

On Tue,  3 Nov 2015 17:26:15 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> I've missed two simlar codepath which need some preparation to work well
> with reworked THP refcounting.
> 
> Both page_referenced() and page_idle_clear_pte_refs_one() assume that
> THP can only be mapped with PMD, so there's no reason to look on PTEs
> for PageTransHuge() pages. That's no true anymore: THP can be mapped
> with PTEs too.
> 
> The patch removes PageTransHuge() test from the functions and opencode
> page table check.

x86_64 allnoconfig:

In file included from mm/rmap.c:47:
include/linux/mm.h: In function 'page_referenced':
include/linux/mm.h:448: error: call to '__compiletime_assert_448' declared with attribute error: BUILD_BUG failed
make[1]: *** [mm/rmap.o] Error 1
make: *** [mm/rmap.o] Error 2

because

#else /* CONFIG_TRANSPARENT_HUGEPAGE */
#define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })


btw, total_mapcount() is far too large to be inlined and
page_mapcount() is getting pretty bad too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
