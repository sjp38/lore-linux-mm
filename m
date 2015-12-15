Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 096FD6B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 17:58:00 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id v16so20848405qge.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 14:58:00 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q186si3365515qha.42.2015.12.15.14.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 14:57:58 -0800 (PST)
Date: Tue, 15 Dec 2015 23:56:59 +0100
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCH RFC] memory-hotplug: add automatic onlining policy for
 the newly added memory
Message-ID: <20151215225659.GU29871@olila.local.net-space.pl>
References: <1450202753-5556-1-git-send-email-vkuznets@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450202753-5556-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>

Hey Vitaly,

On Tue, Dec 15, 2015 at 07:05:53PM +0100, Vitaly Kuznetsov wrote:
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
> values: "offline" (the default) which preserves the current behavior and
> "online" which causes all newly added memory blocks to go online as
> soon as they're added.

In general idea make sense for me but...

> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Daniel Kiper <daniel.kiper@oracle.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Tang Chen <tangchen@cn.fujitsu.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>
> Cc: Xishi Qiu <qiuxishi@huawei.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "K. Y. Srinivasan" <kys@microsoft.com>
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> ---
> - I was able to find previous attempts to fix the issue, e.g.:
>   http://marc.info/?l=linux-kernel&m=137425951924598&w=2
>   http://marc.info/?l=linux-acpi&m=127186488905382
>   but I'm not completely sure why it didn't work out and the solution
>   I suggest is not 'smart enough', thus 'RFC'.
> ---
>  Documentation/memory-hotplug.txt | 21 +++++++++++++++++----
>  drivers/base/memory.c            | 35 +++++++++++++++++++++++++++++++++++
>  include/linux/memory_hotplug.h   |  2 ++
>  mm/memory_hotplug.c              |  8 ++++++++
>  4 files changed, 62 insertions(+), 4 deletions(-)
>
> diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
> index ce2cfcf..fe576d9 100644
> --- a/Documentation/memory-hotplug.txt
> +++ b/Documentation/memory-hotplug.txt
> @@ -254,12 +254,25 @@ If the memory block is online, you'll read "online".
>  If the memory block is offline, you'll read "offline".
>
>
> -5.2. How to online memory
> +5.2. Memory onlining
>  ------------
> -Even if the memory is hot-added, it is not at ready-to-use state.
> -For using newly added memory, you have to "online" the memory block.
> +When the memory is hot-added, the kernel decides whether or not to "online"
> +it according to the policy which can be read from "hotplug_autoonline" file:
>
> -For onlining, you have to write "online" to the memory block's state file as:
> +% cat /sys/devices/system/memory/hotplug_autoonline
> +
> +The default is "offline" which means the newly added memory will not be at
> +ready-to-use state and you have to "online" the newly added memory blocks
> +manually.
> +
> +Automatic onlining can be requested by writing "online" to "hotplug_autoonline"
> +file:
> +
> +% echo online > /sys/devices/system/memory/hotplug_autoonline
> +
> +If the automatic onlining wasn't requested or some memory block was offlined
> +it is possible to change the individual block's state by writing to the "state"
> +file:
>
>  % echo online > /sys/devices/system/memory/memoryXXX/state
>
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 25425d3..001fefe 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -438,6 +438,40 @@ print_block_size(struct device *dev, struct device_attribute *attr,
>
>  static DEVICE_ATTR(block_size_bytes, 0444, print_block_size, NULL);
>
> +
> +/*
> + * Memory auto online policy.
> + */
> +
> +static ssize_t
> +show_memhp_autoonline(struct device *dev, struct device_attribute *attr,
> +		      char *buf)
> +{
> +	if (memhp_autoonline == MMOP_ONLINE_KEEP)
> +		return sprintf(buf, "online\n");
> +	else if (memhp_autoonline == MMOP_OFFLINE)
> +		return sprintf(buf, "offline\n");
> +	else
> +		return sprintf(buf, "unknown\n");

You do not allow unknown state below, so, I do not know how it can appear
here. If it appears out of the blue then I think that we should be alert
because something magic happens around us. Hence, if you wish to leave
this unknown stuff then I suppose we should at least call WARN_ON() if
not BUG_ON() there too (well, I am not convinced about latter).

> +}
> +
> +static ssize_t
> +store_memhp_autoonline(struct device *dev, struct device_attribute *attr,
> +		       const char *buf, size_t count)
> +{
> +	if (sysfs_streq(buf, "online"))
> +		memhp_autoonline = MMOP_ONLINE_KEEP;
> +	else if (sysfs_streq(buf, "offline"))
> +		memhp_autoonline = MMOP_OFFLINE;
> +	else
> +		return -EINVAL;

Here you are not able to set anything which is not allowed.
So, please look above.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
