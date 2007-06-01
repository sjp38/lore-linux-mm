Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200706011221.33062.ak@suse.de>
References: <1180467234.5067.52.camel@localhost>
	 <200705312243.20242.ak@suse.de> <20070601093803.GE10459@minantech.com>
	 <200706011221.33062.ak@suse.de>
Content-Type: text/plain
Date: Fri, 01 Jun 2007 13:15:06 -0400
Message-Id: <1180718106.5278.28.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Gleb Natapov <glebn@voltaire.com>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-01 at 12:21 +0200, Andi Kleen wrote:
> On Friday 01 June 2007 11:38:03 Gleb Natapov wrote:
> > On Thu, May 31, 2007 at 10:43:19PM +0200, Andi Kleen wrote:
> > > 
> > > > > > Do I
> > > > > > miss something here?
> > > > > 
> > > > > I think you do.  
> > > > OK. It seems I missed the fact that VMA policy is completely ignored for
> > > > pagecache backed files and only task policy is used. 
> > > 
> > > That's not correct. tmpfs is page cache backed and supports (even shared) VMA policy.
> > > hugetlbfs used to too, but lost its ability, but will hopefully get it again.
> > > 
> > This is even more confusing.
> 
> I see. Anything that doesn't work exactly as your particular 
> application expects it is "unnatural" and "confusing". I suppose only
> in Glebnix it would be different.

Andi, as you well know, many Posix-like systems have had NUMA policies
for quite a while.  Most of these systems tried to provide consistent
semantics from the applications view point with respect to control of
policy of memory objects mapped into the application's address space.
It's not particularly difficult to achieve.  Your shared policy
infrastructure provides almost everything that's required, as I've
demonstrated.

Like Gleb, I find the different behaviors for different memory regions
to be unnatural.  Not because of the fraction of applications or
deployments that might use them, but because [speaking for customers] I
expect and want to be able to control placement of any object mapped
into an application's address space, subject to permissions and
privileges.

> 
> > So numa_*_memory() works different 
> > depending on where file is created.
> 
> See it as "it doesn't work for files, but only for shared memory".
> The main reason for that is that there is no way to make it persistent
> for files.

Your definition of persistence seems to be keeping policy around on
files when the application that owns the file doesn't have it open or
mapped.  In the context of my customers' applications and, AFAICT,
Gleb's application, your definition of persistence is a red herring.
You're using it to prevent acceptance of behavior we need because the
patches don't address your definition.  From what I can tell from the
discussion so far, YOU don't have a need [or know of anyone who does]
for your definition of persistence.  You claim you don't know of any use
case for memory policy on memory mapped file at all.  

If you do know of a need for file policy persistence at least as good as
shmem--i.e., doesn't survive reboot--that could be added relatively
easily.  But you haven't asked for that.  You've rejected the notion
that anyone might have a need for policy on memory mapped files without
such persistence.  If you want persistence across reboots--i.e.,
attached to the file as some sort of extended attribue--I expect that
could be done, as well.  But, that's a file system issue and, IMO,
mbind() is not the right interface.  However, such a feature would
require the kernel to support policies on regular disk-backed files as
it does for swap-backed files.

> 
> I only objected to your page cache based description because tmpfs
> (and even anonymous memory) are page cache based too.

Then why does Christoph keep insisting that "page cache pages" must
always follow task policy, when shmem, tmpfs and anonymous pages don't
have to?

> 
> > I can't rely on this anyway and 
> > have to assume that numa_*_memory() call is ignored and prefault.
> 
> It's either use shared/anonymous memory or process policy.
> 
> > I think Lee's patches should be applied ASAP to fix this inconsistency.
> 
> They have serious semantic problems.

Which, except for your persistence red herring, you haven't described.

Go back to my message to Gleb where I described the semantics provided
by my patches and show me where your problems are.  And tell us YOUR use
cases for YOUR definition of persistence that you claim is missing.
They must be very compelling if they're worth blocking a capability that
others want to use.

Regards,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
