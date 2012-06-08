Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 7E9EC6B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 01:28:49 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2471856pbb.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 22:28:48 -0700 (PDT)
Date: Thu, 7 Jun 2012 22:28:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 12/12] mm: correctly synchronize rss-counters at
 exit/exec
In-Reply-To: <CA+55aFw7y5FBJm6pxiHHsoiPaVQG3A+4u6J9=4DGd8kVPjmzGQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1206072220200.1738@eggly.anvils>
References: <20120607212114.E4F5AA02F8@akpm.mtv.corp.google.com> <CA+55aFxOWR_h1vqRLAd_h5_woXjFBLyBHP--P8F7WsYrciXdmA@mail.gmail.com> <CA+55aFyQUBXhjVLJH6Fhz9xnpfXZ=9Mej5ujt6ss7VUqT1g9Jg@mail.gmail.com> <alpine.LSU.2.00.1206071759050.1291@eggly.anvils>
 <CA+55aFw7y5FBJm6pxiHHsoiPaVQG3A+4u6J9=4DGd8kVPjmzGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-2106132903-1339133305=:1738"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, khlebnikov@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, markus@trippelsdorf.de, oleg@redhat.com, stable@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-2106132903-1339133305=:1738
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 7 Jun 2012, Linus Torvalds wrote:
> No, this is apparently that same "almost there" patch from Oleg. I
> guarantee that it's wrong.
>=20
>                 Linus
>=20
> ---
>=20
> [ This part, to be exact: ]
>=20
> On Thu, Jun 7, 2012 at 6:16 PM, Hugh Dickins <hughd@google.com> wrote:
> > --- a/kernel/tsacct.c
> > +++ b/kernel/tsacct.c
> > @@ -91,6 +91,7 @@ void xacct_add_tsk(struct taskstats *stats, struct ta=
sk_struct *p)
> > =A0 =A0 =A0 =A0stats->virtmem =3D p->acct_vm_mem1 * PAGE_SIZE / MB;
> > =A0 =A0 =A0 =A0mm =3D get_task_mm(p);
> > =A0 =A0 =A0 =A0if (mm) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sync_mm_rss(mm);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* adjust to KB unit */
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stats->hiwater_rss =A0 =3D get_mm_hiwate=
r_rss(mm) * PAGE_SIZE / KB;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stats->hiwater_vm =A0 =A0=3D get_mm_hiwa=
ter_vm(mm) =A0* PAGE_SIZE / KB;
> > --

Yup.

It does look as if Oleg's intent (last chance to update xacct stats
from dying current task) would be well served by changing that to

=09=09if (p =3D=3D current)
=09=09=09sync_mm_rss(mm);

but I've made too many hurried decisions recently to sign off on that.

Hugh
--8323584-2106132903-1339133305=:1738--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
