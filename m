Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4434C6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 11:27:05 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 12-v6so2666991qtq.8
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 08:27:05 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id k7-v6si3090415qkd.125.2018.06.05.08.27.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jun 2018 08:27:03 -0700 (PDT)
Date: Tue, 5 Jun 2018 15:27:02 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: HARDENED_USERCOPY will BUG on multiple slub objects coalesced
 into an sk_buff fragment
In-Reply-To: <CAKYffwpAAgD+a+0kebid43tpyS6L+8o=4hBbDvhfgaoV_gze1g@mail.gmail.com>
Message-ID: <01000163d08f00b4-068f6b54-5d34-447d-90c6-010a24fc36d5-000000@email.amazonses.com>
References: <CAKYffwqAXWUhdmU7t+OzK1A2oODS+WsfMKJZyWVTwxzR2QbHbw@mail.gmail.com> <55be03eb-3d0d-d43d-b0a4-669341e6d9ab@redhat.com> <CAGXu5jKYsS2jnRcb9RhFwvB-FLdDhVyAf+=CZ0WFB9UwPdefpw@mail.gmail.com> <20180601205837.GB29651@bombadil.infradead.org>
 <CAGXu5jLvN5bmakZ3aDu4TRB9+_DYVaCX2LTLtKvsqgYpjMaNsA@mail.gmail.com> <CAKYffwpAAgD+a+0kebid43tpyS6L+8o=4hBbDvhfgaoV_gze1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Eidelman <anton@lightbitslabs.com>
Cc: Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-hardened@lists.openwall.com

On Fri, 1 Jun 2018, Anton Eidelman wrote:

> I do not have a way of reproducing this decent enough to recommend: I'll
> keep digging.

If you can reproduce it: Could you try the following patch?



Subject: [NET] Fix false positives of skb_can_coalesce

Skb fragments may be slab objects. Two slab objects may reside
in the same slab page. In that case skb_can_coalesce() may return
true althought the skb cannot be expanded because it would
cross a slab boundary.

Enabling slab debugging will avoid the issue since red zones will
be inserted and thus the skb_can_coalesce() check will not detect
neighboring objects and return false.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/skbuff.h
===================================================================
--- linux.orig/include/linux/skbuff.h
+++ linux/include/linux/skbuff.h
@@ -3010,8 +3010,29 @@ static inline bool skb_can_coalesce(stru
 	if (i) {
 		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];

-		return page == skb_frag_page(frag) &&
-		       off == frag->page_offset + skb_frag_size(frag);
+		if (page != skb_frag_page(frag))
+			return false;
+
+		if (off != frag->page_offset + skb_frag_size(frag))
+			return false;
+
+		/*
+		 * This may be a slab page and we may have pointers
+		 * to different slab objects in the same page
+		 */
+		if (!PageSlab(skb_frag_page(frag)))
+			return true;
+
+		/*
+		 * We could still return true if we would check here
+		 * if the two fragments are within the same
+		 * slab object. But that is complicated and
+		 * I guess we would need a new slab function
+		 * to check if two pointers are within the same
+		 * object.
+		 */
+		return false;
+
 	}
 	return false;
 }
