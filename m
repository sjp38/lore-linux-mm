Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6310F900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 00:48:25 -0400 (EDT)
Date: Thu, 14 Apr 2011 14:48:07 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH] mm/thp: Use conventional format for boolean attributes
Message-ID: <20110414144807.19ec5f69@notabene.brown>
In-Reply-To: <alpine.DEB.2.00.1104131202230.5563@chino.kir.corp.google.com>
References: <1300772711.26693.473.camel@localhost>
	<alpine.DEB.2.00.1104131202230.5563@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ben Hutchings <ben@decadent.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, 13 Apr 2011 12:04:59 -0700 (PDT) David Rientjes <rientjes@google.com>
wrote:

> On Tue, 22 Mar 2011, Ben Hutchings wrote:
> 
> > The conventional format for boolean attributes in sysfs is numeric
> > ("0" or "1" followed by new-line).  Any boolean attribute can then be
> > read and written using a generic function.  Using the strings
> > "yes [no]", "[yes] no" (read), "yes" and "no" (write) will frustrate
> > this.
> > 
> > Cc'd to stable in order to change this before many scripts depend on
> > the current strings.
> > 
> 
> I agree with this in general, it's certainly the standard way of altering 
> a boolean tunable throughout the kernel so it would be nice to use the 
> same userspace libraries with THP.
> 
> Let's cc Andrew on this since it will go through the -mm tree if it's 
> merged.
> 
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > Cc: stable@kernel.org [2.6.38]
> > ---
> >  mm/huge_memory.c |   21 +++++++++++----------
> >  1 files changed, 11 insertions(+), 10 deletions(-)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 113e35c..dc0b3f0 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -244,24 +244,25 @@ static ssize_t single_flag_show(struct kobject *kobj,
> >  				struct kobj_attribute *attr, char *buf,
> >  				enum transparent_hugepage_flag flag)
> >  {
> > -	if (test_bit(flag, &transparent_hugepage_flags))
> > -		return sprintf(buf, "[yes] no\n");
> > -	else
> > -		return sprintf(buf, "yes [no]\n");
> > +	return sprintf(buf, "%d\n",
> > +		       test_bit(flag, &transparent_hugepage_flags));

It test bit guaranteed to return 0 or 1?

I think the x86 version returns 0 or -1 (that is from reading the code and
using google to check what 'sbb' does).

Maybe make it "!!test_bit" or even

     strcpy(buf, test_bit(...) ? "1\n" : "0\n");
     return 2;


NeilBrown


> >  }
> >  static ssize_t single_flag_store(struct kobject *kobj,
> >  				 struct kobj_attribute *attr,
> >  				 const char *buf, size_t count,
> >  				 enum transparent_hugepage_flag flag)
> >  {
> > -	if (!memcmp("yes", buf,
> > -		    min(sizeof("yes")-1, count))) {
> > +	unsigned long value;
> > +	char *endp;
> > +
> > +	value = simple_strtoul(buf, &endp, 0);
> > +	if (endp == buf || value > 1)
> > +		return -EINVAL;
> > +
> > +	if (value)
> >  		set_bit(flag, &transparent_hugepage_flags);
> > -	} else if (!memcmp("no", buf,
> > -			   min(sizeof("no")-1, count))) {
> > +	else
> >  		clear_bit(flag, &transparent_hugepage_flags);
> > -	} else
> > -		return -EINVAL;
> >  
> >  	return count;
> >  }
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
