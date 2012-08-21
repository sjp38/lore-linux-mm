Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 4E42F6B0068
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 11:37:23 -0400 (EDT)
Message-ID: <1345563433.26596.2.camel@twins>
Subject: Re: [PATCH v8 3/5] virtio_balloon: introduce migration primitives
 to balloon pages
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 21 Aug 2012 17:37:13 +0200
In-Reply-To: <20120821144013.GA7784@redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
	 <c5f02c618c99b0da11240c1b504672de6f70a074.1345519422.git.aquini@redhat.com>
	 <20120821144013.GA7784@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, paulmck <paulmck@linux.vnet.ibm.com>

On Tue, 2012-08-21 at 17:40 +0300, Michael S. Tsirkin wrote:
> > +             spin_lock(&vb->pages_lock);
> > +             page =3D list_first_or_null_rcu(&vb->pages, struct page, =
lru);
>=20
> Why is list_first_or_null_rcu called outside
> RCU critical section here?

It looks like vb->pages_lock is the exclusive (or modification)
counterpart to the rcu-read-lock in this particular case, so it should
be fine.

Although for that same reason, it seems superfluous to use the RCU list
method since we're exclusive with list manipulations anyway.

> > +             if (!page) {
> > +                     spin_unlock(&vb->pages_lock);
> > +                     break;
> > +             }
> > +             /*
> > +              * It is safe now to drop page->mapping and delete this p=
age
> > +              * from balloon page list, since we are grabbing 'pages_l=
ock'
> > +              * which prevents 'virtballoon_isolatepage()' from acting=
.
> > +              */
> > +             clear_balloon_mapping(page);
> > +             list_del_rcu(&page->lru);
> > +             spin_unlock(&vb->pages_lock);=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
