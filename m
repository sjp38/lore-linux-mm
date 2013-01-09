Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id D40216B0062
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 22:33:13 -0500 (EST)
Message-ID: <1357702376.4838.32.camel@pasglop>
Subject: Re: [PATCH 7/8] mm: use vm_unmapped_area() on powerpc architecture
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 09 Jan 2013 14:32:56 +1100
In-Reply-To: <CANN689EJV_7Q7J4j1ttDxZuqbwD53PAuCHb5DhiE-AVbmNSR7Q@mail.gmail.com>
References: <1357694895-520-1-git-send-email-walken@google.com>
	 <1357694895-520-8-git-send-email-walken@google.com>
	 <1357697739.4838.30.camel@pasglop>
	 <CANN689EJV_7Q7J4j1ttDxZuqbwD53PAuCHb5DhiE-AVbmNSR7Q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 2013-01-08 at 18:38 -0800, Michel Lespinasse wrote:
> 
> Well no fair, the previous patch (for powerpc as well) has 22
> insertions and 93 deletions :)
> 
> The benefit is that the new code has lower algorithmic complexity, it
> replaces a per-vma loop with O(N) complexity with an outer loop that
> finds contiguous slice blocks and passes them to vm_unmapped_area()
> which is only O(log N) complexity. So the new code will be faster for
> workloads which use lots of vmas.
> 
> That said, I do agree that the code that looks for contiguous
> available slices looks kinda ugly - just not sure how to make it look
> nicer though.

Ok. I think at least you can move that construct:

+               if (addr < SLICE_LOW_TOP) {
+                       slice = GET_LOW_SLICE_INDEX(addr);
+                       addr = (slice + 1) << SLICE_LOW_SHIFT;
+                       if (!(available.low_slices & (1u << slice)))
+                               continue;
+               } else {
+                       slice = GET_HIGH_SLICE_INDEX(addr);
+                       addr = (slice + 1) << SLICE_HIGH_SHIFT;
+                       if (!(available.high_slices & (1u << slice)))
+                               continue;
+               }

Into some kind of helper. It will probably compile to the same thing but
at least it's more readable and it will avoid a fuckup in the future if
somebody changes the algorithm and forgets to update one of the
copies :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
