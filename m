From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
Date: Wed, 10 Aug 2005 05:14:13 +1000
References: <42F57FCA.9040805@yahoo.com.au> <200508090710.00637.phillips@arcor.de> <42F7F5AE.6070403@yahoo.com.au>
In-Reply-To: <42F7F5AE.6070403@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508100514.13672.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 09 August 2005 10:15, Nick Piggin wrote:
> Daniel Phillips wrote:
> > Why don't you pass the vma in zap_details?  For that matter, why are addr
> > and end still passed down the zap chain when zap_details appears to
> > duplicate that information?  OK, it is because zap_details is NULL in
> > about twice as many places as it carries data.  But since the details
> > parameter is already there, would it not make sense to press it into
> > service to slim down those parameter lists a little?
>
> Possibly. I initially did it that way, but it ended up fattening
> paths that don't use details.

It should not, it only affects, hmm, less than 10 places, each at the 
beginning of a massive call chain, e.g., in madvise_dontneed:

-	zap_page_range(vma, start, end - start, NULL);
+	zap_page_range(start, end - start, &(struct zap){ .vma = vma });

> And this way is less intrusive.

Nearly the same I think, and makes forward progress in controlling this 
middle-aged belly roll of an internal API.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
