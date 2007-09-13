Date: Thu, 13 Sep 2007 11:18:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 3/5] Mem Policy:  MPOL_PREFERRED fixups for "local
 allocation"
In-Reply-To: <1189691488.5013.36.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709131113230.9378@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <20070830185114.22619.61260.sendpatchset@localhost>  <1189537099.32731.92.camel@localhost>
 <1189535671.5036.71.camel@localhost>  <Pine.LNX.4.64.0709121507170.3835@schroedinger.engr.sgi.com>
 <1189691488.5013.36.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007, Lee Schermerhorn wrote:

> > How does this sync with the nodemasks used by other policies? So far we 
> > are using a sort of cpuset agnostic nodeset and limit it when it is 
> > applied. 
> 
> Not exactly:  set_mempolicy() calls "contextualize_policy()" that
> returns an error if the nodemask is not a subset of mems_allowed; and
> then calls mpol_check_policy() to further vet the syscall args.
> 
> Now, I see that sys_mbind() does just AND the nodemask with
> mems_allowed.  So, it won't give an error.

Correct.

> Should these be the same?  If so, which way:  error or silently mask off
> dis-allowed nodes?  The latter doesn't let the user know what's going
> on, but with my new MPOL_F_MEMS_ALLOWED flag, a user can query the
> allowed nodes.  And, I can update the man pages to state exactly what
> happens.  So, how about:

I think an error is better. However, the use of MPOL_F_MEMS_ALLOWED may 
race with process migration. The mems allowed are not reliable in that 
sense. If the process stores information about allowable nodes then the 
process must have some way to be notified that the underlying nodes are 
changing for page migration. Otherwise the process may start trying to
allocate from nodes that it is no longer allowed to get memory from.

That is another reason why we have considered relative nodemasks in the 
past. If its relative to mems_allowed then the mems_allowed can change 
without the process having to change the nodemasks that it may have 
stored.

> > I think the integration between cpuset and memory policies could 
> > use some work and this is certainly something valid to do. Is there any 
> > way to describe that and have output that clarifies that distinction and 
> > helps the user figure out what is going on?
> 
> Man pages can/will be updated and the ability to query allowed nodes
> should provide the necessary info.  Would this satisfy your concern?

I have no concern about the manpages. You are doing an excellent job. I am 
worried about the consistency of the API and breakage that may be 
introduced because of partially relative and partially absolute nodemasks 
in use. The F_MEMS_ALLOWED needs to have a big warning in the manpage that 
the allowed nodemask may change at any time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
