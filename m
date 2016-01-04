Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5B96B0006
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 06:23:23 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id 6so173210249qgy.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 03:23:23 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id a98si64413818qgf.112.2016.01.04.03.23.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Jan 2016 03:23:22 -0800 (PST)
Message-ID: <568A560A.80906@citrix.com>
Date: Mon, 4 Jan 2016 11:22:50 +0000
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memory-hotplug: add automatic onlining policy for
 the newly added memory
References: <1450801950-7744-1-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1450801950-7744-1-git-send-email-vkuznets@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Jonathan Corbet <corbet@lwn.net>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew
 Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor
 Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad
 Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On 22/12/15 16:32, Vitaly Kuznetsov wrote:
> @@ -1292,6 +1304,11 @@ int __ref add_memory_resource(int nid, struct resource *res)
>  	/* create new memmap entry */
>  	firmware_map_add_hotplug(start, start + size, "System RAM");
>  
> +	/* online pages if requested */
> +	if (online)
> +		online_pages(start >> PAGE_SHIFT, size >> PAGE_SHIFT,
> +			     MMOP_ONLINE_KEEP);

This will cause the Xen balloon driver to deadlock because it calls
add_memory_resource() with the balloon_mutex locked and the online page
callback also locks the balloon_mutex.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
