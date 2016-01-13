Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 064AD828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:47:30 -0500 (EST)
Received: by mail-yk0-f176.google.com with SMTP id x67so504203349ykd.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 12:47:30 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id x143si2096558ywx.233.2016.01.13.12.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 12:47:29 -0800 (PST)
Date: Wed, 13 Jan 2016 21:46:38 +0100
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCH v5 2/2] xen_balloon: support memory auto onlining policy
Message-ID: <20160113204638.GZ3485@olila.local.net-space.pl>
References: <1452706350-21158-1-git-send-email-vkuznets@redhat.com>
 <1452706350-21158-3-git-send-email-vkuznets@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452706350-21158-3-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

On Wed, Jan 13, 2016 at 06:32:30PM +0100, Vitaly Kuznetsov wrote:
> Add support for the newly added kernel memory auto onlining policy to Xen
> ballon driver.
>
> Suggested-by: Daniel Kiper <daniel.kiper@oracle.com>
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

In general Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>
but one nitpick below...

Thank you for doing this work.

> ---
> Changes since v4:
> - 'dom0' -> 'control domain', 'domU' -> 'target domain' in Kconfig
>   [David Vrabel]
> - always call add_memory_resource() with memhp_auto_online [David Vrabel]
> ---
>  drivers/xen/Kconfig   | 20 +++++++++++++-------
>  drivers/xen/balloon.c | 11 ++++++++++-
>  2 files changed, 23 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
> index 73708ac..addcb7f 100644
> --- a/drivers/xen/Kconfig
> +++ b/drivers/xen/Kconfig
> @@ -37,23 +37,29 @@ config XEN_BALLOON_MEMORY_HOTPLUG
>
>  	  Memory could be hotplugged in following steps:
>
> -	    1) dom0: xl mem-max <domU> <maxmem>
> +	    1) target domain: ensure that memory auto online policy is in
> +	       effect by checking /sys/devices/system/memory/auto_online_blocks
> +	       file (should be 'online').
> +
> +	    2) control domain: xl mem-max <target-domain> <maxmem>
>  	       where <maxmem> is >= requested memory size,
>
> -	    2) dom0: xl mem-set <domU> <memory>
> +	    3) control domain: xl mem-set <target-domain> <memory>
>  	       where <memory> is requested memory size; alternatively memory
>  	       could be added by writing proper value to
>  	       /sys/devices/system/xen_memory/xen_memory0/target or
>  	       /sys/devices/system/xen_memory/xen_memory0/target_kb on dumU,

Please change "dumU" to "target domain".

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
