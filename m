Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id D38E26B0092
	for <linux-mm@kvack.org>; Tue, 22 May 2012 13:51:21 -0400 (EDT)
Date: Tue, 22 May 2012 12:51:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Common code 07/12] slabs: Move kmem_cache_create mutex
 handling to common code
In-Reply-To: <CAAmzW4Nt0S-xmwmHhw0AJEikE91pZpnCS+NQosrxAaUDi59pew@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205221250270.21828@router.home>
References: <20120518161906.207356777@linux.com> <20120518161930.978054128@linux.com> <CAAmzW4Nt0S-xmwmHhw0AJEikE91pZpnCS+NQosrxAaUDi59pew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-917050571-1337709080=:21828"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-917050571-1337709080=:21828
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 23 May 2012, JoonSoo Kim wrote:

> 2012/5/19 Christoph Lameter <cl@linux.com>:
> > Move the mutex handling into the common kmem_cache_create()
> > function.
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_add(&s->list, &slab=
_caches);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&slab_mutex=
);
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sysfs_slab_add(s)) {
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_loc=
k(&slab_mutex);
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(=
&s->list);
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(n);
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(s);
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return s;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 r =3D sysfs_slab_add(s);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_lock(&slab_mutex);
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!r)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return s;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&s->list);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache_close(s);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(n);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(s);
> > =A0 =A0 =A0 =A0}
>
> Before this patch is applied, can we move calling 'sysfs_slab_add' to
> common code
> for removing slab_mutex entirely in kmem_cache_create?

Hmmm... its difficult to do that before this patch since sysfs_slab_add
requires dropping the mutex.

---1463811839-917050571-1337709080=:21828--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
