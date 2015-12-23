Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1DC6B02AA
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 15:15:45 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l126so163049153wml.1
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 12:15:44 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id ia6si66632844wjb.29.2015.12.23.12.15.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Dec 2015 12:15:43 -0800 (PST)
Date: Wed, 23 Dec 2015 20:15:29 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
Message-ID: <20151223201529.GX8644@n2100.arm.linux.org.uk>
References: <20151202202725.GA794@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151202202725.GA794@www.outflux.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nico@linaro.org>, Arnd Bergmann <arnd@arndb.de>, kernel-hardening@lists.openwall.com

On Wed, Dec 02, 2015 at 12:27:25PM -0800, Kees Cook wrote:
> The use of CONFIG_DEBUG_RODATA is generally seen as an essential part of
> kernel self-protection:
> http://www.openwall.com/lists/kernel-hardening/2015/11/30/13
> Additionally, its name has grown to mean things beyond just rodata. To
> get ARM closer to this, we ought to rearrange the names of the configs
> that control how the kernel protects its memory. What was called
> CONFIG_ARM_KERNMEM_PERMS is really doing the work that other architectures
> call CONFIG_DEBUG_RODATA.

Kees,

There is a subtle problem with the kernel memory permissions and the
DMA debugging.

DMA debugging checks whether we're trying to do DMA from the kernel
mappings (text, rodata, data etc).  It checks _text.._etext.  However,
when RODATA is enabled, we have about one section between _text and
_stext which are freed into the kernel's page pool, and then become
available for allocation and use for DMA.

This then causes the DMA debugging sanity check to fire.

So, I think I'll revert this change for the time being as it seems to
be causing many people problems, and having this enabled is creating
extra warnings when kernel debug options are enabled along with it.

Sorry.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
