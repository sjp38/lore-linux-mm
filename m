Date: Mon, 4 Jun 2007 14:51:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <200706042223.41681.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0706041444010.26764@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost> <1180976571.5055.24.camel@localhost>
 <Pine.LNX.4.64.0706041003040.23603@schroedinger.engr.sgi.com>
 <200706042223.41681.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Gleb Natapov <glebn@voltaire.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jun 2007, Andi Kleen wrote:

> > The other issues will still remain! This is a fundamental change to the
> > nature of memory policies. They are no longer under the control of the
> > task but imposed from the outside. 
> 
> To be fair this can already happen with tmpfs (and hopefully soon hugetlbfs
> again -- i plan to do some other work there anyways and will put 
> that in too) . But with first touch it is relatively benign.

Well this is pretty restricted for now so the control issues are not that
much of a problem. Both are special areas of memory that only see limited 
use.

But in general the association of memory policies with files is not that 
clean and it would be best to avoid things like that unless we first clean 
up the semantics.
 
> > If one wants to do this then the whole 
> > scheme of memory policies needs to be reworked and rethought in order to
> > be consistent and usable. For example you would need the ability to clear
> > a memory policy.
> 
> That's just setting it to default.

Default does not allow to distinguish between no memory policy set and 
the node local policy. This becomes important if you need to arbitrate 
multiple processes setting competing memory policies on a file page range. 
Right now we are ducking issues here it seems. If a process with higher 
rights sets the node local policy then another process with lower right 
should not be able to change that etc.

> Frankly I think this whole discussion is quite useless without discussing 
> concrete use cases. So far I haven't heard any where this any file policy
> would be a great improvement. Any further complication of the code which
> is already quite complex needs a very good rationale.

In general I agree (we have now operated for years with the current 
mempolicy semantics and I am concerned about any changes causing churn for 
our customers) but there is also the consistency issue. Memory policies do 
not work in mmapped page cache ranges which is surprising and not 
documented.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
