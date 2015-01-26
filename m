Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 07D866B006E
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:01:16 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id h11so9238623wiw.1
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 04:01:15 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id bj2si19876379wjb.96.2015.01.26.04.01.12
        for <linux-mm@kvack.org>;
        Mon, 26 Jan 2015 04:01:12 -0800 (PST)
Date: Mon, 26 Jan 2015 14:00:43 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [next-20150119]regression (mm)?
Message-ID: <20150126120043.GB25833@node.dhcp.inet.fi>
References: <20150120001643.7D15AA8@black.fi.intel.com>
 <20150120114555.GA11502@n2100.arm.linux.org.uk>
 <20150120140546.DDCB8D4@black.fi.intel.com>
 <20150123172736.GA15392@kahuna>
 <CANMBJr7w2jZBwRDEsVNvL3XrDZ2ttwFz7qBf4zySAMMmcgAxiw@mail.gmail.com>
 <20150123183706.GA15791@kahuna>
 <20150123202229.GA9038@node.dhcp.inet.fi>
 <CANMBJr4YOcHj2G7w-gwfoZjQQd=h0Mj59QNBo3ei_=ejYRcdnw@mail.gmail.com>
 <20150124011311.GB9038@node.dhcp.inet.fi>
 <20150124043746.GA22262@kahuna>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150124043746.GA22262@kahuna>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Menon <nm@ti.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tyler Baker <tyler.baker@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Felipe Balbi <balbi@ti.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, linux-omap <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, James Hogan <james.hogan@imgtec.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>

On Fri, Jan 23, 2015 at 10:37:46PM -0600, Nishanth Menon wrote:
> On 03:13-20150124, Kirill A. Shutemov wrote:
> > > >> On 09:39-20150123, Tyler Baker wrote:
> [...]
> > > >> > I just reviewed the boot logs for next-20150123 and there still seems
> > > >> > to be a related issue. I've been boot testing
> > > >> > multi_v7_defconfig+CONFIG_ARM_LPAE=y kernel configurations which still
> > > >> > seem broken.
> [...]
> > Okay, proof of concept patch is below. It's going to break every other
> > architecture with FIRST_USER_ADDRESS != 0, but I think it's cleaner way to
> > go.
> 
> Testing on my end:
> 
> just ran through this set (+ logs similar to Tyler's from my side):
> 
> next-20150123 (multi_v7_defconfig == !LPAE)
>  1:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2219449
>  2:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2219450
>  3:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2219451
>  4:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2219452
> TOTAL = 4 boards, Booted Boards = 4, No Boot boards = 0
> 
> next-20150123-LPAE-Logging enabled[1] (multi_v7_defconfig +LPAE)
>  1:    BeagleBoard-X15(am57xx-evm): BOOT: FAIL: http://paste.ubuntu.org.cn/2220938
>  2:                     dra72x-evm: BOOT: FAIL: http://paste.ubuntu.org.cn/2220943
>  3:                     dra7xx-evm: BOOT: FAIL: http://paste.ubuntu.org.cn/2220947
>  4:                      omap5-evm: BOOT: FAIL: http://paste.ubuntu.org.cn/2220955
> TOTAL = 4 boards, Booted Boards = 0, No Boot boards = 4
> 
> next-20150123-LPAE-new-patch [2] (multi_v7_defconfig + LPAE)
>  1:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2221047
>  2:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221065
>  3:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221069
>  4:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221070
> TOTAL = 4 boards, Booted Boards = 4, No Boot boards = 0
> 
> next-20150123-new-patch[2] (multi_v7_defconfig == !LPAE)
>  1:                     am335x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221277
>  2:                      am335x-sk: BOOT: PASS: http://paste.ubuntu.org.cn/2221278
>  3:                      am437x-sk: BOOT: FAIL: http://paste.ubuntu.org.cn/2221279 (unrelated)
>  4:                    am43xx-epos: BOOT: PASS: http://paste.ubuntu.org.cn/2221280
>  5:                   am43xx-gpevm: BOOT: PASS: http://paste.ubuntu.org.cn/2221281
>  6:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2221282
>  7:                 BeagleBoard-XM: BOOT: FAIL: http://paste.ubuntu.org.cn/2221283 (unrelated)
>  8:            beagleboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221284
>  9:               beaglebone-black: BOOT: PASS: http://paste.ubuntu.org.cn/2221285
> 10:                     beaglebone: BOOT: FAIL: http://paste.ubuntu.org.cn/2221286 (unrelated)
> 11:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221287
> 12:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221288
> 13:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221289
> 14:                  pandaboard-es: BOOT: PASS: http://paste.ubuntu.org.cn/2221290
> 15:             pandaboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221291
> 16:                        sdp4430: BOOT: PASS: http://paste.ubuntu.org.cn/2221292
> TOTAL = 16 boards, Booted Boards = 13, No Boot boards = 3
> 
> next-20150123-new-patch[2] (omap2plus_defconfig)
>  1:                     am335x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221653
>  2:                      am335x-sk: BOOT: PASS: http://paste.ubuntu.org.cn/2221654
>  3:                      am437x-sk: BOOT: PASS: http://paste.ubuntu.org.cn/2221656
>  4:                    am43xx-epos: BOOT: PASS: http://paste.ubuntu.org.cn/2221659
>  5:                   am43xx-gpevm: BOOT: PASS: http://paste.ubuntu.org.cn/2221660
>  6:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2221661
>  7:                 BeagleBoard-XM: BOOT: PASS: http://paste.ubuntu.org.cn/2221670
>  8:            beagleboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221676
>  9:               beaglebone-black: BOOT: PASS: http://paste.ubuntu.org.cn/2221683
> 10:                     beaglebone: BOOT: PASS: http://paste.ubuntu.org.cn/2221690
> 11:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221692
> 12:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221695
> 13:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221700
> 14:                  pandaboard-es: BOOT: PASS: http://paste.ubuntu.org.cn/2221704
> 15:             pandaboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221707
> 16:                        sdp4430: BOOT: PASS: http://paste.ubuntu.org.cn/2221713
> TOTAL = 16 boards, Booted Boards = 16, No Boot boards = 0

Okay thanks. Here's proper patch.
