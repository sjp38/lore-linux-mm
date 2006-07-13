Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH] ia64: race flushing icache in COW path
Date: Thu, 13 Jul 2006 13:37:17 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A38D779@scsmsx411.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Baron <jbaron@redhat.com>
Cc: torvalds@osdl.org, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> lazy_mmu_prot_update() is used in a number of other places *after* the pte 
> is established. An explanation as to why this case is different, would be 
> interesting.

The other places do need a close look, it seems that some of
them may not be needed (e.g. the one inside "if (reuse) { }" at
the top of do_wp_page() ... at the moment I'm struggling to see
what it manages to achieve).

Most of the rest are in cases where we are adding a new virtual
page (comments like "No need to invalidate - it was non-present
before").  These may also need to have the order shuffled, but
they seem unlikely to be the cause of a bug (it is unlikely
that an application has threads that branch to new anonymous
pages as they are being attached to the process).

So you are right that there may be some more work here, but
I wanted to get the one-liner that is a clear and obvious
bugfix posted without being cluttered with some less obvious
fixes.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
