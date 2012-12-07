Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 54A4E6B0073
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 09:33:43 -0500 (EST)
Date: Fri, 7 Dec 2012 15:33:40 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121207143340.GE27523@liondog.tnic>
References: <50C1AD6D.7010709@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <50C1AD6D.7010709@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 07, 2012 at 04:48:45PM +0800, Xishi Qiu wrote:
> On x86 platform, if we use "/sys/devices/system/memory/soft_offline_page" to offline a
> free page twice, the value of mce_bad_pages will be added twice. So this is an error,
> since the page was already marked HWPoison, we should skip the page and don't add the
> value of mce_bad_pages.
> 
> $ cat /proc/meminfo | grep HardwareCorrupted
> 
> soft_offline_page()
> 	get_any_page()
> 		atomic_long_add(1, &mce_bad_pages)
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> i>>?Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> ---
>  mm/memory-failure.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 8b20278..de760ca 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1582,8 +1582,11 @@ int soft_offline_page(struct page *page, int flags)
>  		return ret;
> 
>  done:
> -	atomic_long_add(1, &mce_bad_pages);
> -	SetPageHWPoison(page);
>  	/* keep elevated page count for bad page */
> +	if (!PageHWPoison(page)) {
> +		atomic_long_add(1, &mce_bad_pages);
> +		SetPageHWPoison(page);
> +	}

Ok, I don't know the memory-failure code all that well but IMHO why
should we wade through the whole soft_offline_page function for a page
which has been marked as poisoned already?

IOW, why not do what you started with previously and exit this function
ASAP:

---
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 8b20278be6a6..a83baeca0644 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1494,6 +1494,12 @@ int soft_offline_page(struct page *page, int flags)
 	if (ret == 0)
 		goto done;
 
+	if (PageHWPoison(page)) {
+		put_page(page);
+		pr_info("soft offline: %#lx page already poisoned\n", pfn);
+		return -EBUSY;
+	}
+
 	/*
 	 * Page cache page we can handle?
 	 */
---

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
