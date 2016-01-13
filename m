Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5F790828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 03:06:57 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 65so77294188pff.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 00:06:57 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 85si294013pft.165.2016.01.13.00.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 00:06:55 -0800 (PST)
Date: Wed, 13 Jan 2016 09:06:22 +0100
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCH v4 1/2] memory-hotplug: add automatic onlining policy for
 the newly added memory
Message-ID: <20160113080622.GW3485@olila.local.net-space.pl>
References: <1452617777-10598-1-git-send-email-vkuznets@redhat.com>
 <1452617777-10598-2-git-send-email-vkuznets@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452617777-10598-2-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

On Tue, Jan 12, 2016 at 05:56:16PM +0100, Vitaly Kuznetsov wrote:
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
> /sys/devices/system/memory/auto_online_blocks file with two possible
> values: "offline" which preserves the current behavior and "online" which
> causes all newly added memory blocks to go online as soon as they're added.
> The default is "offline".
>
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> ---
>  Documentation/memory-hotplug.txt | 19 +++++++++++++++----
>  drivers/base/memory.c            | 40 ++++++++++++++++++++++++++++++++++++----
>  drivers/xen/balloon.c            |  2 +-
>  include/linux/memory.h           |  3 ++-
>  include/linux/memory_hotplug.h   |  4 +++-
>  mm/memory_hotplug.c              | 18 +++++++++++++++---
>  6 files changed, 72 insertions(+), 14 deletions(-)
>
> diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
> index ce2cfcf..ceaf40c 100644
> --- a/Documentation/memory-hotplug.txt
> +++ b/Documentation/memory-hotplug.txt
> @@ -254,12 +254,23 @@ If the memory block is online, you'll read "online".
>  If the memory block is offline, you'll read "offline".
>
>
> -5.2. How to online memory
> +5.2. Memory onlining
>  ------------
> -Even if the memory is hot-added, it is not at ready-to-use state.
> -For using newly added memory, you have to "online" the memory block.
> +When the memory is hot-added, the kernel decides whether or not to "online"
> +it according to the policy which can be read from "auto_online_blocks" file:
>
> -For onlining, you have to write "online" to the memory block's state file as:
> +% cat /sys/devices/system/memory/auto_online_blocks
> +
> +The default is "offline" which means the newly added memory is not in a
> +ready-to-use state and you have to "online" the newly added memory blocks
> +manually. Automatic onlining can be requested by writing "online" to
> +"auto_online_blocks" file:
> +
> +% echo online > /sys/devices/system/memory/auto_online_blocks

It looks that you forgot to mention that setting auto_online_blocks to
online does not online currently offlined blocks automatically.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
