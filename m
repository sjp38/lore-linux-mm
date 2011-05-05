Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7036B0011
	for <linux-mm@kvack.org>; Thu,  5 May 2011 02:30:19 -0400 (EDT)
Date: Thu, 5 May 2011 08:30:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH resend] mm: get rid of CONFIG_STACK_GROWSUP || CONFIG_IA64
Message-ID: <20110505063012.GA11529@tiehlicka.suse.cz>
References: <20110503141044.GA25351@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1105031142260.7349@sister.anvils>
 <20110504083005.GA1375@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1105041016110.23159@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1105041016110.23159@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 04-05-11 10:28:36, Hugh Dickins wrote:
> On Wed, 4 May 2011, Michal Hocko wrote:
> > 
> > This case is obscure enough already because we are using VM_GROWSUP to
> > declare expand_stack_upwards in include/linux/mm.h
> 
> Ah yes, I didn't notice that it was already done that way there
> (closer to the definitions of VM_GROWSUP so not as bad).
> 
> > while definition is guarded by CONFIG_STACK_GROWSUP||CONFIG_IA64. 
> > What the patch does is just "make it consistent" thing. I think we
> > should at least use CONFIG_STACK_GROWSUP||CONFIG_IA64 at both places if
> > you do not like VM_GROWSUP misuse.
> 
> If it's worth changing anything, yes, that would be better.

I have looked into the history again and the current VM_GROWSUP usage
for the CONFIG_STACK_GROWSUP||CONFIG_IA64 has been introduced by
commit 8ca3eb08097f6839b2206e2242db4179aee3cfb3
Author: Luck, Tony <tony.luck@intel.com>
Date:   Tue Aug 24 11:44:18 2010 -0700

    guard page for stacks that grow upwards
    
    pa-risc and ia64 have stacks that grow upwards. Check that
    they do not run into other mappings. By making VM_GROWSUP
    0x0 on architectures that do not ever use it, we can avoid
    some unpleasant #ifdefs in check_stack_guard_page().
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

So I think the flag should be used that way. If we ever going to add a
new architecture like IA64 which uses both ways of expanding we should
make it easier by minimizing the places which have to be examined.

> > > Not a nack: others may well disagree with me.
> > > 
> > > And, though I didn't find time to comment on your later "symmetrical"
> > > patch before it went into mmotm, I didn't see how renaming expand_downwards
> > > and expand_upwards to expand_stack_downwards and expand_stack_upwards was
> > > helpful either - needless change, and you end up using expand_stack_upwards
> > > on something which is not (what we usually call) the stack.
> > 
> > OK, I see your point. expand_stack_upwards in ia64_do_page_fault can be
> > confusing as well. Maybe if we stick with the original expand_upwards
> > and just make expand_downwards symmetrical without renameing to
> > "_stack_" like the patch does? I can rework that patch if there is an
> > interest. I would like to have it symmetrical, though, because the
> > original code was rather confusing.
> 
> Yes, what I suggested before was an expand_upwards, an expand_downwards
> and an expand_stack (with mod to fs/exec.c to replace its call to
> expand_stack_downwards by direct call to expand_downwards).

OK, now, with the cleanup patch, we have expand_stack and
expand_stack_{downwards,upwards}. I will repost the patch to Andrew with
up and down cases renamed. Does it work for you?

> But it's always going to be somewhat confusing and asymmetrical
> because of the ia64 register backing store case.

How come? We would have expand_stack which is pretty much clear that it
is expanding stack in the architecture specific way. And then we would
have expand_{upwards,downward} which are clear about way how we expand
whatever VMA, right?
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
