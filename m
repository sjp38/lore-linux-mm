Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E88006B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 10:48:36 -0400 (EDT)
Date: Tue, 14 Jul 2009 18:22:40 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak: Printing of the objects hex dump
Message-ID: <20090714152240.GB3145@localdomain.by>
References: <20090629201014.GA5414@localdomain.by>
 <1247566033.28240.46.camel@pc1117.cambridge.arm.com>
 <20090714103356.GA2929@localdomain.by>
 <1247567641.28240.51.camel@pc1117.cambridge.arm.com>
 <20090714105709.GB2929@localdomain.by>
 <1247578781.28240.92.camel@pc1117.cambridge.arm.com>
 <20090714140349.GA3145@localdomain.by>
 <1247581062.28240.97.camel@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="V0207lvV8h4k8FAm"
Content-Disposition: inline
In-Reply-To: <1247581062.28240.97.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--V0207lvV8h4k8FAm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On (07/14/09 15:17), Catalin Marinas wrote:
> There is no hurry, sometime in the next few weeks :-)
>=20
> > Should I update Documentation/kmemeleak.txt either?
>=20
> I don't think this is needed as it doesn't say much about the format of
> the debug/kmemleak file (and that's pretty clear, no need to explain
> what a hex dump means).
>=20

Fixed typo "The number on lines".
---------------------------------------------------------------------------=
--

kmemleak: Printing of the objects hex dump

Introducing printing of the objects hex dump to the seq file.
The number of lines to be printed is limited to HEX_MAX_LINES
to prevent seq file spamming. The actual number of printed
bytes is less than or equal to (HEX_MAX_LINES * HEX_ROW_SIZE).

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
---
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 5aabd41..f7b74ac 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -161,6 +161,15 @@ struct kmemleak_object {
 /* flag set on newly allocated objects */
 #define OBJECT_NEW		(1 << 3)
=20
+/* number of bytes to print per line; must be 16 or 32 */
+#define HEX_ROW_SIZE		16
+/* number of bytes to print at a time (1, 2, 4, 8) */
+#define HEX_GROUP_SIZE		1
+/* include ASCII after the hex output */
+#define HEX_ASCII		1
+/* max number of lines to be printed */
+#define HEX_MAX_LINES		2
+
 /* the list of all allocated objects */
 static LIST_HEAD(object_list);
 /* the list of gray-colored objects (see color_gray comment below) */
@@ -254,6 +263,35 @@ static void kmemleak_disable(void);
 	kmemleak_disable();		\
 } while (0)
=20
+
+/*
+ * Printing of the objects hex dump to the seq file. The number of lines
+ * to be printed is limited to HEX_MAX_LINES to prevent seq file spamming.
+ * The actual number of printed bytes depends on HEX_ROW_SIZE.
+ * It must be called with the object->lock held.
+ */
+static void hex_dump_object(struct seq_file *seq,
+				struct kmemleak_object *object)
+{
+	const u8 *ptr =3D (const u8 *)object->pointer;
+	/* Limit the number of lines to HEX_MAX_LINES. */
+	int len =3D min(object->size, (size_t)(HEX_MAX_LINES * HEX_ROW_SIZE));
+	int i, remaining =3D len;
+	unsigned char linebuf[200];
+
+	seq_printf(seq, "  hex dump (first %d bytes):\n", len);
+
+	for (i =3D 0; i < len; i +=3D HEX_ROW_SIZE) {
+		int linelen =3D min(remaining, HEX_ROW_SIZE);
+		remaining -=3D HEX_ROW_SIZE;
+		hex_dump_to_buffer(ptr + i, linelen, HEX_ROW_SIZE,
+						   HEX_GROUP_SIZE, linebuf,
+						   sizeof(linebuf), HEX_ASCII);
+
+		seq_printf(seq, "    %s\n", linebuf);
+	}
+}
+
 /*
  * Object colors, encoded with count and min_count:
  * - white - orphan object, not enough references to it (count < min_count)
@@ -304,6 +342,9 @@ static void print_unreferenced(struct seq_file *seq,
 		   object->pointer, object->size);
 	seq_printf(seq, "  comm \"%s\", pid %d, jiffies %lu\n",
 		   object->comm, object->pid, object->jiffies);
+
+	hex_dump_object(seq, object);
+
 	seq_printf(seq, "  backtrace:\n");
=20
 	for (i =3D 0; i < object->trace_len; i++) {

--V0207lvV8h4k8FAm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iJwEAQECAAYFAkpcosAACgkQfKHnntdSXjRpsQQAn7X8UJm0z1bblGtxhY7OiUM6
CJRfzIqbAirJb2+XJOkesXGLUOCBq/S19ociS6bXd/PJVAIJiWMKmYYKUeNqotSV
BFoQA8PzItifBMXEo20oGmkPq2VcGMToE2y1XQVHEzKL28XJvSHni8TQsWUkjEWP
sqUOFHsDezMBAuVUDHU=
=X8CX
-----END PGP SIGNATURE-----

--V0207lvV8h4k8FAm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
