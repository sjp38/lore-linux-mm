Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 967705F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:37:08 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3386E82CA35
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 11:51:49 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id W2t8rkUDkNnM for <linux-mm@kvack.org>;
	Tue,  2 Jun 2009 11:51:44 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8A3AC82CA92
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 11:51:44 -0400 (EDT)
Date: Tue, 2 Jun 2009 11:37:01 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Change ZERO_SIZE_PTR to point at unmapped space
In-Reply-To: <20090531022158.GA9033@oblivion.subreption.com>
Message-ID: <alpine.DEB.1.10.0906021130410.23962@gentwo.org>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>
 <20090531022158.GA9033@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 30 May 2009, Larry H. wrote:

> Let me provide you with a realistic scenario:
>
> 	1. foo.c network protocol implementation takes a sockopt which
> 	sets some ACME_OPTLEN value taken from userland.
>
> 	2. the length is not validated properly: it can be zero or an
> 	integer overflow / signedness issue allows it to wrap to zero.
>
> 	3. kmalloc(0) ensues, and data is copied to the pointer
> 	returned. if this is the default ZERO_SIZE_PTR*, a malicious user
> 	can mmap a page at NULL, and read data leaked from kernel memory
> 	everytime that setsockopt is issued.
> 	(*: kmalloc of zero returns ZERO_SIZE_PTR)

Cannot happen. The page at 0L is not mapped. This will cause a fault.

You are assuming the system has already been breached. Then of course all
bets are off.

> The performance impact, if any, is completely negligible. The security
> benefits of this utterly simple change well surpass the downsides.

Dont see any security benefit. If there is a way to breach security
of the kernel via mmap then please tell us and then lets fix
the problem and not engage in dealing with secondary issues.

Semantics of mmap(NULL, ...) is that the kernel selects a valid address
for you. How are you mapping something at 0L?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
