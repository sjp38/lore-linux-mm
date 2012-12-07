Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 0BF066B0062
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 02:25:44 -0500 (EST)
Date: Fri, 7 Dec 2012 08:25:41 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121207072541.GA27708@liondog.tnic>
References: <50C15A35.5020007@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <50C15A35.5020007@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 07, 2012 at 10:53:41AM +0800, Xishi Qiu wrote:
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
> The free page which marked HWPoison is still managed by page buddy allocator. So when
> offlining it again, get_any_page() always returns 0 with
> "pr_info("%s: %#lx free buddy page\n", __func__, pfn);".
> 
> When page is allocated, the PageBuddy is removed in bad_page(), then get_any_page()
> returns -EIO with pr_info("%s: %#lx: unknown zero refcount page type %lx\n", so
> mce_bad_pages will not be added.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> i>>?Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> ---
>  mm/memory-failure.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 8b20278..02a522e 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1375,6 +1375,11 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
>  	if (flags & MF_COUNT_INCREASED)
>  		return 1;
> 
> +	if (PageHWPoison(p)) {
> +		pr_info("%s: %#lx page already poisoned\n", __func__, pfn);
> +		return -EBUSY;
> +	}

Shouldn't this be done in soft_offline_page() instead, like it is done
in soft_offline_huge_page() for hugepages?

Thanks.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
