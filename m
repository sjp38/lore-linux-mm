Message-Id: <200106260114.f5Q1EVg27737@mailg.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: [RFC] VM statistics to gather
Date: Tue, 26 Jun 2001 03:11:03 +0200
References: <Pine.LNX.4.33L.0106252048230.23373-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0106252048230.23373-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 26 June 2001 01:59, Rik van Riel wrote:
> On Tue, 26 Jun 2001, Roger Larsson wrote:
> > What about
> >
> >    unsigned int vm_pgfails /* failed alloc attempts, in pages (not calls)
> > */
>
> What would that represent ?
>
> How often __alloc_pages() exits without allocating anything?

Yes, failed allocs  [Call it vm_pgalloc_fails ?]

>
> > maybe even a
> >
> >    unsigned int vm_pgallocs /* alloc attempts, in pages */
> >
> > for sanity checking - should be the sum of several other combinations...
>
> Sounds like a nice idea.
>

Let this and vm_pgalloc_fails work together,

at __alloc_pages entry (always done) account in vm_pgallocs
at failed exit account in vm_pgallocs_failed

> > Should memory zone be used as dimension?
>
> Useful for allocations I guess, but it may be too confusing
> if we do this for all statistics... OTOH...

Using order as another dimension could also be interesting...
Something like this?

vm_pgallocs[
	order < MAX_ACCOUNT_ORDER ? order : MAX_ACCOUNT_ORDER][
	gfp_mask & GFP_ZONEMASK] += (1 << order)

Or even simpler (assuming MAX_ACCOUNT_ORDER == 1)

vm_pgallocs[!!order][gfp_mask & GFP_ZONEMASK] += (1 << order)

BTW, why is GFP_ZONEMASK 0xf when MAX_NR_ZONES is 3 ? (i.e. 0..2)

/RogerL

-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
