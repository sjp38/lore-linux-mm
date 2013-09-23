Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 153A76B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 19:59:32 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wp4so4326662obc.28
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 16:59:31 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 24 Sep 2013 09:59:27 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A1A7E2BB0054
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:59:21 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8NNgSXQ7012820
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:42:34 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8NNxElm026919
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:59:15 +1000
Date: Tue, 24 Sep 2013 07:59:13 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 1/4] mm/hwpoison: fix traverse hugetlbfs page to avoid
 printk flood
Message-ID: <5240d5e3.a3e2440a.7005.1f5fSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1379464737-23592-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1379464737-23592-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew, if this patchset is ok for you to merge?
On Wed, Sep 18, 2013 at 08:38:54AM +0800, Wanpeng Li wrote:
>madvise_hwpoison won't check if the page is small page or huge page and traverse
>in small page granularity against the range unconditional, which result in a printk
>flood "MCE xxx: already hardware poisoned" if the page is huge page. This patch fix
>it by increase compound_order(compound_head(page)) for huge page iterator.
>
>Testcase:
>
>#define _GNU_SOURCE
>#include <stdlib.h>
>#include <stdio.h>
>#include <sys/mman.h>
>#include <unistd.h>
>#include <fcntl.h>
>#include <sys/types.h>
>#include <errno.h>
>
>#define PAGES_TO_TEST 3
>#define PAGE_SIZE	4096 * 512
>
>int main(void)
>{
>	char *mem;
>	int i;
>
>	mem = mmap(NULL, PAGES_TO_TEST * PAGE_SIZE,
>			PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, 0, 0);
>
>	if (madvise(mem, PAGES_TO_TEST * PAGE_SIZE, MADV_HWPOISON) == -1)
>		return -1;
>
>	munmap(mem, PAGES_TO_TEST * PAGE_SIZE);
>
>	return 0;
>}
>
>Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>Acked-by: Andi Kleen <ak@linux.intel.com>
>Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>---
> mm/madvise.c |    5 +++--
> 1 files changed, 3 insertions(+), 2 deletions(-)
>
>diff --git a/mm/madvise.c b/mm/madvise.c
>index 6975bc8..539eeb9 100644
>--- a/mm/madvise.c
>+++ b/mm/madvise.c
>@@ -343,10 +343,11 @@ static long madvise_remove(struct vm_area_struct *vma,
>  */
> static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
> {
>+	struct page *p;
> 	if (!capable(CAP_SYS_ADMIN))
> 		return -EPERM;
>-	for (; start < end; start += PAGE_SIZE) {
>-		struct page *p;
>+	for (; start < end; start += PAGE_SIZE <<
>+				compound_order(compound_head(p))) {
> 		int ret;
>
> 		ret = get_user_pages_fast(start, 1, 0, &p);
>-- 
>1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
