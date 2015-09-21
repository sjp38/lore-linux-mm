Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7826B0256
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:42:36 -0400 (EDT)
Received: by oibi136 with SMTP id i136so58177212oib.3
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:42:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k4si12142299oic.89.2015.09.21.06.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 06:42:36 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Subject: Re: [PATCH 00/38] Fixes related to incorrect usage of unsigned types
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <17570.1442842945.1@warthog.procyon.org.uk>
Date: Mon, 21 Sep 2015 14:42:25 +0100
Message-ID: <17571.1442842945@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cachefs@redhat.com, linux-clk@vger.kernel.org, linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-input@vger.kernel.org, linux-leds@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-omap@vger.kernel.org, linux-rdma@vger.kernel.org, linux-serial@vger.kernel.org, linux-sh@vger.kernel.org, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, lustre-devel@lists.lustre.org

Andrzej Hajda <a.hajda@samsung.com> wrote:

> Semantic patch finds comparisons of types:
>     unsigned < 0
>     unsigned >= 0
> The former is always false, the latter is always true.
> Such comparisons are useless, so theoretically they could be
> safely removed, but their presence quite often indicates bugs.

Or someone has left them in because they don't matter and there's the
possibility that the type being tested might be or become signed under some
circumstances.  If the comparison is useless, I'd expect the compiler to just
discard it - for such cases your patch is pointless.

If I have, for example:

	unsigned x;

	if (x == 0 || x > 27)
		give_a_range_error();

I will write this as:

	unsigned x;

	if (x <= 0 || x > 27)
		give_a_range_error();

because it that gives a way to handle x being changed to signed at some point
in the future for no cost.  In which case, your changing the <= to an ==
"because the < part of the case is useless" is arguably wrong.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
