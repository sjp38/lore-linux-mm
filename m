Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE82A6B0069
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 10:44:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r83so19937248pfj.5
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 07:44:13 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d19si9658008pgn.304.2017.10.03.07.44.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 07:44:12 -0700 (PDT)
Received: from mail-qt0-f169.google.com (mail-qt0-f169.google.com [209.85.216.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 261A1218CD
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 14:44:12 +0000 (UTC)
Received: by mail-qt0-f169.google.com with SMTP id o52so13348649qtc.9
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 07:44:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171001082955.GA17116@infradead.org>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org>
 <20170927233224.31676-2-nicolas.pitre@linaro.org> <20171001082955.GA17116@infradead.org>
From: Rob Herring <robh@kernel.org>
Date: Tue, 3 Oct 2017 09:43:50 -0500
Message-ID: <CAL_JsqK1FhN7f55ZDinX+PKaO_e7m7bxCgBeHg=hzCRn+TSwSA@mail.gmail.com>
Subject: Re: [PATCH v4 1/5] cramfs: direct memory access support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-embedded@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Chris Brandt <Chris.Brandt@renesas.com>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>

On Sun, Oct 1, 2017 at 3:29 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Sep 27, 2017 at 07:32:20PM -0400, Nicolas Pitre wrote:
>> To distinguish between both access types, the cramfs_physmem filesystem
>> type must be specified when using a memory accessible cramfs image, and
>> the physaddr argument must provide the actual filesystem image's physical
>> memory location.
>
> Sorry, but this still is a complete no-go.  A physical address is not a
> proper interface.  You still need to have some interface for your NOR nand
> or DRAM.  - usually that would be a mtd driver, but if you have a good
> reason why that's not suitable for you (and please explain it well)
> we'll need a little OF or similar layer to bind a thin driver.

I don't disagree that we may need DT binding here, but DT bindings are
h/w description and not a mechanism bind Linux kernel drivers. It can
be a subtle distinction, but it is an important one.

I can see the case where we have no driver. For RAM we don't have a
driver, yet pretty much all hardware has a DRAM controller which we
just rely on the firmware to setup. I could also envision that we have
hardware we do need to configure in the kernel. Perhaps the boot
settings are not optimal or we want/need to manage the clocks. That
seems somewhat unlikely if the kernel is also XIP from the same flash
as it is in Nico's case.

We do often describe the flash layout in DT when partitions are not
discoverable. I don't know if that would be needed here. Would the ROM
here ever be updateable from within Linux? If we're talking about a
single address to pass the kernel, DT seems like an overkill and
kernel cmdline is perfectly valid IMO.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
