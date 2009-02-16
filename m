Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0946B007E
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 08:55:10 -0500 (EST)
Date: Mon, 16 Feb 2009 14:56:43 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] Export symbol ksize()
Message-ID: <20090216135643.GA6927@cmpxchg.org>
References: <1234272104-10211-1-git-send-email-kirill@shutemov.name> <84144f020902100535i4d626a9fj8cbb305120cf332a@mail.gmail.com> <20090210134651.GA5115@epbyminw8406h.minsk.epam.com> <Pine.LNX.4.64.0902101605070.20991@melkki.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0902101605070.20991@melkki.cs.Helsinki.FI>
Sender: owner-linux-mm@kvack.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 04:06:53PM +0200, Pekka J Enberg wrote:
> On Tue, Feb 10, 2009 at 03:35:03PM +0200, Pekka Enberg wrote:
> > > We unexported ksize() because it's a problematic interface and you
> > > almost certainly want to use the alternatives (e.g. krealloc). I think
> > > I need bit more convincing to apply this patch...
>  
> On Tue, 10 Feb 2009, Kirill A. Shutemov wrote:
> > It just a quick fix. If anybody knows better solution, I have no
> > objections.
> 
> Herbert, what do you think of this (untested) patch? Alternatively, we 
> could do something like kfree_secure() but it seems overkill for this one 
> call-site.

There are more callsites which do memset() + kfree():

	arch/s390/crypto/prng.c
	drivers/s390/crypto/zcrypt_pcixcc.c
	drivers/md/dm-crypt.c
	drivers/usb/host/hwa-hc.c
	drivers/usb/wusbcore/cbaf.c
	(drivers/w1/w1{,_int}.c)
	fs/cifs/misc.c
	fs/cifs/connect.c
	fs/ecryptfs/keystore.c
	fs/ecryptfs/messaging.c
	net/atm/mpoa_caches.c

How about the attached patch?  One problem is that zeroing ksize()
bytes can have an overhead of nearly twice the actual allocation size.

So we would need an interface that lets the caller pass in either a
number of bytes it wants to have zeroed out or say idontknow.

Perhaps add a size parameter that is cut to ksize() if it's too big?
Or (ssize_t)-1 for figureitoutyourself?

	Hannes

---
Subject: slab: introduce kzfree()

kzfree() is a wrapper for kfree() that additionally zeroes the
underlying memory before releasing it to the slab allocator.

---
 include/linux/slab.h |    1 +
 mm/util.c            |   20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -127,6 +127,7 @@ int kmem_ptr_validate(struct kmem_cache 
 void * __must_check __krealloc(const void *, size_t, gfp_t);
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
+void kzfree(const void *);
 size_t ksize(const void *);
 
 /*
--- a/mm/util.c
+++ b/mm/util.c
@@ -129,6 +129,26 @@ void *krealloc(const void *p, size_t new
 }
 EXPORT_SYMBOL(krealloc);
 
+/**
+ * kzfree - like kfree but zero memory
+ * @p: object to free memory of
+ * @zsize: size of the memory region to zero
+ *
+ * The memory of the object @p points to is zeroed before freed.
+ * If @p is %NULL, kzfree() does nothing.
+ */
+void kzfree(const void *p)
+{
+	size_t ks;
+	void *mem = (void *)p;
+
+	if (unlikely(ZERO_OR_NULL_PTR(mem)))
+		return;
+	ks = ksize(mem);
+	memset(mem, 0, ks);
+	kfree(mem);
+}
+
 /*
  * strndup_user - duplicate an existing string from user space
  * @s: The string to duplicate

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
