Date: Tue, 16 Aug 2005 13:49:34 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Zoned CART
In-Reply-To: <43024435.90503@andrew.cmu.edu>
Message-ID: <Pine.LNX.4.62.0508161318420.7906@schroedinger.engr.sgi.com>
References: <1123857429.14899.59.camel@twins>  <1124024312.30836.26.camel@twins>
 <1124141492.15180.22.camel@twins> <43024435.90503@andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rahul Iyer <rni@andrew.cmu.edu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Hmm. I am a bit concerned about the proliferation of counters in CART 
because these may lead to bouncing cachelines.

The paper mentions some relationships between the different values. 

If we had a counter for the number of pages resident (nr_rpages) 
(|T1|+|T2|) then that counter would gradually approach c and then no 
longer change.

Then

|T2| = nr_rpages - |T1|

Similarly if we had a counter for the number of pages on the evicted 
list (nr_evicted) then that counter would also gradually approach c and 
then stay constant. nr_evicted would only increase if nr_rpages has 
already reached c which is another good thing to avoid bouncing 
cachelines.

Then also

|B2| = nr_evicted - |B1|

Thus we could reduce the frequency of counter increments on a fully 
loaded system (where nr_rpages = c and nr_eviced = c) by 
calculating some variables:

#define nr_inactive (nr_rpages - nr_active)
#define nr_evicted_longterm (nr_evicted - nr_evicted_shortterm)

There is also a relationship between |S| and |L| since these attributes 
are only used on resident pages.

|L| = nr_rpages - |S|

So

#define nr_longterm (nr_rpages - nr_shortterm)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
