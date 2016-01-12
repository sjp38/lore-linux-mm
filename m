Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3D638828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 12:38:37 -0500 (EST)
Received: by mail-yk0-f181.google.com with SMTP id k129so436920130yke.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 09:38:37 -0800 (PST)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id d81si4389030ywc.22.2016.01.12.09.38.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Jan 2016 09:38:36 -0800 (PST)
Message-ID: <56953A18.2070407@citrix.com>
Date: Tue, 12 Jan 2016 17:38:32 +0000
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCH v4 2/2] xen_balloon: support memory auto onlining
 policy
References: <1452617777-10598-1-git-send-email-vkuznets@redhat.com>
 <1452617777-10598-3-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1452617777-10598-3-git-send-email-vkuznets@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Kay
 Sievers <kay@vrfy.org>, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, xen-devel@lists.xenproject.org, Igor Mammedov <imammedo@redhat.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Xishi Qiu <qiuxishi@huawei.com>, Dan Williams <dan.j.williams@intel.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Mel
 Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On 12/01/16 16:56, Vitaly Kuznetsov wrote:
> Add support for the newly added kernel memory auto onlining policy to Xen
> ballon driver.
[...]
> --- a/drivers/xen/Kconfig
> +++ b/drivers/xen/Kconfig
> @@ -37,23 +37,29 @@ config XEN_BALLOON_MEMORY_HOTPLUG
>  
>  	  Memory could be hotplugged in following steps:
>  
> -	    1) dom0: xl mem-max <domU> <maxmem>
> +	    1) domU: ensure that memory auto online policy is in effect by
> +	       checking /sys/devices/system/memory/auto_online_blocks file
> +	       (should be 'online').

Step 1 applies to dom0 and domUs.

> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -284,7 +284,7 @@ static void release_memory_resource(struct resource *resource)
>  	kfree(resource);
>  }
>  
> -static enum bp_state reserve_additional_memory(void)
> +static enum bp_state reserve_additional_memory(bool online)
>  {
>  	long credit;
>  	struct resource *resource;
> @@ -338,7 +338,18 @@ static enum bp_state reserve_additional_memory(void)
>  	}
>  #endif
>  
> -	rc = add_memory_resource(nid, resource, false);
> +	/*
> +	 * add_memory_resource() will call online_pages() which in its turn
> +	 * will call xen_online_page() callback causing deadlock if we don't
> +	 * release balloon_mutex here. It is safe because there can only be
> +	 * one balloon_process() running at a time and balloon_mutex is
> +	 * internal to Xen driver, generic memory hotplug code doesn't mess
> +	 * with it.

There are multiple callers of reserve_additional_memory() and these are
not all serialized via the balloon process.  Replace the "It is safe..."
sentence with:

"Unlocking here is safe because the callers drop the mutex before trying
again."

> +	 */
> +	mutex_unlock(&balloon_mutex);
> +	rc = add_memory_resource(nid, resource, online);

This should always be memhp_auto_online, because...

> @@ -562,14 +573,11 @@ static void balloon_process(struct work_struct *work)
>  
>  		credit = current_credit();
>  
> -		if (credit > 0) {
> -			if (balloon_is_inflated())
> -				state = increase_reservation(credit);
> -			else
> -				state = reserve_additional_memory();
> -		}
> -
> -		if (credit < 0)
> +		if (credit > 0 && balloon_is_inflated())
> +			state = increase_reservation(credit);
> +		else if (credit > 0)
> +			state = reserve_additional_memory(memhp_auto_online);
> +		else if (credit < 0)
>  			state = decrease_reservation(-credit, GFP_BALLOON);

I'd have preferred this refactored as:

if (credit > 0) {
    if (balloon_is_inflated())
        ...
    else
        ...
} else if (credit < 0) {
    ...
}
>  
>  		state = update_schedule(state);
> @@ -599,7 +607,7 @@ static int add_ballooned_pages(int nr_pages)
>  	enum bp_state st;
>  
>  	if (xen_hotplug_unpopulated) {
> -		st = reserve_additional_memory();
> +		st = reserve_additional_memory(false);

... we want to auto-online this memory as well.

>  		if (st != BP_ECANCELED) {
>  			mutex_unlock(&balloon_mutex);
>  			wait_event(balloon_wq,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
