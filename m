Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.12.10/8.12.10) with ESMTP id j7287Txt124776
	for <linux-mm@kvack.org>; Tue, 2 Aug 2005 08:07:29 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7287TeZ188242
	for <linux-mm@kvack.org>; Tue, 2 Aug 2005 10:07:29 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j7287Thm027279
	for <linux-mm@kvack.org>; Tue, 2 Aug 2005 10:07:29 +0200
In-Reply-To: <Pine.LNX.4.58.0508011238330.3341@g5.osdl.org>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
Message-ID: <OFAD9E831B.5D9FB95C-ON42257051.002BC8C3-42257051.002CA1EB@de.ibm.com>
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Tue, 2 Aug 2005 10:07:30 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@osdl.org> wrote on 08/01/2005 09:48:40 PM:

> > Attractive, I very much wanted to do that rather than change all the
> > arches, but I think s390 rules it out: its pte_mkdirty does nothing,
> > its pte_dirty just says no.
>
> How does s390 work at all?

The big difference between s390 and your standard architecture is that
s390 keeps the dirty and reference bits in the storage key. That is
per physical page and not per mapping. The primitive pte_dirty() just
doesn't make any sense for s390. A pte never contains any information
about dirty/reference state of a page. The "page" itself contains it,
you access the information with some instructions (sske, iske & rrbe)
which get the page frame address as parameter.

> > Or should we change s390 to set a flag in the pte just for this purpose?
>
> If the choice is between a broken and ugly implementation for everybody
> else, then hell yes. Even if it's a purely sw bit that nothing else
> actually cares about.. I hope they have an extra bit around somewhere.

Urg, depending on the pte type there are no bits available. For valid ptes
there are some bits we could use but it wouldn't be nice.

blue skies,
   Martin

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
