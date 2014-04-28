Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD776B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 04:09:26 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kq14so4883874pab.32
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 01:09:26 -0700 (PDT)
Received: from relay1.mentorg.com (relay1.mentorg.com. [192.94.38.131])
        by mx.google.com with ESMTPS id wh4si9921975pbc.133.2014.04.28.01.09.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 01:09:25 -0700 (PDT)
From: Thomas Schwinge <thomas@codesourcery.com>
Subject: Re: radeon: screen garbled after page allocator change, was: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
In-Reply-To: <20140427195527.GC9315@gmail.com>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org> <1375457846-21521-4-git-send-email-hannes@cmpxchg.org> <87r45fajun.fsf@schwinge.name> <20140424133722.GD4107@cmpxchg.org> <20140427033110.GA15091@gmail.com> <20140427195527.GC9315@gmail.com>
Date: Mon, 28 Apr 2014 10:09:17 +0200
Message-ID: <87ppk1q3iq.fsf@schwinge.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-="; micalg=pgp-sha1;
	protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alex Deucher <alexander.deucher@amd.com>, Christian =?utf-8?Q?K=C3=B6nig?= <christian.koenig@amd.com>, dri-devel@lists.freedesktop.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi!

On Sun, 27 Apr 2014 15:55:29 -0400, Jerome Glisse <j.glisse@gmail.com> wrot=
e:
> If my ugly patch works does this quirk also work ?

Unfortunately they both don't; see my other email,
<http://news.gmane.org/find-root.php?message_id=3D%3C87sioxq3rx.fsf%40schwi=
nge.name%3E>.


Also, the quirk patch resulted in a NULL pointer dereference in
pci_find_ht_capability+0x4/0x30, which I hacked around as follows:

diff --git drivers/pci/quirks.c drivers/pci/quirks.c
index f025867..33aaad2 100644
=2D-- drivers/pci/quirks.c
+++ drivers/pci/quirks.c
@@ -2452,6 +2452,8 @@ u64 pci_ht_quirk_dma_32bit_only(struct pci_dev *dev, =
u64 mask)
 		struct pci_dev *bridge =3D bus->self;
 		int pos;
=20
+		if (!bridge)
+			goto skip;
 		pos =3D pci_find_ht_capability(bridge, HT_CAPTYPE_SLAVE);
 		if (pos) {
 			int ctrl_off;
@@ -2472,6 +2474,7 @@ u64 pci_ht_quirk_dma_32bit_only(struct pci_dev *dev, =
u64 mask)
 				return 0xffffffff;
 			}
 		}
+	skip:
 		bus =3D bus->parent;
 	} while (bus);
 	return mask;

If needed, I can try to capture more data, but someone who has knowledge
of PCI bus architecture and Linux kernel code (so, not me), might
probably already see what's wrong.


Gr=C3=BC=C3=9Fe,
 Thomas

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAEBAgAGBQJTXgytAAoJENuKOtuXzphJQmIH/jS8Ld0BhAf522qyfvmjTdvH
3KGi0+4NX9ca+Lq6azfZMVUbeHHx+oR9BK4/pjsqEt6sMi3C2svpNwfi5sj/Vt3r
PWeGCptMhnuGvxashuQlh/lcu9oWfIh5HxCUGrjFM8ZtQYj0qkoN/+og38E0fQ72
46AzBNHp/f9h8WWZcCLChXLI9nK41yLwS0DQXSzGVm/M1BADaeBrpRDwtlv6xlYj
LflZcVDPoM7lUU3HjPBeWa91C4QcnJUna2G0FAPJGOtmbG2iUETVWRilonZFOWCq
GT0zVFSCCSI27bUsOeoLj8G93qE1fC62dolqw7i6MUWXfYYJ1fhE1NTDNp+mGx0=
=Wd6Z
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
