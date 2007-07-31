Date: Mon, 30 Jul 2007 17:20:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-Id: <20070730172007.ddf7bdee.akpm@linux-foundation.org>
In-Reply-To: <20070731000138.GA32468@localdomain>
References: <20070727232753.GA10311@localdomain>
	<20070730132314.f6c8b4e1.akpm@linux-foundation.org>
	<20070731000138.GA32468@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@engr.sgi.com>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007 17:01:38 -0700
Ravikiran G Thirumalai <kiran@scalex86.org> wrote:

> >The (cheesy) way in which reclaim currently handles this sort of thing is
> >to scan like mad, then to eventually set zone->all_unreclaimable.  Once
> >that has been set, the kernel will reduce the amount of scanning effort it
> >puts into that zone by a very large amount.  If the zone later comes back
> >to life, all_unreclaimable gets cleared and things proceed as normal.
> 
> I see.  But this obviously does not work in this case.  I have noticed the
> process getting into 'system' and staying there for hours.  I have never
> noticed the app complete.  Perhaps because I did not wait long enough.
> So do you think a more aggressive auto setting/unsetting of 'all_unreclaimable'
> is a better approach?

The problem is that __zone_reclaim() doesn't use all_unreclaimable at all.
You'll note that all the other callers of shrink_zone() do take avoiding
action if the zone is in all_unreclaimable state, but __zone_reclaim() forgot
to.

Fixing that could/should fix your CPU consumption problem.  It will further
propagate the existing lameness, but replacing all_unreclaimable with something
more efficient, more accurate and more complex is a separate problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
