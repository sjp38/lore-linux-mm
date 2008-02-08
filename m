Subject: Re: [PATCH] mm/slub.c - Use print_hex_dump
From: Joe Perches <joe@perches.com>
In-Reply-To: <Pine.LNX.4.64.0802081031320.28862@schroedinger.engr.sgi.com>
References: <1202493808.27394.76.camel@localhost>
	 <Pine.LNX.4.64.0802081006460.28568@schroedinger.engr.sgi.com>
	 <1202495069.27394.85.camel@localhost>
	 <Pine.LNX.4.64.0802081031320.28862@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 08 Feb 2008 12:15:39 -0800
Message-Id: <1202501739.27394.96.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-02-08 at 10:32 -0800, Christoph Lameter wrote:
> On Fri, 8 Feb 2008, Joe Perches wrote:
> > On Fri, 2008-02-08 at 10:07 -0800, Christoph Lameter wrote:
> > > On Fri, 8 Feb 2008, Joe Perches wrote:
> > > > Use the library function to dump memory
> > > Could you please compare the formatting of the output before and 
> > > after? Last time we tried this we had issues because it became a bit ugly.
> > The difference is the last line of the ascii is not aligned
> > if the length is non modulo 16.
> > I have sent a patch to print_hex_dump to always align.
> > http://lkml.org/lkml/2007/12/6/304
> Could you group these together for review? I think we are okay with the 
> slub changes if the print_hex_dump is fixed.

hex_dump_to_buffer:
	Removes casts to type for non-1 group sizes
		Used by: fs/ext(3|4)super.c, fs/jfs
		If someone really dislikes this change, please say so.
		I think casting to type in a hex dump odd, especially
		for mixed type structures.
		If you want an array of type dumper, it probably
		shouldn't be called hex_dump_to_buffer.
	Groups by arbitrary size
print_hex_dump:
	Removes rowsize argument
	Reduces linebuf stack use to ~120 bytes
		prefix:25 + address:20 + data:48 + ascii:20)
	Aligns multiline ascii output
	Changes return to size_t, number of bytes actually output

include/linux/kernel.h
	Removes hex_asc define
	Updates hex_dump prototypes
mm/slub.c
	Use print_hex_dump

The rest are trivial conversions to new argument list.

size before:
   text    data     bss     dec     hex filename
   1142       0       0    1142     476 lib/hexdump.o

size after:
   text    data     bss     dec     hex filename
    823       0       0     823     337 lib/hexdump.o

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/ide.h                         |    2 +-
 include/linux/kernel.h                      |   13 +-
 lib/hexdump.c                               |  164 ++++++++++++---------------
 mm/slub.c                                   |   44 ++------
 drivers/mtd/ubi/debug.c                     |    4 +-
 drivers/mtd/ubi/io.c                        |    4 +-
 drivers/net/e1000/e1000_main.c              |    2 +-
 drivers/net/enc28j60.c                      |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    4 +-
 drivers/s390/cio/device_fsm.c               |   17 ++--
 drivers/scsi/ide-scsi.c                     |    2 +-
 drivers/usb/gadget/file_storage.c           |    8 +-
 fs/ext3/super.c                             |    6 +-
 fs/ext4/super.c                             |    6 +-
 fs/jffs2/wbuf.c                             |    8 +-
 fs/jfs/jfs_imap.c                           |    4 +-
 fs/jfs/jfs_logmgr.c                         |   15 ++-
 fs/jfs/jfs_metapage.c                       |    4 +-
 fs/jfs/jfs_txnmgr.c                         |   17 ++--
 fs/jfs/xattr.c                              |    4 +-
 fs/xfs/support/debug.c                      |    2 +-
 crypto/tcrypt.c                             |    3 +-
 23 files changed, 150 insertions(+), 191 deletions(-)

diff --git a/include/linux/ide.h b/include/linux/ide.h
index acec99d..bf2e621 100644
--- a/include/linux/ide.h
+++ b/include/linux/ide.h
@@ -1288,7 +1288,7 @@ extern struct bus_type ide_bus_type;
 
 static inline void ide_dump_identify(u8 *id)
 {
-	print_hex_dump(KERN_INFO, "", DUMP_PREFIX_NONE, 16, 2, id, 512, 0);
+	print_hex_dump(KERN_INFO, "", DUMP_PREFIX_NONE, 2, id, 512, false);
 }
 
 static inline int hwif_to_node(ide_hwif_t *hwif)
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 9e01f37..44ada01 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -252,15 +252,14 @@ enum {
 	DUMP_PREFIX_ADDRESS,
 	DUMP_PREFIX_OFFSET
 };
-extern void hex_dump_to_buffer(const void *buf, size_t len,
-				int rowsize, int groupsize,
-				char *linebuf, size_t linebuflen, bool ascii);
+extern size_t hex_dump_to_buffer(const void *buf, size_t len,
+				 size_t rowsize, size_t groupsize,
+				 char *linebuf, size_t linebuflen, bool ascii);
 extern void print_hex_dump(const char *level, const char *prefix_str,
-				int prefix_type, int rowsize, int groupsize,
-				const void *buf, size_t len, bool ascii);
+			   int prefix_type, size_t groupsize,
+			   const void *buf, size_t len, bool ascii);
 extern void print_hex_dump_bytes(const char *prefix_str, int prefix_type,
-			const void *buf, size_t len);
-#define hex_asc(x)	"0123456789abcdef"[x]
+				 const void *buf, size_t len);
 
 #define pr_emerg(fmt, arg...) \
 	printk(KERN_EMERG fmt, ##arg)
diff --git a/lib/hexdump.c b/lib/hexdump.c
index 3435465..dbe9335 100644
--- a/lib/hexdump.c
+++ b/lib/hexdump.c
@@ -12,18 +12,21 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 
+#define ROWSIZE ((size_t)16)
+#define MAX_PREFIX_LEN ((size_t)20)
+
 /**
  * hex_dump_to_buffer - convert a blob of data to "hex ASCII" in memory
  * @buf: data blob to dump
  * @len: number of bytes in the @buf
- * @rowsize: number of bytes to print per line; must be 16 or 32
+ * @rowsize: maximum number of bytes to output (aligns ascii)
  * @groupsize: number of bytes to print at a time (1, 2, 4, 8; default = 1)
  * @linebuf: where to put the converted data
  * @linebuflen: total size of @linebuf, including space for terminating NUL
  * @ascii: include ASCII after the hex output
  *
  * hex_dump_to_buffer() works on one "line" of output at a time, i.e.,
- * 16 or 32 bytes of input data converted to hex + ASCII output.
+ * input data converted to hex + ASCII output.
  *
  * Given a buffer of u8 data, hex_dump_to_buffer() converts the input data
  * to a hex + ASCII dump at the supplied memory location.
@@ -31,85 +34,54 @@
  *
  * E.g.:
  *   hex_dump_to_buffer(frame->data, frame->len, 16, 1,
- *			linebuf, sizeof(linebuf), 1);
+ *			linebuf, sizeof(linebuf), true);
  *
  * example output buffer:
  * 40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f  @ABCDEFGHIJKLMNO
  */
-void hex_dump_to_buffer(const void *buf, size_t len, int rowsize,
-			int groupsize, char *linebuf, size_t linebuflen,
-			bool ascii)
+size_t hex_dump_to_buffer(const void *buf, size_t len,
+			  size_t rowsize, size_t groupsize,
+			  char *linebuf, size_t linebuflen, bool ascii)
 {
 	const u8 *ptr = buf;
-	u8 ch;
-	int j, lx = 0;
-	int ascii_column;
-
-	if (rowsize != 16 && rowsize != 32)
-		rowsize = 16;
-
+	int i, lx = 0;
+	size_t ascii_column;
+	size_t ngroups;
 	if (!len)
 		goto nil;
-	if (len > rowsize)		/* limit to one line at a time */
-		len = rowsize;
-	if ((len % groupsize) != 0)	/* no mixed size output */
-		groupsize = 1;
-
-	switch (groupsize) {
-	case 8: {
-		const u64 *ptr8 = buf;
-		int ngroups = len / groupsize;
-
-		for (j = 0; j < ngroups; j++)
-			lx += scnprintf(linebuf + lx, linebuflen - lx,
-				"%16.16llx ", (unsigned long long)*(ptr8 + j));
-		ascii_column = 17 * ngroups + 2;
-		break;
-	}
-
-	case 4: {
-		const u32 *ptr4 = buf;
-		int ngroups = len / groupsize;
-
-		for (j = 0; j < ngroups; j++)
-			lx += scnprintf(linebuf + lx, linebuflen - lx,
-				"%8.8x ", *(ptr4 + j));
-		ascii_column = 9 * ngroups + 2;
-		break;
-	}
 
-	case 2: {
-		const u16 *ptr2 = buf;
-		int ngroups = len / groupsize;
+	if (groupsize == 0)
+		groupsize = 1;
+	else if (groupsize > rowsize)
+		groupsize = rowsize;
 
-		for (j = 0; j < ngroups; j++)
-			lx += scnprintf(linebuf + lx, linebuflen - lx,
-				"%4.4x ", *(ptr2 + j));
-		ascii_column = 5 * ngroups + 2;
-		break;
-	}
+	ngroups = rowsize / groupsize;
+	ascii_column = (2 * groupsize + 1) * ngroups + 2;
+	if (len > (ngroups * groupsize))
+		len = ngroups * groupsize;
 
-	default:
-		for (j = 0; (j < rowsize) && (j < len) && (lx + 4) < linebuflen;
-		     j++) {
-			ch = ptr[j];
-			linebuf[lx++] = hex_asc(ch >> 4);
-			linebuf[lx++] = hex_asc(ch & 0x0f);
+	for (i = 0; i < len; i++) {
+		if (i && (i % groupsize) == 0)
 			linebuf[lx++] = ' ';
-		}
-		ascii_column = 3 * rowsize + 2;
-		break;
+		lx += scnprintf(linebuf + lx, linebuflen - lx,
+				"%02x", ptr[i] & 0xff);
 	}
+
 	if (!ascii)
 		goto nil;
 
 	while (lx < (linebuflen - 1) && lx < (ascii_column - 1))
 		linebuf[lx++] = ' ';
-	for (j = 0; (j < rowsize) && (j < len) && (lx + 2) < linebuflen; j++)
-		linebuf[lx++] = (isascii(ptr[j]) && isprint(ptr[j])) ? ptr[j]
-				: '.';
+
+	for (i = 0; i < len && (lx + 2) < linebuflen; i++) {
+		if (i > 0 && groupsize > 1 && (i % groupsize) == 0)
+			linebuf[lx++] = ' ';
+		linebuf[lx++] = (isascii(ptr[i]) && isprint(ptr[i]))
+			? ptr[i] : '.';
+	}
 nil:
-	linebuf[lx++] = '\0';
+	linebuf[lx] = '\0';
+	return len;
 }
 EXPORT_SYMBOL(hex_dump_to_buffer);
 
@@ -120,7 +92,6 @@ EXPORT_SYMBOL(hex_dump_to_buffer);
  *  caller supplies trailing spaces for alignment if desired
  * @prefix_type: controls whether prefix of an offset, address, or none
  *  is printed (%DUMP_PREFIX_OFFSET, %DUMP_PREFIX_ADDRESS, %DUMP_PREFIX_NONE)
- * @rowsize: number of bytes to print per line; must be 16 or 32
  * @groupsize: number of bytes to print at a time (1, 2, 4, 8; default = 1)
  * @buf: data blob to dump
  * @len: number of bytes in the @buf
@@ -131,48 +102,60 @@ EXPORT_SYMBOL(hex_dump_to_buffer);
  * leading prefix.
  *
  * print_hex_dump() works on one "line" of output at a time, i.e.,
- * 16 or 32 bytes of input data converted to hex + ASCII output.
+ * 16 bytes of input data converted to hex + ASCII output.
  * print_hex_dump() iterates over the entire input @buf, breaking it into
- * "line size" chunks to format and print.
+ * groups of up to 16 byte chunks to format and print.
  *
  * E.g.:
- *   print_hex_dump(KERN_DEBUG, "raw data: ", DUMP_PREFIX_ADDRESS,
- *		16, 1, frame->data, frame->len, 1);
+ *   print_hex_dump(KERN_DEBUG, "raw data: ", DUMP_PREFIX_ADDRESS, 1,
+ *		    frame->data, frame->len, 1);
  *
  * Example output using %DUMP_PREFIX_OFFSET and 1-byte mode:
- * 0009ab42: 40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f  @ABCDEFGHIJKLMNO
- * Example output using %DUMP_PREFIX_ADDRESS and 4-byte mode:
- * ffffffff88089af0: 73727170 77767574 7b7a7978 7f7e7d7c  pqrstuvwxyz{|}~.
+ * 00000000: 40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f  @ABCDEFGHIJKLMNO
+ * Example output using %DUMP_PREFIX_ADDRESS and 4-byte mode on BE 64 bit:
+ * ffffffff88089af0: 70717273 74757677 78797a7b 7c7d7e7f  pqrs tuvw xyz{ |}~.
+ * Example output using %DUMP_PREFIX_ADDRESS and 5-byte mode on LE 32 bit:
+ * 88089af0: 7071727374 7576777879 7a7b7d7d7e  pqrst uvwxy z{|}~
  */
+
 void print_hex_dump(const char *level, const char *prefix_str, int prefix_type,
-			int rowsize, int groupsize,
-			const void *buf, size_t len, bool ascii)
+		    size_t groupsize, const void *buf, size_t len, bool ascii)
 {
 	const u8 *ptr = buf;
-	int i, linelen, remaining = len;
-	unsigned char linebuf[200];
-
-	if (rowsize != 16 && rowsize != 32)
-		rowsize = 16;
-
-	for (i = 0; i < len; i += rowsize) {
-		linelen = min(remaining, rowsize);
-		remaining -= rowsize;
-		hex_dump_to_buffer(ptr + i, linelen, rowsize, groupsize,
-				linebuf, sizeof(linebuf), ascii);
+	size_t i;
+	size_t linelen;
+	size_t prefix_len = strlen(prefix_str);
+	unsigned char linebuf[sizeof(KERN_INFO) +
+			      MAX_PREFIX_LEN +
+			      (2 * sizeof(void *) + 4) +
+			      (3 * ROWSIZE) +
+			      (3 * ROWSIZE / 2) + 1];
+	if (prefix_len > MAX_PREFIX_LEN)
+		prefix_len = MAX_PREFIX_LEN;
+
+	i = 0;
+	while (i < len) {
+		size_t bytes;
+		linelen = min(len - i, ROWSIZE);
+		bytes = hex_dump_to_buffer(ptr + i, linelen, ROWSIZE, groupsize,
+					   linebuf, sizeof(linebuf), ascii);
 
 		switch (prefix_type) {
 		case DUMP_PREFIX_ADDRESS:
-			printk("%s%s%*p: %s\n", level, prefix_str,
-				(int)(2 * sizeof(void *)), ptr + i, linebuf);
+			printk("%s%-.*s%*p: %s\n", level,
+			       prefix_len, prefix_str,
+			       (int)(2 * sizeof(void *)), ptr + i, linebuf);
 			break;
 		case DUMP_PREFIX_OFFSET:
-			printk("%s%s%.8x: %s\n", level, prefix_str, i, linebuf);
+			printk("%s%-.*s%.8x: %s\n", level,
+			       prefix_len, prefix_str, i, linebuf);
 			break;
 		default:
-			printk("%s%s%s\n", level, prefix_str, linebuf);
+			printk("%s%-.*s%s\n", level,
+			       prefix_len, prefix_str, linebuf);
 			break;
 		}
+		i += bytes;
 	}
 }
 EXPORT_SYMBOL(print_hex_dump);
@@ -187,12 +170,11 @@ EXPORT_SYMBOL(print_hex_dump);
  * @len: number of bytes in the @buf
  *
  * Calls print_hex_dump(), with log level of KERN_DEBUG,
- * rowsize of 16, groupsize of 1, and ASCII output included.
+ * groupsize of 1, and ASCII output included.
  */
 void print_hex_dump_bytes(const char *prefix_str, int prefix_type,
-			const void *buf, size_t len)
+			  const void *buf, size_t len)
 {
-	print_hex_dump(KERN_DEBUG, prefix_str, prefix_type, 16, 1,
-			buf, len, 1);
+	print_hex_dump(KERN_DEBUG, prefix_str, prefix_type, 1, buf, len, true);
 }
 EXPORT_SYMBOL(print_hex_dump_bytes);
diff --git a/mm/slub.c b/mm/slub.c
index e2989ae..a9324c6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -378,36 +378,10 @@ static char *slub_debug_slabs;
 /*
  * Object debugging
  */
-static void print_section(char *text, u8 *addr, unsigned int length)
+static void print_section(const char *text, const u8 *addr, size_t length)
 {
-	int i, offset;
-	int newline = 1;
-	char ascii[17];
-
-	ascii[16] = 0;
-
-	for (i = 0; i < length; i++) {
-		if (newline) {
-			printk(KERN_ERR "%8s 0x%p: ", text, addr + i);
-			newline = 0;
-		}
-		printk(KERN_CONT " %02x", addr[i]);
-		offset = i % 16;
-		ascii[offset] = isgraph(addr[i]) ? addr[i] : '.';
-		if (offset == 15) {
-			printk(KERN_CONT " %s\n", ascii);
-			newline = 1;
-		}
-	}
-	if (!newline) {
-		i %= 16;
-		while (i < 16) {
-			printk(KERN_CONT "   ");
-			ascii[i] = ' ';
-			i++;
-		}
-		printk(KERN_CONT " %s\n", ascii);
-	}
+	print_hex_dump(KERN_ERR, text, DUMP_PREFIX_ADDRESS, 1,
+		       addr, length, true);
 }
 
 static struct track *get_track(struct kmem_cache *s, void *object,
@@ -517,12 +491,12 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 			p, p - addr, get_freepointer(s, p));
 
 	if (p > addr + 16)
-		print_section("Bytes b4", p - 16, 16);
+		print_section("Bytes b4: ", p - 16, 16);
 
-	print_section("Object", p, min(s->objsize, 128));
+	print_section("Object:   ", p, min(s->objsize, 128));
 
 	if (s->flags & SLAB_RED_ZONE)
-		print_section("Redzone", p + s->objsize,
+		print_section("Redzone:  ", p + s->objsize,
 			s->inuse - s->objsize);
 
 	if (s->offset)
@@ -535,7 +509,7 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 
 	if (off != s->size)
 		/* Beginning of the filler is the free pointer */
-		print_section("Padding", p + off, s->size - off);
+		print_section("Padding: ", p + off, s->size - off);
 
 	dump_stack();
 }
@@ -699,7 +673,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 		end--;
 
 	slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fault, end - 1);
-	print_section("Padding", start, length);
+	print_section("Padding: ", start, length);
 
 	restore_bytes(s, "slab padding", POISON_INUSE, start, end);
 	return 0;
@@ -829,7 +803,7 @@ static void trace(struct kmem_cache *s, struct page *page, void *object, int all
 			page->freelist);
 
 		if (!alloc)
-			print_section("Object", (void *)object, s->objsize);
+			print_section("Object: ", (void *)object, s->objsize);
 
 		dump_stack();
 	}
diff --git a/drivers/mtd/ubi/debug.c b/drivers/mtd/ubi/debug.c
index 56956ec..2e6e987 100644
--- a/drivers/mtd/ubi/debug.c
+++ b/drivers/mtd/ubi/debug.c
@@ -42,8 +42,8 @@ void ubi_dbg_dump_ec_hdr(const struct ubi_ec_hdr *ec_hdr)
 	dbg_msg("data_offset    %d",    be32_to_cpu(ec_hdr->data_offset));
 	dbg_msg("hdr_crc        %#08x", be32_to_cpu(ec_hdr->hdr_crc));
 	dbg_msg("erase counter header hexdump:");
-	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 32, 1,
-		       ec_hdr, UBI_EC_HDR_SIZE, 1);
+	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 1,
+		       ec_hdr, UBI_EC_HDR_SIZE, true);
 }
 
 /**
diff --git a/drivers/mtd/ubi/io.c b/drivers/mtd/ubi/io.c
index db3efde..8cc5edb 100644
--- a/drivers/mtd/ubi/io.c
+++ b/drivers/mtd/ubi/io.c
@@ -1253,8 +1253,8 @@ static int paranoid_check_all_ff(struct ubi_device *ubi, int pnum, int offset,
 fail:
 	ubi_err("paranoid check failed for PEB %d", pnum);
 	dbg_msg("hex dump of the %d-%d region", offset, offset + len);
-	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 32, 1,
-		       ubi->dbg_peb_buf, len, 1);
+	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 1,
+		       ubi->dbg_peb_buf, len, true);
 	err = 1;
 error:
 	ubi_dbg_dump_stack();
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7c5b05a..fcdfa04 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -886,7 +886,7 @@ static void e1000_dump_eeprom(struct e1000_adapter *adapter)
 
 	printk(KERN_ERR "Offset    Values\n");
 	printk(KERN_ERR "========  ======\n");
-	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 16, 1, data, 128, 0);
+	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 1, data, 128, false);
 
 	printk(KERN_ERR "Include this output when contacting your support "
 	       "provider.\n");
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index 0809a6a..c71e446 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -835,8 +835,8 @@ static void enc28j60_dump_rsv(struct enc28j60_net *priv, const char *msg,
 static void dump_packet(const char *msg, int len, const char *data)
 {
 	printk(KERN_DEBUG DRV_NAME ": %s - packet len:%d\n", msg, len);
-	print_hex_dump(KERN_DEBUG, "pk data: ", DUMP_PREFIX_OFFSET, 16, 1,
-			data, len, true);
+	print_hex_dump(KERN_DEBUG, "pk data: ", DUMP_PREFIX_OFFSET, 1,
+		       data, len, true);
 }
 
 /*
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 5ee1ad6..53167ee 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -174,8 +174,8 @@ static void iwl3945_print_hex_dump(int level, void *p, u32 len)
 	if (!(iwl3945_debug_level & level))
 		return;
 
-	print_hex_dump(KERN_DEBUG, "iwl data: ", DUMP_PREFIX_OFFSET, 16, 1,
-			p, len, 1);
+	print_hex_dump(KERN_DEBUG, "iwl data: ", DUMP_PREFIX_OFFSET, 1,
+		       p, len, true);
 #endif
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index f423241..e83443b 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -173,8 +173,8 @@ static void iwl4965_print_hex_dump(int level, void *p, u32 len)
 	if (!(iwl4965_debug_level & level))
 		return;
 
-	print_hex_dump(KERN_DEBUG, "iwl data: ", DUMP_PREFIX_OFFSET, 16, 1,
-			p, len, 1);
+	print_hex_dump(KERN_DEBUG, "iwl data: ", DUMP_PREFIX_OFFSET, 1,
+		       p, len, true);
 #endif
 }
 
diff --git a/drivers/s390/cio/device_fsm.c b/drivers/s390/cio/device_fsm.c
index 4b92c84..22b48f0 100644
--- a/drivers/s390/cio/device_fsm.c
+++ b/drivers/s390/cio/device_fsm.c
@@ -108,8 +108,8 @@ static void ccw_timeout_log(struct ccw_device *cdev)
 	printk(KERN_WARNING "cio: ccw device timeout occurred at %llx, "
 	       "device information:\n", get_clock());
 	printk(KERN_WARNING "cio: orb:\n");
-	print_hex_dump(KERN_WARNING, "cio:  ", DUMP_PREFIX_NONE, 16, 1,
-		       &private->orb, sizeof(private->orb), 0);
+	print_hex_dump(KERN_WARNING, "cio:  ", DUMP_PREFIX_NONE, 1,
+		       &private->orb, sizeof(private->orb), false);
 	printk(KERN_WARNING "cio: ccw device bus id: %s\n", cdev->dev.bus_id);
 	printk(KERN_WARNING "cio: subchannel bus id: %s\n", sch->dev.bus_id);
 	printk(KERN_WARNING "cio: subchannel lpm: %02x, opm: %02x, "
@@ -121,18 +121,19 @@ static void ccw_timeout_log(struct ccw_device *cdev)
 	else
 		printk(KERN_WARNING "cio: last channel program:\n");
 
-	print_hex_dump(KERN_WARNING, "cio:  ", DUMP_PREFIX_NONE, 16, 1,
+	print_hex_dump(KERN_WARNING, "cio:  ", DUMP_PREFIX_NONE, 1,
 		       (void *)(addr_t)private->orb.cpa,
-		       sizeof(struct ccw1), 0);
+		       sizeof(struct ccw1), false);
 	printk(KERN_WARNING "cio: ccw device state: %d\n",
 	       cdev->private->state);
 	printk(KERN_WARNING "cio: store subchannel returned: cc=%d\n", cc);
 	printk(KERN_WARNING "cio: schib:\n");
-	print_hex_dump(KERN_WARNING, "cio:  ", DUMP_PREFIX_NONE, 16, 1,
-		       &schib, sizeof(schib), 0);
+	print_hex_dump(KERN_WARNING, "cio:  ", DUMP_PREFIX_NONE, 1,
+		       &schib, sizeof(schib), false);
 	printk(KERN_WARNING "cio: ccw device flags:\n");
-	print_hex_dump(KERN_WARNING, "cio:  ", DUMP_PREFIX_NONE, 16, 1,
-		       &cdev->private->flags, sizeof(cdev->private->flags), 0);
+	print_hex_dump(KERN_WARNING, "cio:  ", DUMP_PREFIX_NONE, 1,
+		       &cdev->private->flags, sizeof(cdev->private->flags),
+		       false);
 }
 
 /*
diff --git a/drivers/scsi/ide-scsi.c b/drivers/scsi/ide-scsi.c
index 68e5c63..7030bb6 100644
--- a/drivers/scsi/ide-scsi.c
+++ b/drivers/scsi/ide-scsi.c
@@ -243,7 +243,7 @@ static void idescsi_output_buffers (ide_drive_t *drive, idescsi_pc_t *pc, unsign
 
 static void ide_scsi_hex_dump(u8 *data, int len)
 {
-	print_hex_dump(KERN_CONT, "", DUMP_PREFIX_NONE, 16, 1, data, len, 0);
+	print_hex_dump(KERN_CONT, "", DUMP_PREFIX_NONE, 1, data, len, false);
 }
 
 static int idescsi_check_condition(ide_drive_t *drive, struct request *failed_command)
diff --git a/drivers/usb/gadget/file_storage.c b/drivers/usb/gadget/file_storage.c
index 3301167..7207359 100644
--- a/drivers/usb/gadget/file_storage.c
+++ b/drivers/usb/gadget/file_storage.c
@@ -718,8 +718,8 @@ static void dump_msg(struct fsg_dev *fsg, const char *label,
 {
 	if (length < 512) {
 		DBG(fsg, "%s, length %u:\n", label, length);
-		print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET,
-				16, 1, buf, length, 0);
+		print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 1,
+			       buf, length, false);
 	}
 }
 
@@ -736,8 +736,8 @@ static void dump_msg(struct fsg_dev *fsg, const char *label,
 
 static void dump_cdb(struct fsg_dev *fsg)
 {
-	print_hex_dump(KERN_DEBUG, "SCSI CDB: ", DUMP_PREFIX_NONE,
-			16, 1, fsg->cmnd, fsg->cmnd_size, 0);
+	print_hex_dump(KERN_DEBUG, "SCSI CDB: ", DUMP_PREFIX_NONE, 1,
+		       fsg->cmnd, fsg->cmnd_size, false);
 }
 
 #else
diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index cf2a2c3..50734af 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -464,9 +464,9 @@ static void ext3_destroy_inode(struct inode *inode)
 	if (!list_empty(&(EXT3_I(inode)->i_orphan))) {
 		printk("EXT3 Inode %p: orphan list check failed!\n",
 			EXT3_I(inode));
-		print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS, 16, 4,
-				EXT3_I(inode), sizeof(struct ext3_inode_info),
-				false);
+		print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS, 4,
+			       EXT3_I(inode), sizeof(struct ext3_inode_info),
+			       true);
 		dump_stack();
 	}
 	kmem_cache_free(ext3_inode_cachep, EXT3_I(inode));
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 93beb86..65d8b78 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -580,9 +580,9 @@ static void ext4_destroy_inode(struct inode *inode)
 	if (!list_empty(&(EXT4_I(inode)->i_orphan))) {
 		printk("EXT4 Inode %p: orphan list check failed!\n",
 			EXT4_I(inode));
-		print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS, 16, 4,
-				EXT4_I(inode), sizeof(struct ext4_inode_info),
-				true);
+		print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS, 4,
+			       EXT4_I(inode), sizeof(struct ext4_inode_info),
+			       true);
 		dump_stack();
 	}
 	kmem_cache_free(ext4_inode_cachep, EXT4_I(inode));
diff --git a/fs/jffs2/wbuf.c b/fs/jffs2/wbuf.c
index d1d4f27..8f0edf2 100644
--- a/fs/jffs2/wbuf.c
+++ b/fs/jffs2/wbuf.c
@@ -248,12 +248,12 @@ static int jffs2_verify_write(struct jffs2_sb_info *c, unsigned char *buf,
 
 	printk(KERN_WARNING "Write verify error (ECC %s) at %08x. Wrote:\n",
 	       eccstr, c->wbuf_ofs);
-	print_hex_dump(KERN_WARNING, "", DUMP_PREFIX_OFFSET, 16, 1,
-		       c->wbuf, c->wbuf_pagesize, 0);
+	print_hex_dump(KERN_WARNING, "", DUMP_PREFIX_OFFSET, 1,
+		       c->wbuf, c->wbuf_pagesize, false);
 
 	printk(KERN_WARNING "Read back:\n");
-	print_hex_dump(KERN_WARNING, "", DUMP_PREFIX_OFFSET, 16, 1,
-		       c->wbuf_verify, c->wbuf_pagesize, 0);
+	print_hex_dump(KERN_WARNING, "", DUMP_PREFIX_OFFSET, 1,
+		       c->wbuf_verify, c->wbuf_pagesize, false);
 
 	return -EIO;
 }
diff --git a/fs/jfs/jfs_imap.c b/fs/jfs/jfs_imap.c
index 9bf29f7..5946ef8 100644
--- a/fs/jfs/jfs_imap.c
+++ b/fs/jfs/jfs_imap.c
@@ -890,8 +890,8 @@ int diFree(struct inode *ip)
 	 * the map.
 	 */
 	if (iagno >= imap->im_nextiag) {
-		print_hex_dump(KERN_ERR, "imap: ", DUMP_PREFIX_ADDRESS, 16, 4,
-			       imap, 32, 0);
+		print_hex_dump(KERN_ERR, "imap: ", DUMP_PREFIX_ADDRESS, 4,
+			       imap, 32, false);
 		jfs_error(ip->i_sb,
 			  "diFree: inum = %d, iagno = %d, nextiag = %d",
 			  (uint) inum, iagno, imap->im_nextiag);
diff --git a/fs/jfs/jfs_logmgr.c b/fs/jfs/jfs_logmgr.c
index 325a967..4df3b0e 100644
--- a/fs/jfs/jfs_logmgr.c
+++ b/fs/jfs/jfs_logmgr.c
@@ -1625,16 +1625,19 @@ void jfs_flush_journal(struct jfs_log *log, int wait)
 			if (lp->xflag & COMMIT_PAGE) {
 				struct metapage *mp = (struct metapage *)lp;
 				print_hex_dump(KERN_ERR, "metapage: ",
-					       DUMP_PREFIX_ADDRESS, 16, 4,
-					       mp, sizeof(struct metapage), 0);
+					       DUMP_PREFIX_ADDRESS, 4,
+					       mp, sizeof(struct metapage),
+					       false);
 				print_hex_dump(KERN_ERR, "page: ",
-					       DUMP_PREFIX_ADDRESS, 16,
+					       DUMP_PREFIX_ADDRESS,
 					       sizeof(long), mp->page,
-					       sizeof(struct page), 0);
+					       sizeof(struct page),
+					       false);
 			} else
 				print_hex_dump(KERN_ERR, "tblock:",
-					       DUMP_PREFIX_ADDRESS, 16, 4,
-					       lp, sizeof(struct tblock), 0);
+					       DUMP_PREFIX_ADDRESS, 4,
+					       lp, sizeof(struct tblock),
+					       false);
 		}
 	}
 #else
diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
index d1e64f2..28f0b0c 100644
--- a/fs/jfs/jfs_metapage.c
+++ b/fs/jfs/jfs_metapage.c
@@ -466,8 +466,8 @@ add_failed:
 	printk(KERN_ERR "JFS: bio_add_page failed unexpectedly\n");
 	goto skip;
 dump_bio:
-	print_hex_dump(KERN_ERR, "JFS: dump of bio: ", DUMP_PREFIX_ADDRESS, 16,
-		       4, bio, sizeof(*bio), 0);
+	print_hex_dump(KERN_ERR, "JFS: dump of bio: ", DUMP_PREFIX_ADDRESS, 4,
+		       bio, sizeof(*bio), false);
 skip:
 	bio_put(bio);
 	unlock_page(page);
diff --git a/fs/jfs/jfs_txnmgr.c b/fs/jfs/jfs_txnmgr.c
index e7c60ae..3835efd 100644
--- a/fs/jfs/jfs_txnmgr.c
+++ b/fs/jfs/jfs_txnmgr.c
@@ -830,15 +830,16 @@ struct tlock *txLock(tid_t tid, struct inode *ip, struct metapage * mp,
 	/* assert(jfs_ip->fileset == AGGREGATE_I); */
 	if (jfs_ip->fileset != AGGREGATE_I) {
 		printk(KERN_ERR "txLock: trying to lock locked page!");
-		print_hex_dump(KERN_ERR, "ip: ", DUMP_PREFIX_ADDRESS, 16, 4,
-			       ip, sizeof(*ip), 0);
-		print_hex_dump(KERN_ERR, "mp: ", DUMP_PREFIX_ADDRESS, 16, 4,
-			       mp, sizeof(*mp), 0);
+		print_hex_dump(KERN_ERR, "ip: ", DUMP_PREFIX_ADDRESS, 4,
+			       ip, sizeof(*ip), false);
+		print_hex_dump(KERN_ERR, "mp: ", DUMP_PREFIX_ADDRESS, 4,
+			       mp, sizeof(*mp), false);
 		print_hex_dump(KERN_ERR, "Locker's tblock: ",
-			       DUMP_PREFIX_ADDRESS, 16, 4, tid_to_tblock(tid),
-			       sizeof(struct tblock), 0);
-		print_hex_dump(KERN_ERR, "Tlock: ", DUMP_PREFIX_ADDRESS, 16, 4,
-			       tlck, sizeof(*tlck), 0);
+			       DUMP_PREFIX_ADDRESS, 4,
+			       tid_to_tblock(tid), sizeof(struct tblock),
+			       false);
+		print_hex_dump(KERN_ERR, "Tlock: ", DUMP_PREFIX_ADDRESS, 4,
+			       tlck, sizeof(*tlck), false);
 		BUG();
 	}
 	INCREMENT(stattx.waitlock);	/* statistics */
diff --git a/fs/jfs/xattr.c b/fs/jfs/xattr.c
index 9b7f2cd..e45a061 100644
--- a/fs/jfs/xattr.c
+++ b/fs/jfs/xattr.c
@@ -590,8 +590,8 @@ static int ea_get(struct inode *inode, struct ea_buffer *ea_buf, int min_size)
       size_check:
 	if (EALIST_SIZE(ea_buf->xattr) != ea_size) {
 		printk(KERN_ERR "ea_get: invalid extended attribute\n");
-		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1,
-				     ea_buf->xattr, ea_size, 1);
+		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 1,
+			       ea_buf->xattr, ea_size, true);
 		ea_release(inode, ea_buf);
 		rc = -EIO;
 		goto clean_up;
diff --git a/fs/xfs/support/debug.c b/fs/xfs/support/debug.c
index c27abef..f74e059 100644
--- a/fs/xfs/support/debug.c
+++ b/fs/xfs/support/debug.c
@@ -84,5 +84,5 @@ assfail(char *expr, char *file, int line)
 void
 xfs_hex_dump(void *p, int length)
 {
-	print_hex_dump(KERN_ALERT, "", DUMP_PREFIX_OFFSET, 16, 1, p, length, 1);
+	print_hex_dump(KERN_ALERT, "", DUMP_PREFIX_OFFSET, 1, p, length, true);
 }
diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 1ab8c01..7724636 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -90,8 +90,7 @@ static char *check[] = {
 static void hexdump(unsigned char *buf, unsigned int len)
 {
 	print_hex_dump(KERN_CONT, "", DUMP_PREFIX_OFFSET,
-			16, 1,
-			buf, len, false);
+		       1, buf, len, false);
 }
 
 static void tcrypt_complete(struct crypto_async_request *req, int err)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
