Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j34EAt4I530714
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 10:10:55 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j34EAtwV244598
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 08:10:55 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j34EAsvw022986
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 08:10:55 -0600
Subject: Re: [PATCH 3/6] CKRM: Add limit support for mem controller
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050402031346.GD23284@chandralinux.beaverton.ibm.com>
References: <20050402031346.GD23284@chandralinux.beaverton.ibm.com>
Content-Type: text/plain
Date: Mon, 04 Apr 2005 07:10:50 -0700
Message-Id: <1112623850.24676.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chandra Seetharaman <sekharan@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2005-04-01 at 19:13 -0800, Chandra Seetharaman wrote:
> +static void
> +set_impl_guar_children(struct ckrm_mem_res *parres)
> +{
> +       struct ckrm_core_class *child = NULL;
> +       struct ckrm_mem_res *cres;
> +       int nr_dontcare = 1; /* for defaultclass */
> +       int guar, impl_guar;
> +       int resid = mem_rcbs.resid;

This sets off one of my internal "this is just wrong" checks: too many
variables for a function that short.  Can that function be broken up a
bit?

Also, I get a little nervous when I see variable names like "parres" and
"mem_rcbs".  Can they get some real names?  If they're going to be
nonsense, at least make it understandable, like 

>+               cres = ckrm_get_res_class(child, resid, struct ckrm_mem_res);

I think there are probably enough calls to ckrm_get_res_class() with
just the memory controller struct to justify wrapping it in its own
macro.  sysfs does lots of tricks like this, and that's the approach
that it takes to hide some of the ugliness.

> +       while ((child = ckrm_get_next_child(parres->core, child)) != NULL) {

You might even want a for_each_child() macro or something.  That looks a
little hairy.

> 
> +               /* treat NULL cres as don't care as that child is just
> being
> +                * created.
> +                * FIXME: need a better way to handle this case.
> +                */
> +               if (!cres || cres->pg_guar == CKRM_SHARE_DONTCARE)
> +                       nr_dontcare++;

If it needs to be fixed, why did you post it?

> +       parres->nr_dontcare = nr_dontcare;
> +       guar = (parres->pg_guar == CKRM_SHARE_DONTCARE) ?
> +                       parres->impl_guar : parres->pg_unused;
> +       impl_guar = guar / parres->nr_dontcare;

Please don't tell me this is too messy:
        
        parres->nr_dontcare = nr_dontcare;
        if (parres->pg_guar == CKRM_SHARE_DONTCARE)
        	guar = parres->impl_guar;
        else
        	guar = parres->pg_unused;
        impl_guar = guar / parres->nr_dontcare;

All of this 'impl' stufff just looks weird.  I might even wrap that
CKRM_SHARE_DONTCARE logic in a little function.  get_child_guarantee()?

All of the logic surrounding that pg_{limit,guar} being set to DONTCARE
seems like it was special-cased in after it was originally written.
Like someone went back over it, adding conditionals everywhere.  It
greatly adds to the clutter.

"DONTCARE" is also multiplexed.  It means "no guarantee" or "no limit"
depending on context.  I don't think it would hurt to have one variable
for each of these cases.

What does "impl" stand for, anyway?  implied?  implicit? implemented?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
