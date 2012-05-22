Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 54A006B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 13:42:05 -0400 (EDT)
Date: Tue, 22 May 2012 12:42:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Common code 01/12] [slob] define page struct fields used
 in mm_types.h
In-Reply-To: <CAAmzW4O2zk5K3StnGXcQmvDqfSDQbmezoVLYsH-3s4mE9WaEBA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205221240530.21828@router.home>
References: <20120518161906.207356777@linux.com> <20120518161927.549888128@linux.com> <CAAmzW4O2zk5K3StnGXcQmvDqfSDQbmezoVLYsH-3s4mE9WaEBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1793627563-1337708523=:21828"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1793627563-1337708523=:21828
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 22 May 2012, JoonSoo Kim wrote:

> 2012/5/19 Christoph Lameter <cl@linux.com>:
>
> > -/*
> > =A0* free_slob_page: call before a slob_page is returned to the page al=
locator.
> > =A0*/
> > -static inline void free_slob_page(struct slob_page *sp)
> > +static inline void free_slob_page(struct page *sp)
> > =A0{
> > - =A0 =A0 =A0 reset_page_mapcount(&sp->page);
> > - =A0 =A0 =A0 sp->page.mapping =3D NULL;
> > + =A0 =A0 =A0 reset_page_mapcount(sp);
> > + =A0 =A0 =A0 sp->mapping =3D NULL;
> > =A0}
>
> Currently, sp->mapping =3D NULL is useless, because Slob doesn't touch
> this field anymore.

Ok. Adding another patch that does this.

> It is redundant, just using virt_to_page(addr) directly is more preferabl=
e

Ok adding another patch that avoids the accessors.

> > +static inline void clear_slob_page_free(struct page *sp)
> > =A0{
> > =A0 =A0 =A0 =A0list_del(&sp->list);
> > - =A0 =A0 =A0 __ClearPageSlobFree((struct page *)sp);
> > + =A0 =A0 =A0 __ClearPageSlobFree(sp);
> > =A0}
>
> I think we shouldn't use __ClearPageSlobFree anymore.
> Before this patch, list_del affect page->private,
> so when we manipulate slob list,
> using PageSlobFree overloaded with PagePrivate is reasonable.
> But, after this patch is applied, list_del doesn't touch page->private,
> so manipulate PageSlobFree is not reasonable.
> We would use another method for checking slob_page_free without
> PageSlobFree flag.

What method should we be using?

> When we define field in mm_types.h for slauob,
> sorted order between these is good for readability.
> For example, in case of lru, list for slob is first,
> but in case of _mapcount, field for slub is first.
> Consistent ordering is more preferable I think.

Ok. Reordered for next patchset (probably Friday).

---1463811839-1793627563-1337708523=:21828--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
