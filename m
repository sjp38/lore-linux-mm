Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 38EB76B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 05:32:25 -0400 (EDT)
From: Frank Mehnert <frank.mehnert@oracle.com>
Subject: Re: Handling NUMA page migration
Date: Wed, 5 Jun 2013 11:32:15 +0200
References: <201306040922.10235.frank.mehnert@oracle.com> <201306051034.19959.frank.mehnert@oracle.com> <20130605091048.GI15997@dhcp22.suse.cz>
In-Reply-To: <20130605091048.GI15997@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2971917.CRqVaWIEsp";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201306051132.15788.frank.mehnert@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

--nextPart2971917.CRqVaWIEsp
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Wednesday 05 June 2013 11:10:48 Michal Hocko wrote:
> On Wed 05-06-13 10:34:13, Frank Mehnert wrote:
> > On Wednesday 05 June 2013 09:54:54 Michal Hocko wrote:
> > > On Tue 04-06-13 23:54:45, Frank Mehnert wrote:
> > > > On Tuesday 04 June 2013 20:17:02 Frank Mehnert wrote:
> > > > > On Tuesday 04 June 2013 16:02:30 Michal Hocko wrote:
> > > > > > On Tue 04-06-13 14:14:45, Frank Mehnert wrote:
> > > > > > > On Tuesday 04 June 2013 13:58:07 Robin Holt wrote:
> > > > > > > > This is probably more appropriate to be directed at the
> > > > > > > > linux-mm mailing list.
> > > > > > > >=20
> > > > > > > > On Tue, Jun 04, 2013 at 09:22:10AM +0200, Frank Mehnert wro=
te:
> > > > > > > > > Hi,
> > > > > > > > >=20
> > > > > > > > > our memory management on Linux hosts conflicts with NUMA
> > > > > > > > > page migration. I assume this problem existed for a longer
> > > > > > > > > time but Linux 3.8 introduced automatic NUMA page
> > > > > > > > > balancing which makes the problem visible on multi-node
> > > > > > > > > hosts leading to kernel oopses.
> > > > > > > > >=20
> > > > > > > > > NUMA page migration means that the physical address of a
> > > > > > > > > page changes. This is fatal if the application assumes
> > > > > > > > > that this never happens for that page as it was supposed
> > > > > > > > > to be pinned.
> > > > > > > > >=20
> > > > > > > > > We have two kind of pinned memory:
> > > > > > > > >=20
> > > > > > > > > A) 1. allocate memory in userland with mmap()
> > > > > > > > >=20
> > > > > > > > >    2. madvise(MADV_DONTFORK)
> > > > > > > > >    3. pin with get_user_pages().
> > > > > > > > >    4. flush dcache_page()
> > > > > > > > >    5. vm_flags |=3D (VM_DONTCOPY | VM_LOCKED)
> > > > > > > > >   =20
> > > > > > > > >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP |
> > > > > > > > >       VM_DONTEXPAND
> > > > > > > > >      =20
> > > > > > > > >        VM_DONTCOPY | VM_LOCKED | 0xff)
> > > > > > > >=20
> > > > > > > > I don't think this type of allocation should be affected.=20
> > > > > > > > The get_user_pages() call should elevate the pages reference
> > > > > > > > count which should prevent migration from completing.  I
> > > > > > > > would, however, wait for a more definitive answer.
> > > > > > >=20
> > > > > > > Thanks Robin! Actually case B) is more important for us so I'm
> > > > > > > waiting for more feedback :)
> > > > > >=20
> > > > > > The manual node migration code seems to be OK in case B as well
> > > > > > because Reserved are skipped (check check_pte_range called from
> > > > > > down the do_migrate_pages path).
> > > > > >=20
> > > > > > Maybe auto-numa code is missing this check assuming that it
> > > > > > cannot encounter reserved pages.
> > > > > >=20
> > > > > > migrate_misplaced_page relies on numamigrate_isolate_page which
> > > > > > relies on isolate_lru_page and that one expects a LRU page. Is
> > > > > > your Reserved page on the LRU list? That would be a bit
> > > > > > unexpected.
> > > > >=20
> > > > > I will check this.
> > > >=20
> > > > I tested this now. When the Oops happens,
> > >=20
> > > You didn't mention Oops before. Are you sure you are just not missing
> > > any follow up fix?
> >=20
> > Sorry, but remember, this is on a host running VirtualBox which is
> > executing code in ring 0.
>=20
> Then the problem might be almost anywhere... I am afraid I cannot help
> you much with that. Good luck.

Thank you very much for your help. As I said, this problem happens _only_
with NUMA_BALANCING enabled. I understand that you treat the VirtualBox
code as untrusted but the reason for the problem is that some assumption
is obviously not met: The VirtualBox code assumes that the memory it
allocates using case A and case B is

 1. always present and
 2. will always be backed by the same phyiscal memory

over the entire life time. Enabling NUMA_BALANCING seems to make this
assumption false. I only want to know why.

I posted the snipped of the Oops above to show that some present bits are
not set (in that case in PMD ant PTE), the question is why.

> > > > PageLRU() of the corresponding page struct is NOT set! I've patched
> > > > the kernel to find that out.
> > >=20
> > > At which state? When you setup your page or when the Oops happens?
> > > Are you sure that your out-of-tree code plays well with the migration
> > > code?
> >=20
> > I've added code to show_fault_oops(). This code determines the page
> > struct for the address where the ring 0 page fault happened. It then
> > prints the value of PageLRU(page) from that page struct as part of the
> > Oops. This was to check if the page is part of the LRU list or not. I
> > hope I did this right.
>=20
> I am not sure this will tell you much. Your code would have to trip over
> a page affected by the migration. And nothing indicates this so far.

I see, you don't believe me. I will add more code to the kernel logging
which pages were migrated.

Thanks,

=46rank
=2D-=20
Dr.-Ing. Frank Mehnert | Software Development Director, VirtualBox
ORACLE Deutschland B.V. & Co. KG | Werkstr. 24 | 71384 Weinstadt, Germany

Hauptverwaltung: Riesstr. 25, D-80992 M=FCnchen
Registergericht: Amtsgericht M=FCnchen, HRA 95603
Gesch=E4ftsf=FChrer: J=FCrgen Kunz

Komplement=E4rin: ORACLE Deutschland Verwaltung B.V.
Hertogswetering 163/167, 3543 AS Utrecht, Niederlande
Handelsregister der Handelskammer Midden-Niederlande, Nr. 30143697
Gesch=E4ftsf=FChrer: Alexander van der Ven, Astrid Kepper, Val Maher

--nextPart2971917.CRqVaWIEsp
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iEYEABECAAYFAlGvBZ8ACgkQ6z8pigLf3EfIiwCeL4lxBsbWX/s59LOmeWBUA1rX
4R4An0WwsuhZxErQb8GZ0REbGP3ZKI92
=DM6v
-----END PGP SIGNATURE-----

--nextPart2971917.CRqVaWIEsp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
