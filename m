Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB02900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 18:19:47 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so142100522pdb.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 15:19:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pj8si28384105pdb.46.2015.06.02.15.19.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 15:19:46 -0700 (PDT)
Date: Tue, 2 Jun 2015 15:19:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv3] frontswap: allow multiple backends
Message-Id: <20150602151945.9d6b227157852e55a4edb692@linux-foundation.org>
In-Reply-To: <1433282926-15100-1-git-send-email-ddstreet@ieee.org>
References: <1433168544-26301-1-git-send-email-ddstreet@ieee.org>
	<1433282926-15100-1-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue,  2 Jun 2015 18:08:46 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Change frontswap single pointer to a singly linked list of frontswap
> implementations.  Update Xen tmem implementation as register no longer
> returns anything.
> 
> Frontswap only keeps track of a single implementation; any implementation
> that registers second (or later) will replace the previously registered
> implementation, and gets a pointer to the previous implementation that
> the new implementation is expected to pass all frontswap functions to
> if it can't handle the function itself.  However that method doesn't
> really make much sense, as passing that work on to every implementation
> adds unnecessary work to implementations; instead, frontswap should
> simply keep a list of all registered implementations and try each
> implementation for any function.  Most importantly, neither of the
> two currently existing frontswap implementations in the kernel actually
> do anything with any previous frontswap implementation that they
> replace when registering.
> 
> This allows frontswap to successfully manage multiple implementations
> by keeping a list of them all.
> 

offtopic trivia: this

--- a/mm/frontswap.c~frontswap-allow-multiple-backends-fix
+++ a/mm/frontswap.c
@@ -111,14 +111,11 @@ static inline void inc_frontswap_invalid
  */
 void frontswap_register_ops(struct frontswap_ops *ops)
 {
-	DECLARE_BITMAP(a, MAX_SWAPFILES);
-	DECLARE_BITMAP(b, MAX_SWAPFILES);
+	DECLARE_BITMAP(a, MAX_SWAPFILES) = { };
+	DECLARE_BITMAP(b, MAX_SWAPFILES) = { };
 	struct swap_info_struct *si;
 	unsigned int i;
 
-	bitmap_zero(a, MAX_SWAPFILES);
-	bitmap_zero(b, MAX_SWAPFILES);
-
 	spin_lock(&swap_lock);
 	plist_for_each_entry(si, &swap_active_head, list) {
 		if (!WARN_ON(!si->frontswap_map))

saves 64 bytes of text with my gcc.


It shouldn't be open-coded here, but a new macro in bitmap.h could be
useful, assuming it's a win for other sizes of bitmaps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
