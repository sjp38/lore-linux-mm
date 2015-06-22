Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2566B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 15:04:01 -0400 (EDT)
Received: by paceq1 with SMTP id eq1so115231789pac.3
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 12:04:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id a5si30853565pbu.40.2015.06.22.12.03.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jun 2015 12:03:59 -0700 (PDT)
Date: Mon, 22 Jun 2015 12:04:00 -0700
From: Darren Hart <dvhart@infradead.org>
Subject: Re: [PATCH 3/4] dell-laptop: Fix allocating & freeing SMI buffer page
Message-ID: <20150622190400.GD58421@vmdeb7>
References: <1434875967-13370-1-git-send-email-pali.rohar@gmail.com>
 <1434876063-13460-1-git-send-email-pali.rohar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1434876063-13460-1-git-send-email-pali.rohar@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Cc: Matthew Garrett <mjg59@srcf.ucam.org>, Michal Hocko <mhocko@suse.cz>, platform-driver-x86@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Jun 21, 2015 at 10:41:03AM +0200, Pali Rohar wrote:
> This commit fix kernel crash when probing for rfkill devices in dell-laptop
> driver failed. Function free_page() was incorrectly used on struct page *
> instead of virtual address of SMI buffer.
> 
> This commit also simplify allocating page for SMI buffer by using
> __get_free_page() function instead of sequential call of functions
> alloc_page() and page_address().
> 
> Signed-off-by: Pali Rohar <pali.rohar@gmail.com>

Looks good - please resend with Cc to stable - that's the simplest path to
inclusion in stable.

> ---
>  drivers/platform/x86/dell-laptop.c |    8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/platform/x86/dell-laptop.c b/drivers/platform/x86/dell-laptop.c
> index aaef335..0a91599 100644
> --- a/drivers/platform/x86/dell-laptop.c
> +++ b/drivers/platform/x86/dell-laptop.c
> @@ -306,7 +306,6 @@ static const struct dmi_system_id dell_quirks[] __initconst = {
>  };
>  
>  static struct calling_interface_buffer *buffer;
> -static struct page *bufferpage;
>  static DEFINE_MUTEX(buffer_mutex);
>  
>  static int hwswitch_state;
> @@ -2097,12 +2096,11 @@ static int __init dell_init(void)
>  	 * Allocate buffer below 4GB for SMI data--only 32-bit physical addr
>  	 * is passed to SMI handler.
>  	 */
> -	bufferpage = alloc_page(GFP_KERNEL | GFP_DMA32);
> -	if (!bufferpage) {
> +	buffer = (void *)__get_free_page(GFP_KERNEL | GFP_DMA32);
> +	if (!buffer) {
>  		ret = -ENOMEM;
>  		goto fail_buffer;
>  	}
> -	buffer = page_address(bufferpage);
>  
>  	ret = dell_setup_rfkill();
>  
> @@ -2165,7 +2163,7 @@ static int __init dell_init(void)
>  fail_backlight:
>  	dell_cleanup_rfkill();
>  fail_rfkill:
> -	free_page((unsigned long)bufferpage);
> +	free_page((unsigned long)buffer);
>  fail_buffer:
>  	platform_device_del(platform_device);
>  fail_platform_device2:
> -- 
> 1.7.9.5
> 
> 

-- 
Darren Hart
Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
