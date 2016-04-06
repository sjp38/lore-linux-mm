Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id E3E5A6B026E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 08:11:26 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id n1so32368109pfn.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 05:11:26 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id r82si4308518pfb.75.2016.04.06.05.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 05:11:26 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id bx7so15708249pad.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 05:11:25 -0700 (PDT)
Date: Wed, 6 Apr 2016 22:09:11 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [BUG] lib: zram lz4 compression/decompression still broken on
 big endian
Message-ID: <20160406130911.GA584@swordfish>
References: <CALjTZvavWqtLoGQiWb+HxHP4rwRwaZiP0QrPRb+9kYGdicXohg@mail.gmail.com>
 <20160405153439.GA2647@kroah.com>
 <CALjTZvat4FhSc1AvNzjNwfa5tYydiTQLTnxz6cU7-Qd+h5mi6A@mail.gmail.com>
 <20160406053325.GA415@swordfish>
 <CALjTZvZaD7VHieU4A_5JAGZfN-7toWGm1UpM3zqreP6YsvA37A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALjTZvZaD7VHieU4A_5JAGZfN-7toWGm1UpM3zqreP6YsvA37A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Salvaterra <rsalvaterra@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, eunb.song@samsung.com, minchan@kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Chanho Min <chanho.min@lge.com>, Kyungsik Lee <kyungsik.lee@lge.com>

Cc Chanho Min, Kyungsik Lee


Hello,

On (04/06/16 10:39), Rui Salvaterra wrote:
> > may we please ask you to test the patch first? quite possible there
> > is nothing to fix there; I've no access to mips h/w but the patch
> > seems correct to me.
> >
> > LZ4_READ_LITTLEENDIAN_16 does get_unaligned_le16(), so
> > LZ4_WRITE_LITTLEENDIAN_16 must do put_unaligned_le16() /* not put_unaligned() */
> >
[..]
> Consequentially, while I believe the patch will fix the mips case, I'm
> not so sure about ppc (or any other big endian architecture with
> efficient unaligned accesses).

frankly, yes, I took a quick look today (after I sent my initial
message, tho) ... and it is fishy, I agree. was going to followup
on my email but somehow got interrupted, sorry.

so we have, write:
	((U16_S *)(p)) = v    OR    put_unaligned(v, (u16 *)(p))

and only one read:
	get_unaligned_le16(p))

I guess it's either read part also must depend on
HAVE_EFFICIENT_UNALIGNED_ACCESS, or write path
should stop doing so.

I ended up with two patches, NONE was tested (!!!). like at all.

1) provide CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS-dependent
   LZ4_READ_LITTLEENDIAN_16

2) provide common LZ4_WRITE_LITTLEENDIAN_16 and LZ4_READ_LITTLEENDIAN_16
   regardless CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.


assuming that common LZ4_WRITE_LITTLEENDIAN_16 will somehow hit the
performance, I'd probably prefer option #1.

the patch is below. would be great if you can help testing it.

---

 lib/lz4/lz4defs.h | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/lib/lz4/lz4defs.h b/lib/lz4/lz4defs.h
index abcecdc..a23e6c2 100644
--- a/lib/lz4/lz4defs.h
+++ b/lib/lz4/lz4defs.h
@@ -36,10 +36,14 @@ typedef struct _U64_S { u64 v; } U64_S;
 #define PUT4(s, d) (A32(d) = A32(s))
 #define PUT8(s, d) (A64(d) = A64(s))
 #define LZ4_WRITE_LITTLEENDIAN_16(p, v)	\
-	do {	\
-		A16(p) = v; \
-		p += 2; \
+	do {					\
+		A16(p) = v; 			\
+		p += 2; 			\
 	} while (0)
+
+#define LZ4_READ_LITTLEENDIAN_16(d, s, p)	\
+	(d = s - A16(p))
+
 #else /* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */
 
 #define A64(x) get_unaligned((u64 *)&(((U16_S *)(x))->v))
@@ -52,10 +56,13 @@ typedef struct _U64_S { u64 v; } U64_S;
 	put_unaligned(get_unaligned((const u64 *) s), (u64 *) d)
 
 #define LZ4_WRITE_LITTLEENDIAN_16(p, v)	\
-	do {	\
-		put_unaligned(v, (u16 *)(p)); \
-		p += 2; \
+	do {						\
+		put_unaligned_le16(v, (u16 *)(p));	\
+		p += 2; 				\
 	} while (0)
+
+#define LZ4_READ_LITTLEENDIAN_16(d, s, p) 		\
+	(d = s - get_unaligned_le16(p))
 #endif
 
 #define COPYLENGTH 8
@@ -140,9 +147,6 @@ typedef struct _U64_S { u64 v; } U64_S;
 
 #endif
 
-#define LZ4_READ_LITTLEENDIAN_16(d, s, p) \
-	(d = s - get_unaligned_le16(p))
-
 #define LZ4_WILDCOPY(s, d, e)		\
 	do {				\
 		LZ4_COPYPACKET(s, d);	\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
