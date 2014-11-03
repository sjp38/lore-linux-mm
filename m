Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id BC7E66B00FC
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 11:45:37 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id pv20so7880649lab.25
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 08:45:36 -0800 (PST)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id pg10si33117502lbb.127.2014.11.03.08.45.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 08:45:36 -0800 (PST)
Received: by mail-lb0-f169.google.com with SMTP id p9so4015550lbv.28
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 08:45:36 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: DMA allocations from CMA and fatal_signal_pending check
In-Reply-To: <5453F80C.4090006@gmail.com>
References: <544FE9BE.6040503@gmail.com> <20141031082818.GB14642@js1304-P5Q-DELUXE> <5453F80C.4090006@gmail.com>
Date: Mon, 03 Nov 2014 17:45:31 +0100
Message-ID: <xa1tlhnsw7v8.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-arm-kernel@lists.infradead.org, Brian Norris <computersforpeace@gmail.com>, Gregory Fong <gregory.0xf0@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lauraa@codeaurora.org, gioh.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, m.szyprowski@samsung.com, akpm@linux-foundation.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

On Fri, Oct 31 2014, Florian Fainelli wrote:
> I agree that the CMA allocation should not be allowed to succeed, but
> the dma_alloc_coherent() allocation should succeed. If we look at the
> sysport driver, there are kmalloc() calls to initialize private
> structures, those will succeed (except under high memory pressure), so
> by the same token, a driver expects DMA allocations to succeed (unless
> we are under high memory pressure)
>
> What are we trying to solve exactly with the fatal_signal_pending()
> check here? Are we just optimizing for the case where a process has
> allocated from a CMA region to allow this region to be returned to the
> pool of free pages when it gets killed? Could there be another mechanism
> used to reclaim those pages if we know the process is getting killed
> anyway?

We're guarding against situations where process may hang around
arbitrarily long time after receiving SIGKILL.  If user does =E2=80=9Ckill =
-9
$pid=E2=80=9D the usual expectation is that the $pid process will die within
seconds and anything longer is perceived by user as a bug.

What problem are *you* trying to solve?  If user sent SIGKILL to
a process that imitated device initialisation, what is the point of
continuing initialising the device?  Just recover and return -EINTR.

> Well, not really. This driver is not an isolated case, there are tons of
> other networking drivers that do exactly the same thing, and we do
> expect these dma_alloc_* calls to succeed.

Again, why do you expect them to succeed?  The code must handle failures
correctly anyway so why do you wish to ignore fatal signal?

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
