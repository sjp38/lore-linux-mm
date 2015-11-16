Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C6AF36B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 14:45:46 -0500 (EST)
Received: by wmec201 with SMTP id c201so136110121wme.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:45:46 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id kb1si48162890wjc.20.2015.11.16.11.45.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Nov 2015 11:45:45 -0800 (PST)
Date: Mon, 16 Nov 2015 19:45:28 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 07/12] ARM: split off core mapping logic from
 create_mapping
Message-ID: <20151116194528.GI8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
 <1447698757-8762-8-git-send-email-ard.biesheuvel@linaro.org>
 <20151116185519.GE8644@n2100.arm.linux.org.uk>
 <CAKv+Gu-P45_S2aHE2Dr=i-2e29-DvmSBR_JWec=JPcZeTMn02Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu-P45_S2aHE2Dr=i-2e29-DvmSBR_JWec=JPcZeTMn02Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Matt Fleming <matt.fleming@intel.com>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Leif Lindholm <leif.lindholm@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, Ryan Harkin <ryan.harkin@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Nov 16, 2015 at 08:01:03PM +0100, Ard Biesheuvel wrote:
> On 16 November 2015 at 19:55, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > I'm slightly worried about this.  Generally, these functions setup
> > global mappings.  If you're wanting to have a private set of page
> > tables for UEFI, and those private page tables contain global
> > mappings which are different from the mappings in the kernel's page
> > tables, then you need careful break-TLBflush-make handling when
> > switching from the kernel's page tables to the private UEFI ones,
> > and vice versa.
> >
> > Has this aspect been considered?
> 
> Yes. The UEFI mappings are all below 1 GB, and the top kernel end is
> reused as we do for ordinary userland page tables. The switch to the
> UEFI page tables performs a full TLB flush. What it does not do is
> break before make, as far as I can tell, so any pointers regarding how
> to implement that would be appreciated (this is implemented in 11/12)

What matters is whether they are global mappings or not.  If they are,
when the TLB can contain conflicting entries.  If they are non-global
mappings, they will be tagged with the ASID which makes them unique
to each mm.

The simple solution is to ensure that they're non-global, and then you
don't need to even worry about flushing the TLB when switching.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
