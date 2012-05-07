Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 2EC3B6B004D
	for <linux-mm@kvack.org>; Mon,  7 May 2012 16:24:09 -0400 (EDT)
Date: Mon, 7 May 2012 15:24:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab/mempolicy: always use local policy from interrupt
 context v2
In-Reply-To: <CAOJsxLE36GNJBmdrJqFfoyEve8swVsaBSq_oVgkgXSMEC3oBfA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205071522450.6029@router.home>
References: <1334499755-4399-1-git-send-email-andi@firstfloor.org> <CAOJsxLE36GNJBmdrJqFfoyEve8swVsaBSq_oVgkgXSMEC3oBfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-638261144-1336422247=:6029"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-638261144-1336422247=:6029
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 3 May 2012, Pekka Enberg wrote:

> (Adding some CC's.)

Uggg... Strange whitespace coming from Pekka again.

> On Sun, Apr 15, 2012 at 5:22 PM, Andi Kleen <andi@firstfloor.org> wrote:
> > From: Andi Kleen <ak@linux.intel.com>
> >
> > slab_node() could access current->mempolicy from interrupt context.
> > However there's a race condition during exit where the mempolicy
> > is first freed and then the pointer zeroed.
> >
> > Using this from interrupts seems bogus anyways. The interrupt
> > will interrupt a random process and therefore get a random
> > mempolicy. Many times, this will be idle's, which noone can change.
> >
> > Just disable this here and always use local for slab
> > from interrupts. I also cleaned up the callers of slab_node a bit
> > which always passed the same argument.

Good idea.

> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index cfb6c86..da79bbf 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -1586,8 +1586,9 @@ static unsigned interleave_nodes(struct mempolicy=
 *policy)
> > =A0* task can change it's policy. =A0The system default policy requires=
 no
> > =A0* such protection.
> > =A0*/
> > -unsigned slab_node(struct mempolicy *policy)
> > +unsigned slab_node(void)
> > =A0{
> > + =A0 =A0 =A0 struct mempolicy *policy =3D !in_interrupt() ? current->p=
olicy : NULL;
> > =A0 =A0 =A0 =A0if (!policy || policy->flags & MPOL_F_LOCAL)

Simplify this to if (in_interrupt() || !policy || .... ?

---1463811839-638261144-1336422247=:6029--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
