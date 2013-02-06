Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id E3B956B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 11:49:04 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 6 Feb 2013 11:47:41 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E241638C8079
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 11:47:29 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r16GlTSH316470
	for <linux-mm@kvack.org>; Wed, 6 Feb 2013 11:47:29 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r16GlJDV011738
	for <linux-mm@kvack.org>; Wed, 6 Feb 2013 14:47:19 -0200
Message-ID: <51128914.4010204@linux.vnet.ibm.com>
Date: Wed, 06 Feb 2013 10:47:16 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] zsmalloc: Add Kconfig for enabling PTE method
References: <1360117028-5625-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1360117028-5625-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On 02/05/2013 08:17 PM, Minchan Kim wrote:
> Zsmalloc has two methods 1) copy-based and 2) pte-based to access
> allocations that span two pages. You can see history why we supported
> two approach from [1].
> 
> In summary, copy-based method is 3 times fater in x86 while pte-based
> is 6 times faster in ARM.
> 
> But it was bad choice that adding hard coding to select architecture
> which want to use pte based method. This patch removed it and adds
> new Kconfig to select the approach.
> 
> This patch is based on next-20130205.
> 
> [1] https://lkml.org/lkml/2012/7/11/58
> 
> * Changelog from v1
>   * Fix CONFIG_PGTABLE_MAPPING in zsmalloc-main.c - Greg
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
> Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zsmalloc/Kconfig         | 12 ++++++++++++
>  drivers/staging/zsmalloc/zsmalloc-main.c | 20 +++++---------------
>  2 files changed, 17 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
> index 9084565..232b3b6 100644
> --- a/drivers/staging/zsmalloc/Kconfig
> +++ b/drivers/staging/zsmalloc/Kconfig
> @@ -8,3 +8,15 @@ config ZSMALLOC
>  	  non-standard allocator interface where a handle, not a pointer, is
>  	  returned by an alloc().  This handle must be mapped in order to
>  	  access the allocated space.
> +
> +config PGTABLE_MAPPING
> +        bool "Use page table mapping to access allocations that span two pages"
> +        depends on ZSMALLOC
> +        default n
> +        help
> +	  By default, zsmalloc uses a copy-based object mapping method to access
> +	  allocations that span two pages. However, if a particular architecture
> +	  performs VM mapping faster than copying, then you should select this.
> +	  This causes zsmalloc to use page table mapping rather than copying
> +	  for object mapping. You can check speed with zsmalloc benchmark[1].
> +	  [1] https://github.com/spartacus06/zsmalloc

Hmm, I'm not sure we want to include this link in the Kconfig.  While  I
don't have any plans to take that repo down, I could see it getting
stale at some point for yet-to-be-determined reasons.

Of course, without this tool (or something like it) it is hard to know
which option is better for your particular platform.

Would having this in a Documentation/ file, once one exists, be better?

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
