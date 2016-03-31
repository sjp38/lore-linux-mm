Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4606B025E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 16:01:49 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id m7so34888896obh.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 13:01:49 -0700 (PDT)
Received: from ni.com (skprod2.natinst.com. [130.164.80.23])
        by mx.google.com with ESMTPS id w3si5827805oey.69.2016.03.31.13.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 13:01:48 -0700 (PDT)
Date: Thu, 31 Mar 2016 15:01:47 -0500
From: Josh Cartwright <joshc@ni.com>
Subject: Re: Issue with ioremap
Message-ID: <20160331200147.GA20530@jcartwri.amer.corp.natinst.com>
References: <CAGnW=BYw9iqm8BpuWrxgcvXV3wwvHcvMtynPeHUGHHiZfPmfuA@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CAGnW=BYw9iqm8BpuWrxgcvXV3wwvHcvMtynPeHUGHHiZfPmfuA@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: punnaiah choudary kalluri <punnaia@xilinx.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Apr 01, 2016 at 01:13:06AM +0530, punnaiah choudary kalluri wrote:
> Hi,
> 
> We are using the pl353 smc controller for interfacing the nand in our zynq SOC.
> The driver for this controller is currently under mainline review.
> Recently we are moved to 4.4 kernel and observing issues with the driver.
> while debug, found that the issue is with the virtual address returned from
> the ioremap is not aligned to the physical address and causing nand
> access failures.
> the nand controller physical address starts at 0xE1000000 and the size is 16MB.
> the ioremap function in 4.3 kernel returns the virtual address that is
> aligned to the size
> but not the case in 4.4 kernel.

:(.  I had actually ran into this, too, as I was evaluating the use of
the upstream-targetted pl353 stuff; sorry I didn't say anything.

> this controller uses the bits [31:24] as base address and use rest all
> bits for configuring adders cycles, chip select information. so it
> expects the virtual address also aligned to 0xFF000000 otherwise the
> nand commands issued will fail.

The driver _currently_ expects the virtual address to be 16M aligned,
but is that a hard requirement?  It seems possible that the driver could
be written without this assumption, correct?

This would mean that the driver would need to maintain the cs/cycles
configuration state outside of the mapped virtual address, and then
calculate + add the calculated offset to the base.  Would that work?
I had been meaning to give it a try, but haven't gotten around to it.

  Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
