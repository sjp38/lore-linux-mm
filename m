Date: Fri, 19 May 2006 17:46:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 4/5] page migration: Support moving of individual pages
In-Reply-To: <20060519164539.401a8eec.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0605191730370.27242@schroedinger.engr.sgi.com>
References: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
 <20060518182131.20734.27190.sendpatchset@schroedinger.engr.sgi.com>
 <20060519122757.4b4767b3.akpm@osdl.org> <Pine.LNX.4.64.0605191603110.26870@schroedinger.engr.sgi.com>
 <20060519164539.401a8eec.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, bls@sgi.com, jes@sgi.com, lee.schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, mtk-manpages@gmx.net
List-ID: <linux-mm.kvack.org>

On Fri, 19 May 2006, Andrew Morton wrote:

> If we're returning this fine-grained info back to userspace (good) then we
> should go all the way.  If that's hard to do with the current
> map-it-onto-existing-errnos approach then we've hit the limits of that
> approach.

I think the level of detail of -Exx is sufficient. I will have to precheck
the arguments passed before taking mmap sem in the next release. With that
some of the clashes can be removed and I could just f.e. return -ENOENT
if any invalid node was specified so that the -ENOENT page state is really
no page there.

> > The -Exx cocdes are in use thoughout the migration code for error 
> > conditions. We could do another pass through all of this and define 
> > specific error codes for page migration alone?
> 
> They're syscall return codes, not page-migration-per-page-result codes.
> 
> I'd have thought that would produce a cleaner result, really.  I don't know
> how much impact that would hav from a back-compatibility POV though.

I have used these thoughout the page migration code for error conditions 
on pages since we thought this would be a good way to avoid defining error
conditions for multiple function. Better try to keep it.

> > Well I expecteed a longer discussion on how to do this, why are we doing 
> > it this way etc etc before the patch got in and before I would have to 
> > polish it up for prime time. Hopefully this whole thing does not become 
> > too volatile.
> 
> The patches looked fairly straightforward to me.  Maybe I missed something ;)

Great! Will clean it up and do some more testing on it.

Brian: Could you give me some feedback on this one as well? Could you do
some testing with your framework for page migration?

> > Page migration on a 32 bit platform? Do we really need that?
> 
> sys_migrate_pages is presently wired up in the x86 syscall table.  And it's
> available in x86_64's 32-bit mode.

Ok. I will look at that.

> > Could be. But then its an integer status and not a character so I thought 
> > that an int would be cleaner.
> 
> As it's just a status result it's hard to see that we'd ever need more
> bits.  Might as well get the speed and space savings of using a char?

This is just a temporary value and (oh.... yes) we are going up to 4k
nodes right now and are still shooting for more. So the node number
wont fit into a char, lets keep it an int.

> > Ok. Will fix the numerous bugs next week unless there are more concerns on 
> > a basic conceptual level.
> 
> Who else is interested in these features apart from the high-end ia64
> people?

The usual I guess: PowerPC and x86_64(opteron) high end machines plus the 
i386 IBM NUMA machines. Is sparc64 now NUMA capable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
