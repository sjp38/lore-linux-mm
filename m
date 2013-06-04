Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id B196F6B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 17:54:54 -0400 (EDT)
From: Frank Mehnert <frank.mehnert@oracle.com>
Subject: Re: Handling NUMA page migration
Date: Tue, 4 Jun 2013 23:54:45 +0200
References: <201306040922.10235.frank.mehnert@oracle.com> <20130604140230.GB31247@dhcp22.suse.cz> <201306042017.08828.frank.mehnert@oracle.com>
In-Reply-To: <201306042017.08828.frank.mehnert@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5400784.Waqc3BKeRJ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201306042354.45984.frank.mehnert@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

--nextPart5400784.Waqc3BKeRJ
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Tuesday 04 June 2013 20:17:02 Frank Mehnert wrote:
> On Tuesday 04 June 2013 16:02:30 Michal Hocko wrote:
> > On Tue 04-06-13 14:14:45, Frank Mehnert wrote:
> > > On Tuesday 04 June 2013 13:58:07 Robin Holt wrote:
> > > > This is probably more appropriate to be directed at the linux-mm
> > > > mailing list.
> > > >=20
> > > > On Tue, Jun 04, 2013 at 09:22:10AM +0200, Frank Mehnert wrote:
> > > > > Hi,
> > > > >=20
> > > > > our memory management on Linux hosts conflicts with NUMA page
> > > > > migration. I assume this problem existed for a longer time but
> > > > > Linux 3.8 introduced automatic NUMA page balancing which makes the
> > > > > problem visible on multi-node hosts leading to kernel oopses.
> > > > >=20
> > > > > NUMA page migration means that the physical address of a page
> > > > > changes. This is fatal if the application assumes that this never
> > > > > happens for that page as it was supposed to be pinned.
> > > > >=20
> > > > > We have two kind of pinned memory:
> > > > >=20
> > > > > A) 1. allocate memory in userland with mmap()
> > > > >=20
> > > > >    2. madvise(MADV_DONTFORK)
> > > > >    3. pin with get_user_pages().
> > > > >    4. flush dcache_page()
> > > > >    5. vm_flags |=3D (VM_DONTCOPY | VM_LOCKED)
> > > > >   =20
> > > > >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP |
> > > > >       VM_DONTEXPAND
> > > > >      =20
> > > > >        VM_DONTCOPY | VM_LOCKED | 0xff)
> > > >=20
> > > > I don't think this type of allocation should be affected.  The
> > > > get_user_pages() call should elevate the pages reference count which
> > > > should prevent migration from completing.  I would, however, wait f=
or
> > > > a more definitive answer.
> > >=20
> > > Thanks Robin! Actually case B) is more important for us so I'm waiting
> > > for more feedback :)
> >=20
> > The manual node migration code seems to be OK in case B as well because
> > Reserved are skipped (check check_pte_range called from down the
> > do_migrate_pages path).
> >=20
> > Maybe auto-numa code is missing this check assuming that it cannot
> > encounter reserved pages.
> >=20
> > migrate_misplaced_page relies on numamigrate_isolate_page which relies
> > on isolate_lru_page and that one expects a LRU page. Is your Reserved
> > page on the LRU list? That would be a bit unexpected.
>=20
> I will check this.

I tested this now. When the Oops happens, PageLRU() of the corresponding
page struct is NOT set! I've patched the kernel to find that out. This is
case B from my original mail (alloc_pages(), SetPageReserved(), vm_mmap(),
vm_insert_page(), vm_flags |=3D (VM_DONTEXPAND | VM_DONTDUMP)) and PageLRU()
was clear after vm_insert_page().

Example of such an oops (the present bits of PMD and PTE are clear):

BUG: unable to handle kernel paging request at 00007ff493c7eff8=20
IP: [<ffffffffa039e17f>] 0xffffffffa039e17e
PGD 201b068067 PUD 381c082067 PMD 20063d2166 PTE 8000002005da9166
Oops: 0000 [#1] SMP=20
Modules linked in: pci_stub vboxpci(OF) vboxnetadp(OF) vboxnetflt(OF)=20
vboxdrv(OF) md4 nls_utf8 cifs fscache vesafb kvm_amd kvm psmouse serio_raw=
=20
microcode ib_mthca ib_mad ib_core amd64_edac_mod edac_core k10temp=20
edac_mce_amd joydev shpchp mac_hid lp parport i2c_nforce2 hid_generic usbhi=
d=20
hid mptsas mptscsih mptbase scsi_transport_sas e1000 pata_acpi pata_amd=20
CPU 24=20
Pid: 2058, comm: EMT Tainted: GF          O 3.8.0-23-generic #34 Sun=20
Microsystems     Sun Fire X4600 M2/Sun Fire X4600 M2
RIP: 0010:[<ffffffffa039e17f>]  [<ffffffffa039e17f>] 0xffffffffa039e17e
RSP: 0018:ffff88381bac1968  EFLAGS: 00010202
RAX: 00007ff493c7eff8 RBX: ffff88381bac1998 RCX: 0000000000000000
RDX: 0000000000000ff8 RSI: 0000000000000000 RDI: ffff88381bac1a18
RBP: ffff88381bac1988 R08: ffffc90029981000 R09: ffffc9002999c000
R10: ffff88381bac1998 R11: ffffffffa037aee0 R12: ffffc9002999c000
R13: ffffffffa002f98d R14: ffffffffa002f98d R15: ffffc9002999c000
=46S:  00007ff4f59b7700(0000) GS:ffff883827c00000(0000) knlGS:0000000000000=
000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007ff493c7eff8 CR3: 000000201b06f000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process EMT (pid: 2058, threadinfo ffff88381bac0000, task ffff88381b840000)=
=20
Stack:
 0000000000000000 ffff88381bac1a60 ffff88381bac1ab8 ffffffffa002f98d
 ffff88381bac1a28 ffffffffa039e5bd ffffffffa002f98d 0000000000000000
 0000000000000000 0000000000000000 00007ff493c7e000 00007ff493c7eff8

Any more ideas? I'm happy to perform more tests.

Thanks,

=46rank

> In the meantime I verified that my testcase does not fail if I pass
> 'numa_balancing=3Dfalse' to the kernel, so it's definitely a NUMA balanci=
ng
> problem.
>=20
> I also did 'get_page()' on all pages of method B but the testcase so this
> didn't help.
>=20
> Frank

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

--nextPart5400784.Waqc3BKeRJ
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iEYEABECAAYFAlGuYiUACgkQ6z8pigLf3EehZQCggdbaPoHAy1Q9ZLtqEvLR7A8A
wC4Anif6qRo2nk9Nd64cYNxhPEIQaViU
=w3de
-----END PGP SIGNATURE-----

--nextPart5400784.Waqc3BKeRJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
