Subject: Re: [RFC][PATCH 2/6] CART Implementation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.63.0508282301390.13831@cuia.boston.redhat.com>
References: <20050827215756.726585000@twins>
	 <20050827220300.688094000@twins>
	 <Pine.LNX.4.63.0508282301390.13831@cuia.boston.redhat.com>
Content-Type: text/plain
Date: Mon, 29 Aug 2005 06:15:07 +0200
Message-Id: <1125288907.20161.111.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2005-08-28 at 23:02 -0400, Rik van Riel wrote:
> On Sat, 27 Aug 2005, a.p.zijlstra@chello.nl wrote:
> 
> > +static void bucket_stats(struct nr_bucket * nr_bucket, int * b1, int * b2)
> > +{
> > +	unsigned int i, b[2] = {0, 0};
> > +	for (i = 0; i < 2; ++i) {
> > +		unsigned int j = nr_bucket->hand[i];
> > +		do
> > +		{
> > +			u32 *slot = &nr_bucket->slot[j];
> > +			if (!!(GET_FLAGS(*slot) & NR_list) != !!i)
> > +				break;
> > +
> > +			j = GET_INDEX(*slot);
> > +			++b[i];
> > +		} while (j != nr_bucket->hand[i]);
> 
> Does this properly skip empty slots ?

There are no empty slots. This thing always has B1_j + B2_j = NR_SLOTS.
I couldn't manage keeping track of two lists and empty slots. It doesn't
really matter though. I just have to start out with |B1| = 0 and |B2| =
c. I fill B2_j with zero cookies, so getting a hit there is very
unlikely, that way they just get overwritten due to old age and all is
well.

> 
> Remember that a page that got paged in leaves a zeroed
> out slot in the bucket...
> 
Yeah, I was playing aroung with that. I'll change that back because it
does indeed generate a problem elsewhere.

-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
