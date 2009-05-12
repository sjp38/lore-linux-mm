Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CF10C6B005A
	for <linux-mm@kvack.org>; Tue, 12 May 2009 00:15:53 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so2112952rvb.26
        for <linux-mm@kvack.org>; Mon, 11 May 2009 21:16:07 -0700 (PDT)
Message-ID: <4A08F7C0.1050105@gmail.com>
Date: Tue, 12 May 2009 12:14:56 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lib : do code optimization for radix_tree_lookup() and
 radix_tree_lookup_slot()
References: <4A0787B5.8060103@gmail.com> <20090511150045.4cc376db.akpm@linux-foundation.org>
In-Reply-To: <20090511150045.4cc376db.akpm@linux-foundation.org>
Content-Type: multipart/mixed;
 boundary="------------060906010907080503030802"
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060906010907080503030802
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Andrew Morton a??e??:
> On Mon, 11 May 2009 10:04:37 +0800
> Huang Shijie <shijie8@gmail.com> wrote:
>
>   
>>  I think radix_tree_lookup() and radix_tree_lookup_slot() have too much 
>> same code except the return value.
>>  I introduce the function radix_tree_lookup_element() to do the real work.
>>     
>
> Fair enough.
>
> The patch was badly wordwrapped and had all its tabs replaced with
> spaces.  Please fix your email client before sending any further
> patches.
>
> Please also use scripts/checkpatch.pl to check for small stylistic
> errors.  This patch introduced several of them.
>
>   
I feel embararssed to find  that my second patch still has  probloms 
with my email client(thunderbird).

I put the patch  within the attachment.

Sorry to waste your time. I will send patch with "git-send-email" in future.

thanks.


 

--------------060906010907080503030802
Content-Type: text/x-patch;
 name="radix_tree.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="radix_tree.patch"

Signed-off-by: Huang Shijie <shijie8@gmail.com>
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 4bb42a0..defba9b 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -351,20 +351,12 @@ int radix_tree_insert(struct radix_tree_root *root,
 }
 EXPORT_SYMBOL(radix_tree_insert);
 
-/**
- *	radix_tree_lookup_slot    -    lookup a slot in a radix tree
- *	@root:		radix tree root
- *	@index:		index key
- *
- *	Returns:  the slot corresponding to the position @index in the
- *	radix tree @root. This is useful for update-if-exists operations.
- *
- *	This function can be called under rcu_read_lock iff the slot is not
- *	modified by radix_tree_replace_slot, otherwise it must be called
- *	exclusive from other writers. Any dereference of the slot must be done
- *	using radix_tree_deref_slot.
+/*
+ * is_slot == 1 : search for the slot.
+ * is_slot == 0 : search for the node.
  */
-void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
+static void *radix_tree_lookup_element(struct radix_tree_root *root,
+				unsigned long index, int is_slot)
 {
 	unsigned int height, shift;
 	struct radix_tree_node *node, **slot;
@@ -376,7 +368,7 @@ void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
 	if (!radix_tree_is_indirect_ptr(node)) {
 		if (index > 0)
 			return NULL;
-		return (void **)&root->rnode;
+		return is_slot ? (void *)&root->rnode : node;
 	}
 	node = radix_tree_indirect_to_ptr(node);
 
@@ -397,7 +389,25 @@ void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
 		height--;
 	} while (height > 0);
 
-	return (void **)slot;
+	return is_slot ? (void *)slot:node;
+}
+
+/**
+ *	radix_tree_lookup_slot    -    lookup a slot in a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *
+ *	Returns:  the slot corresponding to the position @index in the
+ *	radix tree @root. This is useful for update-if-exists operations.
+ *
+ *	This function can be called under rcu_read_lock iff the slot is not
+ *	modified by radix_tree_replace_slot, otherwise it must be called
+ *	exclusive from other writers. Any dereference of the slot must be done
+ *	using radix_tree_deref_slot.
+ */
+void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
+{
+	return (void **)radix_tree_lookup_element(root, index, 1);
 }
 EXPORT_SYMBOL(radix_tree_lookup_slot);
 
@@ -415,38 +425,7 @@ EXPORT_SYMBOL(radix_tree_lookup_slot);
  */
 void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
 {
-	unsigned int height, shift;
-	struct radix_tree_node *node, **slot;
-
-	node = rcu_dereference(root->rnode);
-	if (node == NULL)
-		return NULL;
-
-	if (!radix_tree_is_indirect_ptr(node)) {
-		if (index > 0)
-			return NULL;
-		return node;
-	}
-	node = radix_tree_indirect_to_ptr(node);
-
-	height = node->height;
-	if (index > radix_tree_maxindex(height))
-		return NULL;
-
-	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
-
-	do {
-		slot = (struct radix_tree_node **)
-			(node->slots + ((index>>shift) & RADIX_TREE_MAP_MASK));
-		node = rcu_dereference(*slot);
-		if (node == NULL)
-			return NULL;
-
-		shift -= RADIX_TREE_MAP_SHIFT;
-		height--;
-	} while (height > 0);
-
-	return node;
+	return radix_tree_lookup_element(root, index, 0);
 }
 EXPORT_SYMBOL(radix_tree_lookup);
 

--------------060906010907080503030802--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
