Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A42256006AB
	for <linux-mm@kvack.org>; Sun,  2 May 2010 13:28:57 -0400 (EDT)
Received: by iwn31 with SMTP id 31so1800977iwn.27
        for <linux-mm@kvack.org>; Sun, 02 May 2010 10:28:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1272529930-29505-2-git-send-email-mel@csn.ul.ie>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
	 <1272529930-29505-2-git-send-email-mel@csn.ul.ie>
Date: Mon, 3 May 2010 02:28:56 +0900
Message-ID: <k2z28c262361005021028w31775ebah7c27411bb411b9f8@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Take all anon_vma locks in anon_vma_lock
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 29, 2010 at 5:32 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> From: Rik van Riel <riel@redhat.com>
>
> Take all the locks for all the anon_vmas in anon_vma_lock, this properly
> excludes migration and the transparent hugepage code from VMA changes don=
e
> by mmap/munmap/mprotect/expand_stack/etc...
>
> Unfortunately, this requires adding a new lock (mm->anon_vma_chain_lock),
> otherwise we have an unavoidable lock ordering conflict. =C2=A0This chang=
es the
> locking rules for the "same_vma" list to be either mm->mmap_sem for write=
,
> or mm->mmap_sem for read plus the new mm->anon_vma_chain lock. =C2=A0This=
 limits
> the place where the new lock is taken to 2 locations - anon_vma_prepare a=
nd
> expand_downwards.
>
> Document the locking rules for the same_vma list in the anon_vma_chain an=
d
> remove the anon_vma_lock call from expand_upwards, which does not need it=
.
>
> Signed-off-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I like this one.

Although it try to lock the number of anon_vmas attached to a VMA ,
it's small so latency couldn't be big. :)
It's height problem not width problem of tree. :)

Thanks, Rik.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
