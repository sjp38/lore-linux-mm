Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 800026B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 16:02:34 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id f8so2831500wiw.13
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 13:02:33 -0800 (PST)
Received: from ns0.vlq16.iliad.fr (ns0.vlq16.iliad.fr. [213.36.7.21])
        by mx.google.com with ESMTPS id d8si12364722wjs.109.2014.02.17.13.02.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Feb 2014 13:02:33 -0800 (PST)
Message-ID: <1392670951.24429.10.camel@sakura.staff.proxad.net>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
From: Maxime Bizon <mbizon@freebox.fr>
Reply-To: mbizon@freebox.fr
Date: Mon, 17 Feb 2014 22:02:31 +0100
In-Reply-To: <20140216225000.GO30257@n2100.arm.linux.org.uk>
References: <20140216200503.GN30257@n2100.arm.linux.org.uk>
	 <alpine.DEB.2.02.1402161406120.26926@chino.kir.corp.google.com>
	 <20140216225000.GO30257@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org


On Sun, 2014-02-16 at 22:50 +0000, Russell King - ARM Linux wrote:

> http://www.home.arm.linux.org.uk/~rmk/misc/log-20140208.txt

[<c0064ce0>] (__alloc_pages_nodemask+0x0/0x694) from [<c022273c>] (sk_page_frag_refill+0x78/0x108)
[<c02226c4>] (sk_page_frag_refill+0x0/0x108) from [<c026a3a4>] (tcp_sendmsg+0x654/0xd1c)  r6:00000520 r5:c277bae0 r4:c68f37c0
[<c0269d50>] (tcp_sendmsg+0x0/0xd1c) from [<c028ca9c>] (inet_sendmsg+0x64/0x70)

FWIW I had OOMs with the exact same backtrace on kirkwood platform
(512MB RAM), but sorry I don't have the full dump anymore.

I found a slow leaking process, and since I fixed that leak I now have
uptime better than 7 days, *but* there was definitely some memory left
when the OOM happened, so it appears to be related to fragmentation.

>From what I recall, clearing the page cache helped making the box live a
little bit longer. Does it make sense or should alloc_pages() discard
its content when trying to satisfy high order allocations ?

-- 
Maxime


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
