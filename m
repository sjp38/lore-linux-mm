Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j35HmELg538126
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 13:48:14 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j35HmEWs252508
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 11:48:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j35HmE3h006952
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 11:48:14 -0600
Date: Tue, 5 Apr 2005 10:42:39 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [PATCH 3/6] CKRM: Add limit support for mem controller
Message-ID: <20050405174239.GD32645@chandralinux.beaverton.ibm.com>
References: <20050402031346.GD23284@chandralinux.beaverton.ibm.com> <1112623850.24676.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1112623850.24676.8.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 04, 2005 at 07:10:50AM -0700, Dave Hansen wrote:
> On Fri, 2005-04-01 at 19:13 -0800, Chandra Seetharaman wrote:
> > +static void
> > +set_impl_guar_children(struct ckrm_mem_res *parres)
> > +{
> > +       struct ckrm_core_class *child = NULL;
> > +       struct ckrm_mem_res *cres;
> > +       int nr_dontcare = 1; /* for defaultclass */
> > +       int guar, impl_guar;
> > +       int resid = mem_rcbs.resid;
> 
> This sets off one of my internal "this is just wrong" checks: too many
> variables for a function that short.  Can that function be broken up a
> bit?

It doesn't make sense to break the function to a smaller one, and is an
atomic one. nevertheless, it won't do any good to the number of variables :)
I 'll look at what can be done for teh number of variables.
> 
> Also, I get a little nervous when I see variable names like "parres" and
> "mem_rcbs".  Can they get some real names?  If they're going to be
parres - parent resource data structure(do differentiate from parent core
class data structure)
mem_rcbs - memory resource's callback structure
Will think about good names.
> nonsense, at least make it understandable, like 

Just wondering... how can a thing be both understandable and nonsense :)
> 
> >+               cres = ckrm_get_res_class(child, resid, struct ckrm_mem_res);
> 
> I think there are probably enough calls to ckrm_get_res_class() with
> just the memory controller struct to justify wrapping it in its own
> macro.  sysfs does lots of tricks like this, and that's the approach
> that it takes to hide some of the ugliness.

Good idea... 
> 
> > +       while ((child = ckrm_get_next_child(parres->core, child)) != NULL) {
> 
> You might even want a for_each_child() macro or something.  That looks a
> little hairy.

Good idea....
> 
> > 
> > +               /* treat NULL cres as don't care as that child is just
> > being
> > +                * created.
> > +                * FIXME: need a better way to handle this case.
> > +                */
> > +               if (!cres || cres->pg_guar == CKRM_SHARE_DONTCARE)
> > +                       nr_dontcare++;
> 
> If it needs to be fixed, why did you post it?

Because, I didn't want to wait (to post) until I fixed everything.

> 
> > +       parres->nr_dontcare = nr_dontcare;
> > +       guar = (parres->pg_guar == CKRM_SHARE_DONTCARE) ?
> > +                       parres->impl_guar : parres->pg_unused;
> > +       impl_guar = guar / parres->nr_dontcare;
> 
> Please don't tell me this is too messy:
>         
>         parres->nr_dontcare = nr_dontcare;
>         if (parres->pg_guar == CKRM_SHARE_DONTCARE)
>         	guar = parres->impl_guar;
>         else
>         	guar = parres->pg_unused;
>         impl_guar = guar / parres->nr_dontcare;
> 
> All of this 'impl' stufff just looks weird.  I might even wrap that
> CKRM_SHARE_DONTCARE logic in a little function.  get_child_guarantee()?
> 
> All of the logic surrounding that pg_{limit,guar} being set to DONTCARE
> seems like it was special-cased in after it was originally written.
> Like someone went back over it, adding conditionals everywhere.  It
> greatly adds to the clutter.

hmm... will look into it.
> 
> "DONTCARE" is also multiplexed.  It means "no guarantee" or "no limit"
> depending on context.  I don't think it would hurt to have one variable
> for each of these cases.

It is agnostic... and the name doesn't suggest one way or other... so, I
don't see a problem in multiplexing it.

> 
> What does "impl" stand for, anyway?  implied?  implicit? implemented?

I meant implicit... you can also say implied.... will add in comments to
the dats structure definition.

> 
> -- Dave
> 

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
