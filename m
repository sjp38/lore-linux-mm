Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id 81EBC6B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 12:13:29 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id u14so5703907bkz.25
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 09:13:28 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id lx9si23286055bkb.59.2014.01.06.09.13.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 09:13:28 -0800 (PST)
Date: Mon, 6 Jan 2014 12:13:24 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [REGRESSION] [BISECTED] MM patch causes kernel lockup with 3.12
 and acpi_backlight=vendor
Message-ID: <20140106171324.GA6963@cmpxchg.org>
References: <CAJrk0BuA2OTfMhmqZ-OFvtbdf_8+O3V77L0mDsoixN+t4A0ASA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJrk0BuA2OTfMhmqZ-OFvtbdf_8+O3V77L0mDsoixN+t4A0ASA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bradley Baetz <bbaetz@gmail.com>
Cc: platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, hdegoede@redhat.com

Hi Bradley,

On Fri, Dec 27, 2013 at 02:21:21PM +1100, Bradley Baetz wrote:
> Hi,
> 
> I have a Dell laptop (Vostro 3560). When I boot Fedora 20 with the
> acpi_backlight=vendor option, the kernel locks up hard during the boot
> proces, when systemd runs udevadm trigger. This is a hard lockup -
> magic-sysrq doesn't work, and neither does caps lock/vt-change/etc.
> 
> I've bisected this to:
> 
> commit 81c0a2bb515fd4daae8cab64352877480792b515
> Author: Johannes Weiner <hannes@cmpxchg.org>
> Date:   Wed Sep 11 14:20:47 2013 -0700
> 
>     mm: page_alloc: fair zone allocator policy
> 
> which seemed really unrelated, but I've confirmed that:
> 
>  - the commit before this patch doesn't cause the problem, and the commit
> afterwrads does
>  - reverting that patch from 3.12.0 fixes the problem
>  - reverting that patch (and the partial revert
> fff4068cba484e6b0abe334ed6b15d5a215a3b25) from master also fixes the problem
>  - reverting that patch from the fedora 3.12.5-302.fc20 kernel fixes the
> problem
>  - applying that patch to 3.11.0 causes the problem
> 
> so I'm pretty sure that that is the patch that causes (or at least
> triggers) this issue
> 
> I'm using the acpi_backlight option to get the backlight working - without
> this the backlight doesn't work at all. Removing 'acpi_backlight=vendor'
> (or blacklisting the dell-laptop module, which is effectively the same
> thing) fixes the issue.
> 
> The lockup happens when systemd runs "udevadm trigger", not when the module
> is loaded - I can reproduce the issue by booting into emergency mode,
> remounting the filesystem as rw, starting up systemd-udevd and running
> udevadm trigger manually. It dies a few seconds after loading the
> dell-laptop module.
> 
> This happens even if I don't boot into X (using
> systemd.unit=multi-user.target)
> 
> Triggering udev individually for each item doesn't trigger the issue ie:
> 
> for i in `udevadm --debug trigger --type=devices --action=add --dry-run
> --verbose`; do echo $i; udevadm --debug trigger --type=devices --action=add
> --verbose --parent-match=$i; sleep 1; done
> 
> works, so I haven't been able to work out what specific combination of
> actions are causing this.
> 
> With the acpi_backlight option, I can manually read/write to the sysfs
> dell-laptop backlight file, and it works (and changes the backlight as
> expected)
> 
> This is 100% reproducible. I've also tested by powering off the laptop and
> pulling the battery just in case one of the previous boots with the bisect
> left the hardware in a strange state - no change.

My patch aggressively spreads allocations over all zones in the
system, but it should still respect dell-laptop's requirements for
DMA32 memory.

I wonder if the drastic change in allocation placement exposes an
existing memory corruption.  In fact, the dell-laptop module is
confused when it comes to the page allocator interface, it does

  free_page((unsigned long)bufferpage);

in the error path, where bufferpage is a page pointer that came out of
alloc_page(), which will cause the page allocator to try to free the
mem_map(!) page that backs the bufferpage page struct.  So one failed
load attempt of the module could plausibly corrupt internal state.

Does the following resolve the problem?  And if not, what are the
"dell-laptop:" lines in the good and the bad kernel, and does the bad
kernel trigger the WARNING?

---

diff --git a/drivers/platform/x86/dell-laptop.c b/drivers/platform/x86/dell-laptop.c
index c608b1d33f4a..92088b228573 100644
--- a/drivers/platform/x86/dell-laptop.c
+++ b/drivers/platform/x86/dell-laptop.c
@@ -819,6 +819,18 @@ static int __init dell_init(void)
 		ret = -ENOMEM;
 		goto fail_buffer;
 	}
+
+	{
+		struct zone *zone = page_zone(bufferpage);
+		int idx = zone_idx(zone);
+
+		printk("dell-laptop: bufferpage (%p) in node %d zone %d (%s)\n", bufferpage, zone->node, idx, zone->name);
+		if (WARN_ON(idx > ZONE_DMA32)) {
+			ret = -EINVAL;
+			goto fail_rfkill;
+		}
+	}
+
 	buffer = page_address(bufferpage);
 
 	ret = dell_setup_rfkill();
@@ -888,7 +900,7 @@ fail_backlight:
 fail_filter:
 	dell_cleanup_rfkill();
 fail_rfkill:
-	free_page((unsigned long)bufferpage);
+	__free_page(bufferpage);
 fail_buffer:
 	platform_device_del(platform_device);
 fail_platform_device2:
@@ -914,7 +926,7 @@ static void __exit dell_exit(void)
 		platform_driver_unregister(&platform_driver);
 	}
 	kfree(da_tokens);
-	free_page((unsigned long)buffer);
+	__free_page(bufferpage);
 }
 
 module_init(dell_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
