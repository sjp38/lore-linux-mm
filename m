Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 9A7A56B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 01:10:13 -0500 (EST)
Message-ID: <5113450C.1080109@huawei.com>
Date: Thu, 7 Feb 2013 14:09:16 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V3] ia64/mm: fix a bad_page bug when crash kernel booting
References: <51074786.5030007@huawei.com> <1359995565.7515.178.camel@mfleming-mobl1.ger.corp.intel.com> <51131248.3080203@huawei.com>
In-Reply-To: <51131248.3080203@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Matt Fleming <matt.fleming@intel.com>, "Luck, Tony" <tony.luck@intel.com>, fenghua.yu@intel.com, Liujiang <jiang.liu@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, WuJianguo <wujianguo@huawei.com>

> Sorry, this bug will be happen when use Sparse-Memory(section is valid, but last

> several pages are invalid). If use Flat-Memory, crash kernel will boot successfully.
> I think the following patch would be better.
> 
> Hi Andrew, will you just ignore the earlier patch and consider the following one? :>
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  arch/ia64/mm/init.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index 082e383..23f2ee3 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -213,6 +213,8 @@ free_initrd_mem (unsigned long start, unsigned long end)
>  	for (; start < end; start += PAGE_SIZE) {
>  		if (!virt_addr_valid(start))
>  			continue;
> +		if ((start >> PAGE_SHIFT) >= max_low_pfn)

I confused the vaddr and paddr, really sorry for it.

In efi_init() memory aligns in IA64_GRANULE_SIZE(16M). If set "crashkernel=1024M-:600M"
and use sparse memory model, when crash kernel booting it changes [128M-728M] to [128M-720M].
But initrd memory is in [709M-727M], and virt_addr_valid() *can not* check the invalid pages
when freeing initrd memory. There are some pages missed at the end of the seciton.

ChangeLog V3:
	fixed vaddr mistake
ChangeLog V2:
	add invalid pages check when freeing initrd memory

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 arch/ia64/mm/init.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 082e383..8a269f8 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -173,6 +173,7 @@ void __init
 free_initrd_mem (unsigned long start, unsigned long end)
 {
 	struct page *page;
+	unsigned long pfn;
 	/*
 	 * EFI uses 4KB pages while the kernel can use 4KB or bigger.
 	 * Thus EFI and the kernel may have different page sizes. It is
@@ -213,6 +214,9 @@ free_initrd_mem (unsigned long start, unsigned long end)
 	for (; start < end; start += PAGE_SIZE) {
 		if (!virt_addr_valid(start))
 			continue;
+		pfn = __pa(start) >> PAGE_SHIFT;
+		if (pfn >= max_low_pfn)
+			continue;
 		page = virt_to_page(start);
 		ClearPageReserved(page);
 		init_page_count(page);
-- 
1.7.6.1





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
