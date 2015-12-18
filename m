Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3E86B0005
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 11:53:26 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id c96so37689702qgd.3
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 08:53:26 -0800 (PST)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id 89si16913961qgi.63.2015.12.18.08.53.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Dec 2015 08:53:25 -0800 (PST)
Message-ID: <56743A00.4020503@citrix.com>
Date: Fri, 18 Dec 2015 16:53:20 +0000
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: add automatic onlining policy for the
 newly added memory
References: <1450457155-31234-1-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1450457155-31234-1-git-send-email-vkuznets@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan
 Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David
 Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>

On 18/12/15 16:45, Vitaly Kuznetsov wrote:
> Currently, all newly added memory blocks remain in 'offline' state unless
> someone onlines them, some linux distributions carry special udev rules
> like:
> 
> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"
> 
> to make this happen automatically. This is not a great solution for virtual
> machines where memory hotplug is being used to address high memory pressure
> situations as such onlining is slow and a userspace process doing this
> (udev) has a chance of being killed by the OOM killer as it will probably
> require to allocate some memory.
> 
> Introduce default policy for the newly added memory blocks in
> /sys/devices/system/memory/hotplug_autoonline file with two possible
> values: "offline" which preserves the current behavior and "online" which
> causes all newly added memory blocks to go online as soon as they're added.
> The default is "online" when MEMORY_HOTPLUG_AUTOONLINE kernel config option
> is selected.

FWIW, I'd prefer it if the caller of add_memory_resource() could specify
that it wants the new memory automatically onlined.

I'm not sure just having one knob is appropriate -- there are different
sorts of memory that can be added.  e,g., in the Xen balloon driver we
use the memory add infrastructure to add empty pages (pages with no
machine pages backing them) for mapping things into, as well as adding
regular pages.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
