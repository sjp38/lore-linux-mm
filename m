Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 955F18E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 06:28:50 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so5808307edd.2
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 03:28:50 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id j30si4189368edc.365.2019.01.11.03.28.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 03:28:48 -0800 (PST)
Date: Fri, 11 Jan 2019 12:28:40 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: (ghes|hest)_disable
Message-ID: <20190111112840.GB4729@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>, Tony Luck <tony.luck@intel.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

Ok,

lemme split this out into a separate thread and add Tony.

On Thu, Jan 10, 2019 at 06:20:35PM +0000, James Morse wrote:
> > Grrr, what an effing mess that code is! There's hest_disable *and*
> > ghes_disable. Do we really need them both?
> 
> ghes_disable lets you ignore the firmware-first notifications, but still 'use'
> the other error sources:
> drivers/pci/pcie/aer.c picks out the three AER types, and uses apei_hest_parse()
> to know if firmware is controlling AER, even if ghes_disable is set.

Ok, that kinda makes sense.

But look what our sparse documentation says:

        hest_disable    [ACPI]
                        Disable Hardware Error Source Table (HEST) support;
                        corresponding firmware-first mode error processing
                        logic will be disabled.


and from looking at the code, hest_disable is kinda like the master
switch because it gets evaluated first. Right?

Which sounds to me like we want a generic switch which does:

	apei=disable_ff_notifications

to explicitly do exactly that - disable the firmware-first notification
method. And then the master switch will be

	apei=disable

And we'll be able to pass whatever options here instead of all those
different _disable switches which need lotsa code staring to figure out
what exactly they even do in the first place.

> x86's arch_apei_enable_cmcff() looks like it disables MCE to get firmware to
> handle them. hest_disable would stop this, but instead ghes_disable keeps that,
> and stops the NOTIFY_NMI being registered.

Yeah, and when you boot with ghes_disable, that would say:

	pr_info("HEST: Enabling Firmware First mode for corrected errors.\n");

but there will be no notifications and users will scratch heads.

> (do you consider cmdline arguments as ABI, or hard to justify and hard to remove?)

I don't, frankly. I guess we will have to have a transition period where
we keep them and issue a warning message that users should switch to
"apei=xxx" instead and remove them after a lot of time has passed.

> I don't think its broken enough to justify ripping them out. A user of
> ghes_disable would be someone with broken firmware-first handling of AER. They
> need to know firmware is changing the register values behind their back (so need
> to parse the HEST), but want to ignore the junk notifications. It doesn't sound
> like an unlikely scenario.

Yes, that makes sense.

But I think we should add a generic cmdline arg with suboptions and
document exactly what all those do. Similar to "mce=" on x86 which is
nicely documented in Documentation/x86/x86_64/boot-options.txt.

Right now, only a few people understand what those do and in some of the
cases they do too much/the wrong thing.

Thoughts?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
