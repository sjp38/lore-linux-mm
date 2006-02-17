Subject: Re: [RFC] 4/4 Migration Cache - use for direct migration
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <Pine.LNX.4.64.0602170834310.30999@schroedinger.engr.sgi.com>
References: <1140190651.5219.25.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0602170834310.30999@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 17 Feb 2006 13:37:58 -0500
Message-Id: <1140201478.5219.132.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-02-17 at 08:35 -0800, Christoph Lameter wrote:
> On Fri, 17 Feb 2006, Lee Schermerhorn wrote:
> 
> > Index: linux-2.6.16-rc3-mm1/mm/vmscan.c
> > ===================================================================
> > --- linux-2.6.16-rc3-mm1.orig/mm/vmscan.c	2006-02-15 10:50:59.000000000 -0500
> > +++ linux-2.6.16-rc3-mm1/mm/vmscan.c	2006-02-15 10:51:09.000000000 -0500
> > @@ -911,7 +911,12 @@ redo:
> >  		 * preserved.
> >  		 */
> >  		if (PageAnon(page) && !PageSwapCache(page)) {
> > -			if (!add_to_swap(page, GFP_KERNEL)) {
> > +			if (!to) {
> > +				if (!add_to_swap(page, GFP_KERNEL)) {
> > +					rc = -ENOMEM;
> > +					goto unlock_page;
> > +				}
> > +			} else if (add_to_migration_cache(page, GFP_KERNEL)) {
> >  				rc = -ENOMEM;
> >  				goto unlock_page;
> >  			}
> 
> Hmmm.... maybe add another parameter to add_to_swap instead? This seems to 
> be duplicating some code.
> 

Could do.  The value of which would depend on 'to' in this context.  

This would require a change to shrink_list() in vmscan which you wanted
to avoid in comment on previous mail, or we could leave add_to_swap() as
a wrapper over the current one renamed to __add_to_swap or such with the
extra parameter.

Could also change the code above to use a single if:

if ((!to && !add_to_swap()) || (to && add_to_migration_cache())) ...

I'm not too clear on what passes for "readability" and how that weighs
against this level code duplication. ;-)

But, in general, I agree with the notion of hiding the details or
even existence of the migration cache behind the swap interfaces.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
