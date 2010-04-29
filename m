Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 027D36B01F6
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 20:28:27 -0400 (EDT)
Received: by iwn40 with SMTP id 40so5925913iwn.1
        for <linux-mm@kvack.org>; Wed, 28 Apr 2010 17:28:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100428165734.6541bab3@annuminas.surriel.com>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	 <20100427231007.GA510@random.random>
	 <20100428091555.GB15815@csn.ul.ie>
	 <20100428153525.GR510@random.random>
	 <20100428155558.GI15815@csn.ul.ie>
	 <20100428162305.GX510@random.random>
	 <20100428134719.32e8011b@annuminas.surriel.com>
	 <20100428142510.09984e15@annuminas.surriel.com>
	 <20100428161711.5a815fa8@annuminas.surriel.com>
	 <20100428165734.6541bab3@annuminas.surriel.com>
Date: Thu, 29 Apr 2010 09:28:25 +0900
Message-ID: <y2s28c262361004281728we31e3b9fsd2427aacdc76a9e7@mail.gmail.com>
Subject: Re: [RFC PATCH -v3] take all anon_vma locks in anon_vma_lock
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 29, 2010 at 5:57 AM, Rik van Riel <riel@redhat.com> wrote:
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

This patch makes things simple. So I like this.
Actually, I wanted this all-at-once locks approach.
But I was worried about that how the patch affects AIM 7 workload
which is cause of anon_vma_chain about scalability by Rik.
But now Rik himself is sending the patch. So I assume the patch
couldn't decrease scalability of the workload heavily.

Let's wait result of test if Rik doesn't have a problem of AIM7.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
