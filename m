Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id DCA846B0263
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 14:02:14 -0500 (EST)
Received: by wmec201 with SMTP id c201so192617146wme.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:02:14 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id a15si20568848wma.114.2015.11.16.11.02.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Nov 2015 11:02:13 -0800 (PST)
Date: Mon, 16 Nov 2015 19:01:56 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 11/12] ARM: wire up UEFI init and runtime support
Message-ID: <20151116190156.GH8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
 <1447698757-8762-12-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447698757-8762-12-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, matt.fleming@intel.com, will.deacon@arm.com, grant.likely@linaro.org, catalin.marinas@arm.com, mark.rutland@arm.com, leif.lindholm@linaro.org, roy.franz@linaro.org, msalter@redhat.com, ryan.harkin@linaro.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon, Nov 16, 2015 at 07:32:36PM +0100, Ard Biesheuvel wrote:
> +static inline void efi_set_pgd(struct mm_struct *mm)
> +{
> +	if (unlikely(mm->context.vmalloc_seq != init_mm.context.vmalloc_seq))
> +		__check_vmalloc_seq(mm);
> +
> +	cpu_switch_mm(mm->pgd, mm);
> +
> +	flush_tlb_all();
> +	if (icache_is_vivt_asid_tagged())
> +		__flush_icache_all();
> +}

I don't think that's sufficient.  There's a gap between switching the mm
and flushing the TLBs where we could have different global TLB entries
from those in the page tables - and that can cause problems with CPUs
which speculatively prefetch.  Some CPUs raise exceptions for this...

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
