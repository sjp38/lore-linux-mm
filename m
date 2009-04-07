Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B0DE85F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 18:10:17 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1F21982C2BE
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 18:19:25 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9jerbwD8cHSL for <linux-mm@kvack.org>;
	Tue,  7 Apr 2009 18:19:25 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7192182C2EB
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 18:19:11 -0400 (EDT)
Date: Tue, 7 Apr 2009 18:04:39 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] [10/16] POISON: Use bitmask/action code for try_to_unmap
 behaviour
In-Reply-To: <20090407215953.GA17934@one.firstfloor.org>
Message-ID: <alpine.DEB.1.10.0904071802290.12192@qirst.com>
References: <20090407509.382219156@firstfloor.org> <20090407151007.71F3F1D046F@basil.firstfloor.org> <alpine.DEB.1.10.0904071714450.12192@qirst.com> <20090407215953.GA17934@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Lee.Schermerhorn@hp.com, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Apr 2009, Andi Kleen wrote:

> > Ignoring MLOCK? This means we are violating POSIX which says that an
> > MLOCKed page cannot be unmapped from a process?
>
> I'm sure if you can find sufficiently vague language in the document
> to standards lawyer around that requirement @)
>
> The alternative would be to panic.


If you unmmap a MLOCKed page then you may get memory corruption because
f.e. the Infiniband layer is doing DMA to that page.

> > How does that work for the poisoning case? We substitute a fresh page?
>
> It depends on the state of the page. If it was a clean disk mapped
> page yes (it's just invalidated and can be reloaded). If it's a dirty anon
> page the process is normally killed first (with advisory mode on) or only
> killed when it hits the corrupted page. The process can also
> catch the signal if it choses so. The late killing works with
> a special entry similar to the migration case, but that results
> in a special SIGBUS.

I think a process needs to be killed if any MLOCKed page gets corrupted
because the OS cannot keep the POSIX guarantees.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
