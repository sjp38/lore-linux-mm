Message-Id: <200505181757.j4IHv0g14491@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
Date: Wed, 18 May 2005 10:57:00 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
In-Reply-To: <17035.30820.347382.9137@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Wolfgang Wander' <wwc@rentec.com>
Cc: =?iso-8859-1?Q?Herv=E9_Piedvache?= <herve@elma.fr>, 'Andrew Morton' <akpm@osdl.org>, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Wolfgang Wander wrote on Wednesday, May 18, 2005 10:16 AM
> My goal was to place small requests close to the base while leaving
> larger holes open as long as possible and far from the base. 2.4
> kernels did this inadvertently by always starting to search from the
> base, my patch starts searching from the base (upward or downward)
> if the new request is known to fit between base and current cache
> pointer, thus it maintains the 2.4 quality of mixing small and large
> requests and maintains the huge speedups Ingo introduced with the
> cache pointer.

This algorithm tends to penalize small size request and it would do a
linear search from the beginning. It would also penalize large size
request since cache pointer will be reset to a lower address and making
a subsequent large request to search forward.  In your case, since all
mappings are anonymous mmap with same page protection, you won't notice
performance problem because of coalescing in the mapped area.  But other
app like apache web server, which mmap thousands of different files will
degrade. The probability of linear search is lot higher with this proposal.
The nice thing about the current *broken* cache pointer is that it is
almost an O(1) order to fulfill a request since it moves in one direction.
The new proposal would reduce that O(1) probability.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
