Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3416B0254
	for <linux-mm@kvack.org>; Sat, 31 Oct 2015 19:39:16 -0400 (EDT)
Received: by wijp11 with SMTP id p11so31292837wij.0
        for <linux-mm@kvack.org>; Sat, 31 Oct 2015 16:39:16 -0700 (PDT)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id j15si18223487wjn.71.2015.10.31.16.39.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 31 Oct 2015 16:39:15 -0700 (PDT)
Message-ID: <1446334747.2595.19.camel@decadent.org.uk>
Subject: [PATCH selftests 5/6] selftests: vm: Try harder to allocate huge
 pages
From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 31 Oct 2015 23:39:07 +0000
In-Reply-To: <1446334510.2595.13.camel@decadent.org.uk>
References: <1446334510.2595.13.camel@decadent.org.uk>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QFC3UrDrbq8T6yGt/Hc5"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuah Khan <shuahkh@osg.samsung.com>
Cc: linux-api@vger.kernel.org, linux-mm@kvack.org


--=-QFC3UrDrbq8T6yGt/Hc5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

If we need to increase the number of huge pages, drop caches first
to reduce fragmentation and then check that we actually allocated
as many as we wanted.=C2=A0=C2=A0Retry once if that doesn't work.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
The test always fails for me in a 1 GB VM without this.

Ben.

=C2=A0tools/testing/selftests/vm/run_vmtests | 15 ++++++++++++++-
=C2=A01 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftes=
ts/vm/run_vmtests
index 9179ce8..97ed1b2 100755
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -20,13 +20,26 @@ done < /proc/meminfo
=C2=A0if [ -n "$freepgs" ] && [ -n "$pgsize" ]; then
=C2=A0	nr_hugepgs=3D`cat /proc/sys/vm/nr_hugepages`
=C2=A0	needpgs=3D`expr $needmem / $pgsize`
-	if [ $freepgs -lt $needpgs ]; then
+	tries=3D2
+	while [ $tries -gt 0 ] && [ $freepgs -lt $needpgs ]; do
=C2=A0		lackpgs=3D$(( $needpgs - $freepgs ))
+		echo 3 > /proc/sys/vm/drop_caches
=C2=A0		echo $(( $lackpgs + $nr_hugepgs )) > /proc/sys/vm/nr_hugepages
=C2=A0		if [ $? -ne 0 ]; then
=C2=A0			echo "Please run this test as root"
=C2=A0			exit 1
=C2=A0		fi
+		while read name size unit; do
+			if [ "$name" =3D "HugePages_Free:" ]; then
+				freepgs=3D$size
+			fi
+		done < /proc/meminfo
+		tries=3D$((tries - 1))
+	done
+	if [ $freepgs -lt $needpgs ]; then
+		printf "Not enough huge pages available (%d < %d)\n" \
+		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0$freepgs $needpgs
+		exit 1
=C2=A0	fi
=C2=A0else
=C2=A0	echo "no hugetlbfs support in kernel?"

--=20
Ben Hutchings
All extremists should be taken out and shot.
--=-QFC3UrDrbq8T6yGt/Hc5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVjVRG+e/yOyVhhEJAQrF4xAAiYIr51i4rTr+4Bby9dSyu9VGidiGXz2F
kGLJRDYbFNhCAshrhP3FYISAgVTUxfd5B/SrLd0B3V5VGwOoopLzRdNxMMOF/lRT
L5yEeGHCvwIa857dFN9G5mhW/QCymfo+1bEO0uCC3WIgMWVHZePVpTfNmtT9ePQj
XmCOBKsOML/OTGm3hIhl4riC2xkk30K3obljx7dk8BRldAWNcm1PVPJTINT0EZ7I
J4qy6Zx8zxmuCke7KG6tY+8EGoN44DA+761phyYDJX+JEBVIVCp0Crqv5Bi+BGNX
5UUcQg21ADEoI2SKB8oA2xdaHB2Q4LfRgppHZckO0BKXCnpEbGI7Jkjo7zTyvV+y
fagp1BA4KI7KveLgVrw+6iAoVrUxKqRsri6F/edSMFmC28LWqwK7RPSbKJlt3wt7
RXPbWiLsrdqwV/coZ6gB5hMF5l0cXHOb24sBCiqPqtMyvo4kstAm7Hq0VDDvdZRm
hzne6J8v6Mp8nrnbYhXABRpt6umOWOtk616PSc1+bYudqVcoJTnDmMyHnCJn9hCB
FREAYxbC87e2bKHmQRq1wwg0wuwLcavBRqcH6C0/VhH2YdBy7whTbqvFjNgCW8xM
PpvpheQUOMgAkSWxs+3GNJ4QEDj+2gtKfY9vQxwG8hD/JSuN00L7FczdnXwWOvEJ
wqGgCwmq9Ug=
=cQ5x
-----END PGP SIGNATURE-----

--=-QFC3UrDrbq8T6yGt/Hc5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
