Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 917E36B0253
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 14:01:09 -0500 (EST)
Received: by iouu10 with SMTP id u10so93298900iou.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 11:01:09 -0800 (PST)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id z8si317396igl.72.2015.12.03.11.01.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 11:01:08 -0800 (PST)
Received: by igcmv3 with SMTP id mv3so19812538igc.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 11:01:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151203184051.GE3213@pd.tnic>
References: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
	<1448404418-28800-2-git-send-email-toshi.kani@hpe.com>
	<20151201135000.GB4341@pd.tnic>
	<CAPcyv4g2n9yTWye2aVvKMP0X7mrm_NLKmGd5WBO2SesTj77gbg@mail.gmail.com>
	<20151201171322.GD4341@pd.tnic>
	<CA+55aFw22JD8W2cy3w=5VcU9-ENXSP9utmhGB2NeiDVqwpnUSw@mail.gmail.com>
	<1449168859.9855.54.camel@hpe.com>
	<20151203184051.GE3213@pd.tnic>
Date: Thu, 3 Dec 2015 11:01:08 -0800
Message-ID: <CA+55aFy4WQrWexC4u2LxX9Mw2NVoznw7p3Yh=iF4Xtf7zKWnRw@mail.gmail.com>
Subject: Re: [PATCH v3 1/3] resource: Add @flags to region_intersects()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Toshi Kani <toshi.kani@hpe.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Tony Luck <tony.luck@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Dec 3, 2015 at 10:40 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Thu, Dec 03, 2015 at 11:54:19AM -0700, Toshi Kani wrote:
>> Adding a new type for regular memory will require inspecting the codes
>> using IORESOURCE_MEM currently, and modify them to use the new type if
>> their target ranges are regular memory.  There are many references to this
>> type across multiple architectures and drivers, which make this inspection
>> and testing challenging.
>
> What's wrong with adding a new type_flags to struct resource and not
> touching IORESOURCE_* at all?

Bah. Both of these ideas are bogus.

Just add a new flag. The bits are already modifiers that you can
*combine* to show what kind of resource it is, and we already have
things like IORESOURCE_PREFETCH etc, that are in *addition* to the
normal IORESOURCE_MEM bit.

Just add another modifier: IORESOURCE_RAM.

So it would still show up as IORESOURCE_MEM, but it would have
additional information specifying that it's actually RAM.

If somebody does something like

     if (res->flags == IORESOURCE_MEM)

then they are already completely broken and won't work *anyway*. It's
a bitmask, bit a set of values.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
