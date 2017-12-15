Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC366B0033
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 12:10:33 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f7so8276545pfa.21
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 09:10:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w189si4855424pgd.73.2017.12.15.09.10.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 09:10:31 -0800 (PST)
Date: Fri, 15 Dec 2017 09:10:12 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Storing errors in the XArray
Message-ID: <20171215171012.GA11918@bombadil.infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-9-willy@infradead.org>
 <66ad068b-1973-ca41-7bbf-8a0634cc488d@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <66ad068b-1973-ca41-7bbf-8a0634cc488d@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Dec 11, 2017 at 03:10:22PM -0800, Randy Dunlap wrote:
> > +The XArray does not support storing :c:func:`IS_ERR` pointers; some
> > +conflict with data values and others conflict with entries the XArray
> > +uses for its own purposes.  If you need to store special values which
> > +cannot be confused with real kernel pointers, the values 4, 8, ... 4092
> > +are available.
> 
> or if I know that they values are errno-range values, I can just shift them
> left by 2 to store them and then shift them right by 2 to use them?

On further thought, I like this idea so much, it's worth writing helpers
for this usage.  And test-suite (also doubles as a demonstration of how
to use it).

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index c616e9319c7c..53aa251df57a 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -232,6 +232,39 @@ static inline bool xa_is_value(const void *entry)
 	return (unsigned long)entry & 1;
 }
 
+/**
+ * xa_mk_errno() - Create an XArray entry from an error number.
+ * @error: Error number to store in XArray.
+ *
+ * Return: An entry suitable for storing in the XArray.
+ */
+static inline void *xa_mk_errno(long error)
+{
+	return (void *)(error << 2);
+}
+
+/**
+ * xa_to_errno() - Get error number stored in an XArray entry.
+ * @entry: XArray entry.
+ *
+ * Return: The error number stored in the XArray entry.
+ */
+static inline unsigned long xa_to_errno(const void *entry)
+{
+	return (long)entry >> 2;
+}
+
+/**
+ * xa_is_errno() - Determine if an entry is an errno.
+ * @entry: XArray entry.
+ *
+ * Return: True if the entry is an errno, false if it is a pointer.
+ */
+static inline bool xa_is_errno(const void *entry)
+{
+	return (((unsigned long)entry & 3) == 0) && (entry > (void *)-4096);
+}
+
 /**
  * xa_is_internal() - Is the entry an internal entry?
  * @entry: Entry retrieved from the XArray
diff --git a/tools/testing/radix-tree/xarray-test.c b/tools/testing/radix-tree/xarray-test.c
index 43111786ebdd..b843cedf3988 100644
--- a/tools/testing/radix-tree/xarray-test.c
+++ b/tools/testing/radix-tree/xarray-test.c
@@ -29,7 +29,13 @@ void check_xa_err(struct xarray *xa)
 	assert(xa_err(xa_store(xa, 1, xa_mk_value(0), GFP_KERNEL)) == 0);
 	assert(xa_err(xa_store(xa, 1, NULL, 0)) == 0);
 // kills the test-suite :-(
-//     assert(xa_err(xa_store(xa, 0, xa_mk_internal(0), 0)) == -EINVAL);
+//	assert(xa_err(xa_store(xa, 0, xa_mk_internal(0), 0)) == -EINVAL);
+
+	assert(xa_err(xa_store(xa, 0, xa_mk_errno(-ENOMEM), GFP_KERNEL)) == 0);
+	assert(xa_err(xa_load(xa, 0)) == 0);
+	assert(xa_is_errno(xa_load(xa, 0)) == true);
+	assert(xa_to_errno(xa_load(xa, 0)) == -ENOMEM);
+	xa_erase(xa, 0);
 }
 
 void check_xa_tag(struct xarray *xa)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
