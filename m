Date: Tue, 15 Apr 2003 19:40:36 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.67-mm3
Message-ID: <20030416024036.GK706@holomorphy.com>
References: <20030414015313.4f6333ad.akpm@digeo.com> <20030416022154.GF12487@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030416022154.GF12487@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 15, 2003 at 07:21:54PM -0700, William Lee Irwin III wrote:
> follow_hugetlb_page() behaved improperly if its starting address was
> not hugepage-aligned. It looked a bit unclean too, so I rewrote it.
> This fixes a bug, and more importantly, makes the thing readable by
> something other than a compiler (e.g. programmers).

And this one fixes an overflow when there is more than 4GB of hugetlb:


diff -urpN htlb-2.5.67-bk6-1/arch/i386/mm/hugetlbpage.c htlb-2.5.67-bk6-2/arch/i386/mm/hugetlbpage.c
--- htlb-2.5.67-bk6-1/arch/i386/mm/hugetlbpage.c	2003-04-15 18:58:07.000000000 -0700
+++ htlb-2.5.67-bk6-2/arch/i386/mm/hugetlbpage.c	2003-04-15 19:25:30.000000000 -0700
@@ -482,9 +482,7 @@ int hugetlb_report_meminfo(char *buf)
 
 int is_hugepage_mem_enough(size_t size)
 {
-	if (size > (htlbpagemem << HPAGE_SHIFT))
-		return 0;
-	return 1;
+	return (size + ~HPAGE_MASK)/HPAGE_SIZE <= htlbpagemem;
 }
 
 /*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
