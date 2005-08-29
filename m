Subject: Re: [RFC][PATCH 2/6] CART Implementation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1125288907.20161.111.camel@twins>
References: <20050827215756.726585000@twins>
	 <20050827220300.688094000@twins>
	 <Pine.LNX.4.63.0508282301390.13831@cuia.boston.redhat.com>
	 <1125288907.20161.111.camel@twins>
Content-Type: text/plain
Date: Mon, 29 Aug 2005 08:20:40 +0200
Message-Id: <1125296440.20824.82.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm being dense again. I really should not write these mails at 6am :-{

On Mon, 2005-08-29 at 06:15 +0200, Peter Zijlstra wrote:
> On Sun, 2005-08-28 at 23:02 -0400, Rik van Riel wrote:
> > On Sat, 27 Aug 2005, a.p.zijlstra@chello.nl wrote:
> > 
> > > +static void bucket_stats(struct nr_bucket * nr_bucket, int * b1, int * b2)
> > > +{
> > > +	unsigned int i, b[2] = {0, 0};
> > > +	for (i = 0; i < 2; ++i) {
> > > +		unsigned int j = nr_bucket->hand[i];
> > > +		do
> > > +		{
> > > +			u32 *slot = &nr_bucket->slot[j];
> > > +			if (!!(GET_FLAGS(*slot) & NR_list) != !!i)
> > > +				break;
> > > +
> > > +			j = GET_INDEX(*slot);
> > > +			++b[i];
> > > +		} while (j != nr_bucket->hand[i]);
> > 
> > Does this properly skip empty slots ?
> 
I should idd skip 0 cookie slots for the stats. The hidden assumption
was that the balance would not be disturbed by these null cookies; which
is not obvious true. Thanks for the hint.

> There are no empty slots. This thing always has B1_j + B2_j = NR_SLOTS.
> I couldn't manage keeping track of two lists and empty slots. It doesn't
> really matter though. I just have to start out with |B1| = 0 and |B2| =
> c. I fill B2_j with zero cookies, so getting a hit there is very
> unlikely, that way they just get overwritten due to old age and all is
> well.
> 
I could ofcourse make the head 1 byte and have 4 list heads in there,
that way I even have 1 spare. I'll see what kind of mess that would
give ;-).

> > 
> > Remember that a page that got paged in leaves a zeroed
> > out slot in the bucket...
> > 
> Yeah, I was playing aroung with that. I'll change that back because it
> does indeed generate a problem elsewhere.

should be there again in the second series I send out earlier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
