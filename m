Message-ID: <4415F410.90706@yahoo.com.au>
Date: Tue, 14 Mar 2006 09:37:04 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/3] radix tree: RCU lockless read-side
References: <20060207021822.10002.30448.sendpatchset@linux.site>	 <20060207021831.10002.84268.sendpatchset@linux.site>	 <661de9470603110022i25baba63w4a79eb543c5db626@mail.gmail.com>	 <44128EDA.6010105@yahoo.com.au>	 <661de9470603121904h7e83579boe3b26013f771c0f2@mail.gmail.com>	 <4414E2CB.7060604@yahoo.com.au> <661de9470603130724mc95405dr6ee32d00d800d37@mail.gmail.com>
In-Reply-To: <661de9470603130724mc95405dr6ee32d00d800d37@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:

><snip>
>
>>But we should have already rcu_dereference()ed "slot", right
>>(in the loop above this one)? That means we are now able to
>>dereference it, and the data at the other end will be valid.
>>
>>
>
>Yes, but my confusion is about the following piece of code
>
><begin code>
>
>       for ( ; height > 1; height--) {
>
>               for (i = (index >> shift) & RADIX_TREE_MAP_MASK ;
>                               i < RADIX_TREE_MAP_SIZE; i++) {
>-                       if (slot->slots[i] != NULL)
>+                       __s = rcu_dereference(slot->slots[i]);
>+                       if (__s != NULL)
>                               break;
>                       index &= ~((1UL << shift) - 1);
>                       index += 1UL << shift;
>@@ -531,14 +550,14 @@ __lookup(struct radix_tree_root *root, v
>                       goto out;
>
>               shift -= RADIX_TREE_MAP_SHIFT;
>-               slot = slot->slots[i];
>+               slot = __s;
>       }
>
>       /* Bottom level: grab some items */
>       for (i = index & RADIX_TREE_MAP_MASK; i < RADIX_TREE_MAP_SIZE; i++) {
>               index++;
>               if (slot->slots[i]) {
>-                       results[nr_found++] = slot->slots[i];
>+                       results[nr_found++] = &slot->slots[i];
>                       if (nr_found == max_items)
>                               goto out;
>               }
><end code>
>
>In the for loop, lets say __s is *not* NULL, we break from the loop.
>In the loop below
>slot->slots[i] is derefenced without rcu, __s is not used. Is that not
>inconsistent?
>
>

The "slots" member is an array, not an RCU assigned pointer. As such, after
doing rcu_dereference(slot), you can access slot->slots[i] without further
memory barriers I think?

But I agree that code now is a bit inconsistent. I've cleaned things up a
bit in my tree now... but perhaps it is easier if you send a patch to show
what you mean (because sometimes I'm a bit dense, I'm afraid).

Thanks,
Nick

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
