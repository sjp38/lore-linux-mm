Date: Thu, 16 Oct 2008 09:43:19 +0200
From: Kurt Garloff <garloff@suse.de>
Subject: [garloff@suse.de: [PATCH 1/1] default mlock limit 32k->64k]
Message-ID: <20081016074319.GD5286@tpkurt2.garloff.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="S8hWgp6Wl+RBuNna"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <NPiggin@suse.de>
List-ID: <linux-mm.kvack.org>

--S8hWgp6Wl+RBuNna
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

this patch does increase the default mlock()able memory from 32k to 64k
on PAGE_SIZE=3D4k systems. However, on systems with page sizes larger than
8k, the patch actually decreases the default down to 64k (or one page
in case that's larger).

Please speak up if you foresee problems on those platforms.
It would be simple to do=20
#define MLOCK_LIMIT  ((PAGE_SIZE > 4096) ? 8*PAGE_SIZE : 64*1024)
in that case -- but doing min(64k,PAGE_SIZE) seems cleaner to me.

----- Forwarded message from Kurt Garloff <garloff@suse.de> -----

Date: Wed, 15 Oct 2008 11:27:36 +0200
=46rom: Kurt Garloff <garloff@suse.de>
To: linux-kernel@vger.kernel.org
Cc: Nick Piggin <NPiggin@suse.de>
Subject: [PATCH 1/1] default mlock limit 32k->64k
X-Operating-System: Linux 2.6.25.16-0.1-default x86_64
X-PGP-Info: on http://www.garloff.de/kurt/mykeys.pgp
X-PGP-Key: 1024D/1C98774E
Organization: SUSE Linux Products GmbH (a Novell company), Nuernberg, GF:
	Markus Rex, HRB 16746 (AG Nuernberg)
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org

Hi,

normal users can mlock memory up to the value defined in RLIMIT_MLOCK.
The number used to 0 for a long time and has been changed to 8 pages
(32k on 4k page systems) a number of years ago to accommodate the needs
of gpg, which is one of the few programs that a normal user runs and
which needs mlock (to prevent passphrase and key from leaking into
swap).=20

Nowadays, we have gpg2, and the need has increased to 64k.
Attached patch does change the default to 64k, independent of the
PAGE_SIZE. (Unless PAGE_SIZE is larger than 64k, then we allow one
page.)

Please apply.
--=20
Kurt Garloff, VP Business Development -- OPS, Novell Inc.

=46rom: Kurt Garloff <garloff@suse.de>
Subject: Increase default RLIMIT_MEMLOCK to 64k
References: bnc#329675
Patch-Mainline: no (should be submitted)

By default, non-privileged tasks can only mlock() a small amount of
memory to avoid a DoS attack by ordinary users. The Linux kernel
defaulted to 32k (on a 4k page size system) to accommodate the
needs of gpg.
However, newer gpg2 needs 64k in various circumstances and otherwise
fails miserably, see bnc#329675.

Change the default to 64k, and make it more agnostic to PAGE_SIZE.

Signed-off-by: Kurt Garloff <garloff@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6.27/include/linux/resource.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.27.orig/include/linux/resource.h
+++ linux-2.6.27/include/linux/resource.h
@@ -59,10 +59,10 @@ struct rlimit {
 #define _STK_LIM	(8*1024*1024)
=20
 /*
- * GPG wants 32kB of mlocked memory, to make sure pass phrases
+ * GPG2 wants 64kB of mlocked memory, to make sure pass phrases
  * and other sensitive information are never written to disk.
  */
-#define MLOCK_LIMIT	(8 * PAGE_SIZE)
+#define MLOCK_LIMIT	((PAGE_SIZE > 64*1024) ? PAGE_SIZE : 64*1024)
=20
 /*
  * Due to binary compatibility, the actual resource numbers




----- End forwarded message -----

--=20
Kurt Garloff, VP Business Development -- OPS, Novell Inc.

--S8hWgp6Wl+RBuNna
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)

iD8DBQFI9vCXxmLh6hyYd04RApTlAJ98br+ffFTABav4jRWvyq3IHXjXlQCeMZX/
38Cf2L53ORnNqcGwNuc44Uw=
=GVzC
-----END PGP SIGNATURE-----

--S8hWgp6Wl+RBuNna--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
