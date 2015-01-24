Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 433B56B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 23:38:02 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id a41so185954yho.1
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 20:38:01 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id 196si733138ykw.151.2015.01.23.20.37.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 20:37:59 -0800 (PST)
Date: Fri, 23 Jan 2015 22:37:46 -0600
From: Nishanth Menon <nm@ti.com>
Subject: Re: [next-20150119]regression (mm)?
Message-ID: <20150124043746.GA22262@kahuna>
References: <20150119174317.GK20386@saruman>
 <20150120001643.7D15AA8@black.fi.intel.com>
 <20150120114555.GA11502@n2100.arm.linux.org.uk>
 <20150120140546.DDCB8D4@black.fi.intel.com>
 <20150123172736.GA15392@kahuna>
 <CANMBJr7w2jZBwRDEsVNvL3XrDZ2ttwFz7qBf4zySAMMmcgAxiw@mail.gmail.com>
 <20150123183706.GA15791@kahuna>
 <20150123202229.GA9038@node.dhcp.inet.fi>
 <CANMBJr4YOcHj2G7w-gwfoZjQQd=h0Mj59QNBo3ei_=ejYRcdnw@mail.gmail.com>
 <20150124011311.GB9038@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150124011311.GB9038@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Tyler Baker <tyler.baker@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Felipe Balbi <balbi@ti.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, linux-omap <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 03:13-20150124, Kirill A. Shutemov wrote:
> > >> On 09:39-20150123, Tyler Baker wrote:
[...]
> > >> > I just reviewed the boot logs for next-20150123 and there still seems
> > >> > to be a related issue. I've been boot testing
> > >> > multi_v7_defconfig+CONFIG_ARM_LPAE=y kernel configurations which still
> > >> > seem broken.
[...]
> Okay, proof of concept patch is below. It's going to break every other
> architecture with FIRST_USER_ADDRESS != 0, but I think it's cleaner way to
> go.

Testing on my end:

just ran through this set (+ logs similar to Tyler's from my side):

next-20150123 (multi_v7_defconfig == !LPAE)
 1:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2219449
 2:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2219450
 3:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2219451
 4:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2219452
TOTAL = 4 boards, Booted Boards = 4, No Boot boards = 0

next-20150123-LPAE-Logging enabled[1] (multi_v7_defconfig +LPAE)
 1:    BeagleBoard-X15(am57xx-evm): BOOT: FAIL: http://paste.ubuntu.org.cn/2220938
 2:                     dra72x-evm: BOOT: FAIL: http://paste.ubuntu.org.cn/2220943
 3:                     dra7xx-evm: BOOT: FAIL: http://paste.ubuntu.org.cn/2220947
 4:                      omap5-evm: BOOT: FAIL: http://paste.ubuntu.org.cn/2220955
TOTAL = 4 boards, Booted Boards = 0, No Boot boards = 4

next-20150123-LPAE-new-patch [2] (multi_v7_defconfig + LPAE)
 1:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2221047
 2:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221065
 3:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221069
 4:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221070
TOTAL = 4 boards, Booted Boards = 4, No Boot boards = 0

next-20150123-new-patch[2] (multi_v7_defconfig == !LPAE)
 1:                     am335x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221277
 2:                      am335x-sk: BOOT: PASS: http://paste.ubuntu.org.cn/2221278
 3:                      am437x-sk: BOOT: FAIL: http://paste.ubuntu.org.cn/2221279 (unrelated)
 4:                    am43xx-epos: BOOT: PASS: http://paste.ubuntu.org.cn/2221280
 5:                   am43xx-gpevm: BOOT: PASS: http://paste.ubuntu.org.cn/2221281
 6:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2221282
 7:                 BeagleBoard-XM: BOOT: FAIL: http://paste.ubuntu.org.cn/2221283 (unrelated)
 8:            beagleboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221284
 9:               beaglebone-black: BOOT: PASS: http://paste.ubuntu.org.cn/2221285
10:                     beaglebone: BOOT: FAIL: http://paste.ubuntu.org.cn/2221286 (unrelated)
11:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221287
12:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221288
13:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221289
14:                  pandaboard-es: BOOT: PASS: http://paste.ubuntu.org.cn/2221290
15:             pandaboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221291
16:                        sdp4430: BOOT: PASS: http://paste.ubuntu.org.cn/2221292
TOTAL = 16 boards, Booted Boards = 13, No Boot boards = 3

next-20150123-new-patch[2] (omap2plus_defconfig)
 1:                     am335x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221653
 2:                      am335x-sk: BOOT: PASS: http://paste.ubuntu.org.cn/2221654
 3:                      am437x-sk: BOOT: PASS: http://paste.ubuntu.org.cn/2221656
 4:                    am43xx-epos: BOOT: PASS: http://paste.ubuntu.org.cn/2221659
 5:                   am43xx-gpevm: BOOT: PASS: http://paste.ubuntu.org.cn/2221660
 6:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2221661
 7:                 BeagleBoard-XM: BOOT: PASS: http://paste.ubuntu.org.cn/2221670
 8:            beagleboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221676
 9:               beaglebone-black: BOOT: PASS: http://paste.ubuntu.org.cn/2221683
10:                     beaglebone: BOOT: PASS: http://paste.ubuntu.org.cn/2221690
11:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221692
12:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221695
13:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221700
14:                  pandaboard-es: BOOT: PASS: http://paste.ubuntu.org.cn/2221704
15:             pandaboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221707
16:                        sdp4430: BOOT: PASS: http://paste.ubuntu.org.cn/2221713
TOTAL = 16 boards, Booted Boards = 16, No Boot boards = 0

[1] http://paste.ubuntu.org.cn/2220994 (based on diff from Tyler B)
[2] https://patchwork.kernel.org/patch/5698491/
-- 
Regards,
Nishanth Menon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
