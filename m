Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2166B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 05:13:57 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so4250198pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:13:57 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id r3si1075444pap.0.2015.09.22.02.13.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Sep 2015 02:13:56 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NV200D60MZ4DV70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 22 Sep 2015 10:13:52 +0100 (BST)
Subject: Re: [PATCH 00/38] Fixes related to incorrect usage of unsigned types
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
 <17571.1442842945@warthog.procyon.org.uk>
From: Andrzej Hajda <a.hajda@samsung.com>
Message-id: <56011BB9.5030004@samsung.com>
Date: Tue, 22 Sep 2015 11:13:29 +0200
MIME-version: 1.0
In-reply-to: <17571.1442842945@warthog.procyon.org.uk>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, brcm80211-dev-list@broadcom.com, devel@driverdev.osuosl.org, dev@openvswitch.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-api@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cachefs@redhat.com, linux-clk@vger.kernel.org, linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-input@vger.kernel.orglinux-kernel@vger.kernel.org, linux-leds@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-omap@vger.kernel.org, linux-rdma@vger.kernel.org, linux-serial@vger.kernel.org, linux-sh@vger.kernel.org, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, lustre-devel@lists.lustre.org, netdev@vger.kernel.org, rtc-linux@googlegroups.com

On 09/21/2015 03:42 PM, David Howells wrote:
> Andrzej Hajda <a.hajda-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org> wrote:
> 
>> Semantic patch finds comparisons of types:
>>     unsigned < 0
>>     unsigned >= 0
>> The former is always false, the latter is always true.
>> Such comparisons are useless, so theoretically they could be
>> safely removed, but their presence quite often indicates bugs.
> 
> Or someone has left them in because they don't matter and there's the
> possibility that the type being tested might be or become signed under some
> circumstances.  If the comparison is useless, I'd expect the compiler to just
> discard it - for such cases your patch is pointless.
> 
> If I have, for example:
> 
> 	unsigned x;
> 
> 	if (x == 0 || x > 27)
> 		give_a_range_error();
> 
> I will write this as:
> 
> 	unsigned x;
> 
> 	if (x <= 0 || x > 27)
> 		give_a_range_error();
> 
> because it that gives a way to handle x being changed to signed at some point
> in the future for no cost.  In which case, your changing the <= to an ==
> "because the < part of the case is useless" is arguably wrong.

This is why I have not checked for such cases - I have skipped checks of type
	unsigned <= 0
exactly for the reasons above.

However I have left two other checks as they seems to me more suspicious - they
are always true or false. But as Dmitry and Andrew pointed out Linus have quite
strong opinion against removing range checks in such cases as he finds it
clearer. I think it applies to patches 29-36. I am not sure about patches 26-28,37.

Regards
Andrzej

> 
> David
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
