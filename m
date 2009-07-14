Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C635B6B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 06:24:38 -0400 (EDT)
Date: Tue, 14 Jul 2009 13:57:11 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak hexdump proposal
Message-ID: <20090714105709.GB2929@localdomain.by>
References: <20090629201014.GA5414@localdomain.by>
 <1247566033.28240.46.camel@pc1117.cambridge.arm.com>
 <20090714103356.GA2929@localdomain.by>
 <1247567641.28240.51.camel@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="i9LlY+UWpKt15+FH"
Content-Disposition: inline
In-Reply-To: <1247567641.28240.51.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--i9LlY+UWpKt15+FH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On (07/14/09 11:34), Catalin Marinas wrote:
> On Tue, 2009-07-14 at 13:33 +0300, Sergey Senozhatsky wrote:
> > On (07/14/09 11:07), Catalin Marinas wrote:
> > Am I understand correct that no way for user to on/off hexdump?
> > /* no need for atomic_t kmemleak_hex_dump */
>=20
> Yes. Two lines aren't really too much so we can always have them
> displayed.
>
Agree.


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
+ * Printing of the objects hex dump to the seq file. The number on lines
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


--i9LlY+UWpKt15+FH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iJwEAQECAAYFAkpcZIUACgkQfKHnntdSXjQqDwP+OLAZ3uj0XluD6A5BUFoKSSS+
xNNMsNNKlS2cwxVlAdVGmBoUBUOmD2Sq+FksMDyZdRnG2TL5LcUokfcL//LbSo8h
hOIssNyv9URqV4PaMIR45E40DBk/rOrz9w6CNCVi8PxeGc5nZjponrwZJq2PCzUg
06KxkqiQ9W215baNQDg=
=PwYQ
-----END PGP SIGNATURE-----

--i9LlY+UWpKt15+FH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
