Message-ID: <3CCEF4CC.C56E31B8@zip.com.au>
Date: Tue, 30 Apr 2002 12:47:24 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]Fix: Init page count for all pages during higher order allocs
References: <20020429202446.A2326@in.ibm.com> <m1r8ky1jzu.fsf@frodo.biederman.org> <20020430110108.A1275@in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: suparna@in.ibm.com
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, marcelo@brutus.conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Suparna Bhattacharya wrote:
> 
> ...
> > It might make sense to add a PG_large flag and
> > then in the immediately following struct page add a pointer to the next
> > page, so you can identify these pages by inspection.  Doing something
> > similar to the PG_skip flag.
> 
> Maybe different solutions could emerge for this in 2.4 and 2.5.
> 
> Even a PG_partial flag for the partial pages will enable us to
> traverse back to the main page, and vice-versa to determine the
> partial pages covered by the main page, without any additional
> pointers. Is that an acceptable option for 2.4 ? (That's one
> more page flag ...)
> 

I'd suggest that you go with the PG_partial thing for the
follow-on pages.

If you have a patch for crashdumps, and that patch is
included in the main kernel, and it happens to rely on the
addition of a new page flag well gee, that's a tiny change.

Plus it only affects code paths in the `order > 0' case,
which are rare.

Plus you can independently use PG_partial to detect when
someone is freeing pages from the wrong part of a higher-order
allocation - that's a feature ;)

An alternative is to just set PG_inuse against _all_ pages
in rmqueue(), and clear PG_inuse against all pages in
__free_pages_ok().  Which seems cleaner, and would fix other
problems, I suspect.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
