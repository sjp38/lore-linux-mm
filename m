Received: by zproxy.gmail.com with SMTP id l1so1318255nzf
        for <linux-mm@kvack.org>; Mon, 13 Mar 2006 07:24:47 -0800 (PST)
Message-ID: <661de9470603130724mc95405dr6ee32d00d800d37@mail.gmail.com>
Date: Mon, 13 Mar 2006 20:54:47 +0530
From: "Balbir Singh" <bsingharora@gmail.com>
Subject: Re: [patch 1/3] radix tree: RCU lockless read-side
In-Reply-To: <4414E2CB.7060604@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060207021822.10002.30448.sendpatchset@linux.site>
	 <20060207021831.10002.84268.sendpatchset@linux.site>
	 <661de9470603110022i25baba63w4a79eb543c5db626@mail.gmail.com>
	 <44128EDA.6010105@yahoo.com.au>
	 <661de9470603121904h7e83579boe3b26013f771c0f2@mail.gmail.com>
	 <4414E2CB.7060604@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

<snip>

>
> But we should have already rcu_dereference()ed "slot", right
> (in the loop above this one)? That means we are now able to
> dereference it, and the data at the other end will be valid.
>

Yes, but my confusion is about the following piece of code

<begin code>

       for ( ; height > 1; height--) {

               for (i = (index >> shift) & RADIX_TREE_MAP_MASK ;
                               i < RADIX_TREE_MAP_SIZE; i++) {
-                       if (slot->slots[i] != NULL)
+                       __s = rcu_dereference(slot->slots[i]);
+                       if (__s != NULL)
                               break;
                       index &= ~((1UL << shift) - 1);
                       index += 1UL << shift;
@@ -531,14 +550,14 @@ __lookup(struct radix_tree_root *root, v
                       goto out;

               shift -= RADIX_TREE_MAP_SHIFT;
-               slot = slot->slots[i];
+               slot = __s;
       }

       /* Bottom level: grab some items */
       for (i = index & RADIX_TREE_MAP_MASK; i < RADIX_TREE_MAP_SIZE; i++) {
               index++;
               if (slot->slots[i]) {
-                       results[nr_found++] = slot->slots[i];
+                       results[nr_found++] = &slot->slots[i];
                       if (nr_found == max_items)
                               goto out;
               }
<end code>

In the for loop, lets say __s is *not* NULL, we break from the loop.
In the loop below
slot->slots[i] is derefenced without rcu, __s is not used. Is that not
inconsistent?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
