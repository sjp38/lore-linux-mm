Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2277A9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 10:00:51 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <ae99a884-f63b-4258-afea-ca1d6cf5a74c@default>
Date: Thu, 29 Sep 2011 07:00:22 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V10 0/6] mm: frontswap: overview (and proposal to merge at
 next window)
References: <20110915213305.GA26317@ca-server1.us.oracle.com>
 <20110928151558.dca1da5e.kamezawa.hiroyu@jp.fujitsu.com>
 <22173398-de03-43ef-abe4-a3f3231dd2e9@default
 20110929134816.7f29bf46.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110929134816.7f29bf46.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

> From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> Sent: Wednesday, September 28, 2011 10:48 PM
>=20
> On Wed, 28 Sep 2011 07:09:18 -0700 (PDT)
> Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
>=20
> > > From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> > > Sent: Wednesday, September 28, 2011 12:16 AM
> > >
> > > I'm sorry I couldn't catch following... what happens at hibernation ?
> > > frontswap is effectively stopped/skipped automatically ? or contents =
of
> > > TMEM can be kept after power off and it can be read correctly when
> > > resume thread reads swap ?
> > >
> > > In short: no influence to hibernation ?
> > > I'm sorry if I misunderstand some.
> >
> > Hibernation would need to be handled by the tmem backend (e.g. zcache, =
Xen
> > tmem).  In the case of Xen tmem, both save/restore and live migration a=
re
> > fully supported.  I'm not sure if zcache works across hibernation; sinc=
e
> > all memory is kmalloc'ed, I think it should work fine, but it would be =
an
> > interesting experiment.
>=20
> I'm afraid that users will lose data on memory of frontswap/zcache/tmem
> by power-off, hibernation. How about adding internal hooks to disable/syn=
c
> frontswap itself before hibernation ? difficult ?

Hi Kame --

First, remember that frontswap is currently only enabled by
specifying a tmem backend as a kernel boot parameter ("zcache"
or "tmem"), so there is no risk of data loss to the average
laptop user doing hibernation, even if CONFIG_FRONTSWAP
and CONFIG_ZCACHE are enabled in their kernel.

The patchset's frontswap_shrink() call can be used to remove
pages from frontswap so there is one internal hook for this
already.

I still think hibernation should work fine with zcache
because all frontswap metadata and data is preserved as part
of kernel memory.  For poweroff, the normal swapoff will
"get" all frontswap pages, so no issue there either.
I do agree that this should be investigated before zcache
could be moved from staging and certainly before zcache is
enabled by default by a distro (with no kernel boot parameter).
If it turns out that zcache needs more hooks to provide finer
control of frontswap disable/sync, I don't think it will be=20
difficult but I think those hooks should be designed in the future.

And Xen tmem supports save/restore and live migration
already so this is not a concern for the Xen tmem backend.

Hope that helps!

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
