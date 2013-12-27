Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 07F376B0037
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 22:22:18 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so7676490wgg.4
        for <linux-mm@kvack.org>; Thu, 26 Dec 2013 19:22:18 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id 10si12298294wjp.35.2013.12.26.19.22.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Dec 2013 19:22:18 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id cc10so9189374wib.10
        for <linux-mm@kvack.org>; Thu, 26 Dec 2013 19:22:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJrk0BuA2OTfMhmqZ-OFvtbdf_8+O3V77L0mDsoixN+t4A0ASA@mail.gmail.com>
References: <CAJrk0BuA2OTfMhmqZ-OFvtbdf_8+O3V77L0mDsoixN+t4A0ASA@mail.gmail.com>
Date: Fri, 27 Dec 2013 14:22:18 +1100
Message-ID: <CAJrk0Bsz6VCcyxuR7-MLV7SjhXMJzvBqvuDbUsD+CLgHEF=j6Q@mail.gmail.com>
Subject: Re: [REGRESSION] [BISECTED] MM patch causes kernel lockup with 3.12
 and acpi_backlight=vendor
From: Bradley Baetz <bbaetz@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org
Cc: hdegoede@redhat.com

Resending in plain text mode....

Bradley

On Fri, Dec 27, 2013 at 2:21 PM, Bradley Baetz <bbaetz@gmail.com> wrote:
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
> so I'm pretty sure that that is the patch that causes (or at least triggers)
> this issue
>
> I'm using the acpi_backlight option to get the backlight working - without
> this the backlight doesn't work at all. Removing 'acpi_backlight=vendor' (or
> blacklisting the dell-laptop module, which is effectively the same thing)
> fixes the issue.
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
>
> I did successfully boot a 3.12 kernel on F19 (before I upgraded to F20), so
> there's presumably something that F20 is doing differently. It was only one
> boot though.
>
> I reported this to fedora
> (https://bugzilla.redhat.com/show_bug.cgi?id=1045807) but it looks like this
> is an upstream issue so I was asked to report it here.
>
> This is an 8-core single i7 cpu (one numa node) - its a laptop, so nothing
> fancy. DMI data is attached to the fedora bug.
>
> Bradley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
