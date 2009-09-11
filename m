Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C3BAC6B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 07:07:11 -0400 (EDT)
Received: by iwn1 with SMTP id 1so402119iwn.11
        for <linux-mm@kvack.org>; Fri, 11 Sep 2009 04:07:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0909072227140.15430@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
	 <Pine.LNX.4.64.0909072227140.15430@sister.anvils>
Date: Fri, 11 Sep 2009 20:07:13 +0900
Message-ID: <82e12e5f0909110407h178ab6e0hbd6ac9e204738ae7@mail.gmail.com>
Subject: Re: [PATCH 1/8] mm: munlock use follow_page
From: Hiroaki Wakabayashi <primulaelatior@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/9/8 Hugh Dickins <hugh.dickins@tiscali.co.uk>:
> Hiroaki Wakabayashi points out that when mlock() has been interrupted
> by SIGKILL, the subsequent munlock() takes unnecessarily long because
> its use of __get_user_pages() insists on faulting in all the pages
> which mlock() never reached.
>
> It's worse than slowness if mlock() is terminated by Out Of Memory kill:
> the munlock_vma_pages_all() in exit_mmap() insists on faulting in all the
> pages which mlock() could not find memory for; so innocent bystanders are
> killed too, and perhaps the system hangs.
>
> __get_user_pages() does a lot that's silly for munlock(): so remove the
> munlock option from __mlock_vma_pages_range(), and use a simple loop of
> follow_page()s in munlock_vma_pages_range() instead; ignoring absent
> pages, and not marking present pages as accessed or dirty.
>
> (Change munlock() to only go so far as mlock() reached? =A0That does not
> work out, given the convention that mlock() claims complete success even
> when it has to give up early - in part so that an underlying file can be
> extended later, and those pages locked which earlier would give SIGBUS.)
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Reviewed-by: Hiroaki Wakabayashi <primulaelatior@gmail.com>

It very simple and so cool! I have learned something.

--
Thanks,
Hiroaki Wakabayashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
