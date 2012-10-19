Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id E9E5F6B005A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 12:39:17 -0400 (EDT)
Message-ID: <1350664742.2768.40.camel@twins>
Subject: Re: question on NUMA page migration
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 19 Oct 2012 18:39:02 +0200
In-Reply-To: <5081777A.8050104@redhat.com>
References: <5081777A.8050104@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 2012-10-19 at 11:53 -0400, Rik van Riel wrote:
>=20
> If we do need the extra refcount, why is normal
> page migration safe? :)=20

Its mostly a matter of how convoluted you make the code, regular page
migration is about as bad as you can get

Normal does:

  follow_page(FOLL_GET) +1

  isolate_lru_page() +1

  put_page() -1

ending up with a page with a single reference (for anon, or one extra
each for the mapping and buffer).

And while I suppose I could do a put_page() in migrate_misplaced_page()
that makes the function frob the page-count depending on the return
value.

I always try and avoid conditional locks/refs, therefore the code ends
up doing:

  page =3D vm_normal_page()
  if (page) {
    get_page()

    migrate_misplaced_page()

    put_page()
  }


where migrate_misplaced_page() does isolate_lru_page()/putback_lru_page,
and this leaves the page-count invariant.

We got a ref, therefore we must put a ref, is easier than we got a ref
and must put except when...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
