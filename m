Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9639F8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 13:30:32 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1HIUSYh005976
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 10:30:28 -0800
Received: by iyi20 with SMTP id 20so2689719iyi.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 10:30:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110217162124.457572646@chello.nl>
References: <20110217161948.045410404@chello.nl> <20110217162124.457572646@chello.nl>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Feb 2011 10:30:07 -0800
Message-ID: <AANLkTimj1d6QpzuNZ6NJvLDVvvC++mPodggFaBziU8Bj@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: Simplify anon_vma refcounts
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Thu, Feb 17, 2011 at 8:19 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wr=
ote:
>
> +void __put_anon_vma(struct anon_vma *anon_vma)
> +{
> + =A0 =A0 =A0 if (anon_vma->root !=3D anon_vma)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_anon_vma(anon_vma->root);
> + =A0 =A0 =A0 anon_vma_free(anon_vma);
> =A0}

So this makes me nervous. It looks like recursion.

Now, I don't think we can ever get a chain of these things (because
the root should be the root of everything), but I still preferred the
older code that made that "one-level root" case explicit, and didn't
have recursion.

IOW, even though it should be entirely equivalent, I think I'd really
prefer something like

  void __put_anon_vma(struct anon_vma *anon_vma)
  {
    struct anon_vma *root =3D anon_vma->root;

    if (root !=3D anon_vma && atomic_dec_and_test(&root->refcount))
      anon_vma_free(root);
    anon_vma_free(anon_vma);
  }

instead. Exactly because it makes it very clear that the "root" is a
root, and we're not doing some possibly arbitrarily deep list like the
dentry tree (which avoids recursion by open-coding its freeing as a
loop).

Hmm? (The above is obviously untested, maybe it has some stupid bug)

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
