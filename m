Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 489D9900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 06:01:36 -0400 (EDT)
Date: Mon, 18 Apr 2011 12:01:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v2] mm: make expand_downwards symmetrical to expand_upwards
Message-ID: <20110418100131.GD8925@tiehlicka.suse.cz>
References: <20110415135144.GE8828@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1104171952040.22679@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1104171952040.22679@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Sun 17-04-11 20:00:17, Hugh Dickins wrote:
> On Fri, 14 Apr 2011, Michal Hocko wrote:
[...]
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 692dbae..765cf4e 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1498,8 +1498,10 @@ unsigned long ra_submit(struct file_ra_state *ra,
> >  extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
> >  #if VM_GROWSUP
> >  extern int expand_upwards(struct vm_area_struct *vma, unsigned long address);
> > +  #define expand_downwards(vma, address) do { } while (0)
> 
> I think this is wrong: doesn't the VM_GROWSUP case actually want
> a real expand_downwards() in addition to expand_upwards()?

Ahh, right you are. I haven't noticed that we have
expand_stack_downwards as well and this one is called from get_arg_page
if CONFIG_STACK_GROWSUP. 

I am wondering why we do this just for CONFIG_STACK_GROWSUP. Do we
expand stack for GROWSDOWN automatically?

> 
> >  #else
> >    #define expand_upwards(vma, address) do { } while (0)
> > +extern int expand_downwards(struct vm_area_struct *vma, unsigned long address);
> >  #endif
> >  extern int expand_stack_downwards(struct vm_area_struct *vma,
> >  				  unsigned long address);
> 
> And if you're going for symmetry, wouldn't it be nice to add fs/exec.c
> to the patch and remove this silly expand_stack_downwards() wrapper?

Sounds reasonable. Thanks for the review, Hugh. I am also thinking
whether expand_stack_{downwards,upwards} is more suitable name for those
functions as we are more explicit that this is stack related.

What about the updated patch bellow?

Changes since v1
 - fixed expand_downwards case for CONFIG_STACK_GROWSUP in get_arg_page.
 - rename expand_{downwards,upwards} -> expand_stack_{downwards,upwards}
---
