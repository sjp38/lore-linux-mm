Subject: Re: Query re:  mempolicy for page cache pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200605182012.19570.ak@suse.de>
References: <1147974599.5195.96.camel@localhost.localdomain>
	 <200605182012.19570.ak@suse.de>
Content-Type: text/plain
Date: Thu, 18 May 2006 14:29:53 -0400
Message-Id: <1147976994.5195.123.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Steve Longerbeam <stevel@mvista.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Thanks, Andi

On Thu, 2006-05-18 at 20:12 +0200, Andi Kleen wrote:
> > 1) What ever happened to Steve's patch set?
> 
> It needed more work, but he just disappeared at some point.

OK.

> > 
> > 2) Is this even a problem that needs solving, as Christoph seem to think
> > at one time?
> 
> The problem that hasn't been worked out is how to add persistent 
> attributes to files. Steve avoided that by limiting his to only
> ELF executables and using a static header there, but i'm not
> sure that is a generally useful enough for mainline. Just temporary
> for mmaps seems very narrow in usefulness.
> 
> And with xattrs was unclear if it would be costly or not and
> even worth it.

I see...  Still, I find it "interesting" that an app doesn't have
explicit control over shared file mappings except via the process
policy.  I suppose if one applies explicit policy to all ones 
vmas, then by process of elimination, the process policy would
only apply to is file mappings.

> 
> At least in the general case just interleaving the file cache
> based on a global setting or on cpuset seemed to work well enough
> for most people.

Yes, for not overburdening any single node.  Paul Jackson's 
"spread" patches address this.  Actually, for [some of] our platforms,
we can hardware interleave some % of memory at the cache line level.
This shows up as a memory-only node.  Some folks claim it would be
beneficial to be able to specify a page cache policy to prefer this
hardware interleaved node for the page cache.   I see that Ray
Bryant once proposed a patch to define a separate global and 
optional per process policy to be used for page cache pages. This
also "died on the vine"...

> 
> Let's ask it differently. Do you have a real application that
> would be improved by it? 

Uh, not at this point.  As I said, Chistoph said he "wished this were
addressed" before thinking about migrate-on-fault, etc.  Since I wasn't
getting any traction with the migration stuff, and this didn't look to
difficult, I thought I'd look into it.
> 
> 
> > 2) As with shmem segments, the shared policies applied to shared
> >    file mappings persist as long as the inode remains--i.e., until
> >    the file is deleted or the inode recycled--whether or not any
> >    task has the file mapped or even open.  We could, I suppose,
> >    free the map on last close.
> 
> The recycling is the problem. It's basically a lottery if the
> attributes are kept with high memory pressure or not.
> Doesn't seem like a robust approach.

Unless, of course, the file remains mapped/open, right?  Then isn't 
the inode and address_space guaranteed to hang around?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
