Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3DC46B027D
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:45 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id x62so3113741iod.7
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 15si5610968itg.134.2017.12.15.14.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:44 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 21/78] xarray: Add ability to store errno values
Date: Fri, 15 Dec 2017 14:03:53 -0800
Message-Id: <20171215220450.7899-22-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

While the radix tree offers no ability to store IS_ERR pointers,
documenting that the XArray does not led to some concern.  Here is a
sanctioned way to store errnos in the XArray.  I'm concerned that it
will confuse people who can't tell the difference between xa_is_err()
and xa_is_errno(), so I've added copious kernel-doc to help them tell
the difference.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 Documentation/core-api/xarray.rst      |  9 ++++---
 include/linux/xarray.h                 | 46 +++++++++++++++++++++++++++++++++-
 tools/testing/radix-tree/xarray-test.c |  8 +++++-
 3 files changed, 57 insertions(+), 6 deletions(-)

diff --git a/Documentation/core-api/xarray.rst b/Documentation/core-api/xarray.rst
index 706081bfe92f..57a494026d96 100644
--- a/Documentation/core-api/xarray.rst
+++ b/Documentation/core-api/xarray.rst
@@ -42,11 +42,12 @@ When you retrieve an entry from the XArray, you can check whether it is
 a value entry by calling :c:func:`xa_is_value`, and convert it back to
 an integer by calling :c:func:`xa_to_value`.
 
-The XArray does not support storing :c:func:`IS_ERR` pointers as some
+The XArray does not support storing :c:func:`IS_ERR` pointers because some
 conflict with value entries or internal entries.  If you need to store
-error numbers in the array, you can store ``(errno << 2)`` as these values
-will be aligned to a multiple of 4 and are not valid kernel pointers.
-The values 4, 8, ... 4092 are also not valid kernel pointers.
+error numbers in the array, you can encode them into error entries
+with :c:func:`xa_mk_errno`, check whether a returned entry is an error
+with :c:func:`xa_is_errno` and convert it back into an errno with
+:c:func:`xa_to_errno`.
 
 An unusual feature of the XArray is the ability to create entries which
 occupy a range of indices.  Once stored to, looking up any index in
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index bcc321fb280f..e0f8eb06b874 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -231,6 +231,50 @@ static inline bool xa_is_value(const void *entry)
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
+ * Calling this function on an entry which is not an xa_is_errno() will
+ * yield unpredictable results.  Do not confuse this function with xa_err();
+ * this function is for errnos which have been stored in the XArray, and
+ * that function is for errors returned from the XArray implementation.
+ *
+ * Return: The error number stored in the XArray entry.
+ */
+static inline long xa_to_errno(const void *entry)
+{
+	return (long)entry >> 2;
+}
+
+/**
+ * xa_is_errno() - Determine if an entry is an errno.
+ * @entry: XArray entry.
+ *
+ * Do not confuse this function with xa_is_err(); that function tells you
+ * whether the XArray implementation returned an error; this function
+ * tells you whether the entry you successfully stored in the XArray
+ * represented an errno.  If you have never stored an errno in the XArray,
+ * you do not have to check this.
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
@@ -277,7 +321,7 @@ static inline int xa_err(void *entry)
 
 /**
  * xa_store_empty() - Store this entry in the XArray unless another entry is
- * 			already present.
+ *			already present.
  * @xa: XArray.
  * @index: Index into array.
  * @entry: New entry.
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
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
