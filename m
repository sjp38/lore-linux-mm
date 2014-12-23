Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 926986B0032
	for <linux-mm@kvack.org>; Sun, 28 Dec 2014 07:51:44 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so20099480wid.3
        for <linux-mm@kvack.org>; Sun, 28 Dec 2014 04:51:44 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id fz7si66628742wjb.100.2014.12.28.04.51.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Dec 2014 04:51:43 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC][PATCH RESEND] mm: vmalloc: remove ioremap align constraint
Date: Tue, 23 Dec 2014 21:58:49 +0100
Message-ID: <11656044.WGcPr1b8t8@wuerfel>
In-Reply-To: <1419328813-2211-1-git-send-email-d.safonov@partner.samsung.com>
References: <1419328813-2211-1-git-send-email-d.safonov@partner.samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Dmitry Safonov <d.safonov@partner.samsung.com>, linux-mm@kvack.org, Nicolas Pitre <nicolas.pitre@linaro.org>, Russell King <linux@arm.linux.org.uk>, Dyasly Sergey <s.dyasly@samsung.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, James Bottomley <JBottomley@parallels.com>, Arnd Bergmann <arnd.bergmann@linaro.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Andrew Morton <akpm@linux-foundation.org>

On Tuesday 23 December 2014 13:00:13 Dmitry Safonov wrote:
> ioremap uses __get_vm_area_node which sets alignment to fls of requested size.
> I couldn't find any reason for such big align. Does it decrease TLB misses?
> I tested it on custom ARM board with 200+ Mb of ioremap and it works.
> What am I missing?

The alignment was originally introduced in this commit:

commit ff0daca525dde796382b9ccd563f169df2571211
Author: Russell King <rmk@dyn-67.arm.linux.org.uk>
Date:   Thu Jun 29 20:17:15 2006 +0100

    [ARM] Add section support to ioremap
    
    Allow section mappings to be setup using ioremap() and torn down
    with iounmap().  This requires additional support in the MM
    context switch to ensure that mappings are properly synchronised
    when mapped in.
    
    Based an original implementation by Deepak Saxena, reworked and
    ARMv6 support added by rmk.
    
    Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

and then later extended to 16MB supersection mappings, which indeed
is used to reduce TLB pressure.

I don't see any downsides to it, why change it?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
