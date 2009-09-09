Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B7E506B004F
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 11:59:57 -0400 (EDT)
Received: by ywh32 with SMTP id 32so3499432ywh.11
        for <linux-mm@kvack.org>; Wed, 09 Sep 2009 08:59:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0909072227140.15430@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
	 <Pine.LNX.4.64.0909072227140.15430@sister.anvils>
Date: Thu, 10 Sep 2009 00:59:56 +0900
Message-ID: <28c262360909090859l6e94c0eekc38bd2670d7fc79e@mail.gmail.com>
Subject: Re: [PATCH 1/8] mm: munlock use follow_page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hiroaki Wakabayashi <primulaelatior@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 8, 2009 at 6:29 AM, Hugh Dickins <hugh.dickins@tiscali.co.uk> w=
rote:
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
> Cc: stable@kernel.org
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
It looks better than old Hiroaki's one.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
