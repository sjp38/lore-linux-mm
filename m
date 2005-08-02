Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.12.10/8.12.10) with ESMTP id j72C1Tmp156848
	for <linux-mm@kvack.org>; Tue, 2 Aug 2005 12:01:29 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j72C1TeZ143828
	for <linux-mm@kvack.org>; Tue, 2 Aug 2005 14:01:29 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j72C1SpF028987
	for <linux-mm@kvack.org>; Tue, 2 Aug 2005 14:01:29 +0200
In-Reply-To: <Pine.LNX.4.58.0508011455520.3341@g5.osdl.org>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
Message-ID: <OF3BCB86B7.69087CF8-ON42257051.003DCC6C-42257051.00420E16@de.ibm.com>
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Tue, 2 Aug 2005 14:01:29 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

> > Any chance you can change the __follow_page test to account for
> > writeable clean ptes? Something like
> >
> >       if (write && !pte_dirty(pte) && !pte_write(pte))
> >               goto out;
> >
> > And then you would re-add the set_page_dirty logic further on.
>
> Hmm.. That should be possible. I wanted to do the simplest possible code
> sequence, but yeah, I guess there's nothing wrong with allowing the code
> to dirty the page.
>
> Somebody want to send me a proper patch? Also, I haven't actually heard
> from whoever actually noticed the problem in the first place (Robin?)
> whether the fix does fix it. It "obviously does", but testing is always
> good ;)

Why do we require the !pte_dirty(pte) check? I don't get it. If a writeable
clean pte is just fine then why do we check the dirty bit at all? Doesn't
pte_dirty() imply pte_write()?

With the additional !pte_write(pte) check (and if I haven't overlooked
something which is not unlikely) s390 should work fine even without the
software-dirty bit hack.

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
