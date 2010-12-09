Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7F0F36B008A
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 16:37:44 -0500 (EST)
Received: by ewy27 with SMTP id 27so2521179ewy.14
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 13:37:42 -0800 (PST)
Date: Thu, 9 Dec 2010 23:39:11 +0200
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: NULL pointer dereference in __mark_inode_dirty
Message-ID: <20101209213911.GB4250@swordfish.minsk.epam.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XOIedfhf+7KOe/yw"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


--XOIedfhf+7KOe/yw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,
I had an oops today while copying files from external USB hdd,
because of NULL pointer dereference in __mark_inode_dirty.

Stack trace looks similar to this one:
__mark_inode_dirty
touch_atime
generic_file_aio_read
vfs_read


The problem is that, at the same time something similiar=20
to this happens
sb->s_bdi =3D NULL
bdi_prune_sb
bdi_unregister
del_gendisk
sd_remove

due to
[ 2595.650474] usb 2-1.2: new high speed USB device using ehci_hcd and addr=
ess 34
[ 2595.735409] usb 2-1.2: New USB device found, idVendor=3D1058, idProduct=
=3D0704
[ 2595.735419] usb 2-1.2: New USB device strings: Mfr=3D1, Product=3D2, Ser=
ialNumber=3D3
[ 2595.735427] usb 2-1.2: Product: External HDD   =20
[ 2595.735434] usb 2-1.2: Manufacturer: Western Digital=20
[ 2595.735440] usb 2-1.2: SerialNumber: 575845363038453236303437
[ 2595.738574] usb-storage 2-1.2:1.0: Quirks match for vid 1058 pid 0704: 8=
000
[ 2595.738678] scsi34 : usb-storage 2-1.2:1.0
[ 2596.735886] scsi 34:0:0:0: Direct-Access     WD       3200BMV External 1=
=2E05 PQ: 0 ANSI: 4
[ 2596.738702] sd 34:0:0:0: [sdb] 625142448 512-byte logical blocks: (320 G=
B/298 GiB)
[ 2596.739695] sd 34:0:0:0: [sdb] Write Protect is off
[ 2596.739700] sd 34:0:0:0: [sdb] Mode Sense: 21 00 00 00
[ 2596.739704] sd 34:0:0:0: [sdb] Assuming drive cache: write through
[ 2596.742589] sd 34:0:0:0: [sdb] Assuming drive cache: write through
[ 2596.788526]  sdb: sdb1
[ 2596.791876] sd 34:0:0:0: [sdb] Assuming drive cache: write through
[ 2596.791886] sd 34:0:0:0: [sdb] Attached SCSI disk
[ 2602.946272] FAT: utf8 is not a recommended IO charset for FAT filesystem=
s, filesystem will be case sensitive!
[ 2614.887119] usb 2-1.2: USB disconnect, address 34
[ 2614.890093] sd 34:0:0:0: [sdb] Unhandled error code
[ 2614.890101] sd 34:0:0:0: [sdb]  Result: hostbyte=3DDID_NO_CONNECT driver=
byte=3DDRIVER_OK
[ 2614.890112] sd 34:0:0:0: [sdb] CDB: Read(10): 28 00 02 49 27 eb 00 00 10=
 00
[ 2614.890144] end_request: I/O error, dev sdb, sector 38348779
[ 2614.890210] sd 34:0:0:0: [sdb] Unhandled error code
[ 2614.890216] sd 34:0:0:0: [sdb]  Result: hostbyte=3DDID_NO_CONNECT driver=
byte=3DDRIVER_OK
[ 2614.890225] sd 34:0:0:0: [sdb] CDB: Read(10): 28 00 02 49 27 fb 00 00 f0=
 00
[ 2614.890256] end_request: I/O error, dev sdb, sector 38348795
[ 2614.891577] FAT: FAT read failed (blocknr 5025)
[ 2614.891744] FAT: FAT read failed (blocknr 5037)
[ 2614.893203] FAT: FAT read failed (blocknr 66)
[ 2614.893451] FAT: FAT read failed (blocknr 28135)
[ 2614.894942] FAT: FAT read failed (blocknr 32)


Later in __mark_inode_dirty
bdi =3D inode_to_bdi(inode)

call returns NULL. And the result is Oops.

Below is the first `solution' that I came up with. Yet I don't
think it's proper.

---

 fs/fs-writeback.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 3d06ccc..0b0e79c 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -987,6 +987,9 @@ void __mark_inode_dirty(struct inode *inode, int flags)
 		if (!was_dirty) {
 			bdi =3D inode_to_bdi(inode);
=20
+			if (bdi =3D=3D NULL)
+				goto out;
+
 			if (bdi_cap_writeback_dirty(bdi)) {
 				WARN(!test_bit(BDI_registered, &bdi->state),
 				     "bdi-%s not registered\n", bdi->name);



--XOIedfhf+7KOe/yw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iJwEAQECAAYFAk0BTH8ACgkQfKHnntdSXjTvzQP/XDvY3XERtjZCaSIzjgXZi+tn
a3Db1ypC3yZpAJUBix+lcMWp2X6WcLlRGDcjhBwo9UNteUuDYVZBbyRnIgHXQ7xg
0GxE9Jgehrl1ZNfisCds2ldJ+IrLLR3rLEaNxpk9L/Lysa16+KUyJ3l2NKdJvwKG
GD+o00VcP63XiZRT+Ws=
=F3il
-----END PGP SIGNATURE-----

--XOIedfhf+7KOe/yw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
