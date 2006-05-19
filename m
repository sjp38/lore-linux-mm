Date: Fri, 19 May 2006 16:45:39 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC 4/5] page migration: Support moving of individual pages
Message-Id: <20060519164539.401a8eec.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605191603110.26870@schroedinger.engr.sgi.com>
References: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
	<20060518182131.20734.27190.sendpatchset@schroedinger.engr.sgi.com>
	<20060519122757.4b4767b3.akpm@osdl.org>
	<Pine.LNX.4.64.0605191603110.26870@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, bls@sgi.com, jes@sgi.com, lee.schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, mtk-manpages@gmx.net
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Fri, 19 May 2006, Andrew Morton wrote:
> 
> > > Possible page states:
> > > 
> > > 0..MAX_NUMNODES		The page is now on the indicated node.
> > > 
> > > -ENOENT		Page is not present or target node is not present
> > 
> > So the caller has no way of distinguishing one case from the other? 
> > Perhaps it would be better to permit that.
> 
> But then we would not follow the meaning of the -Exx codes?

If we're returning this fine-grained info back to userspace (good) then we
should go all the way.  If that's hard to do with the current
map-it-onto-existing-errnos approach then we've hit the limits of that
approach.

> > But it still feels a bit kludgy to me.  Perhaps it would be nicer to define
> > a specific set of return codes for this application.
> 
> The -Exx cocdes are in use thoughout the migration code for error 
> conditions. We could do another pass through all of this and define 
> specific error codes for page migration alone?

They're syscall return codes, not page-migration-per-page-result codes.

I'd have thought that would produce a cleaner result, really.  I don't know
how much impact that would have from a back-compatibility POV though.

> > > Test program for this may be found with the patches
> > > on ftp.kernel.org:/pub/linux/kernel/people/christoph/pmig/patches-2.6.17-rc4-mm1
> > 
> > The syscall is ia64-only at present.  And that's OK, but if anyone has an
> > interest in page migration on other architectures (damn well hope so) then
> > let's hope they wire the syscall up and get onto it..
> 
> Well I expecteed a longer discussion on how to do this, why are we doing 
> it this way etc etc before the patch got in and before I would have to 
> polish it up for prime time. Hopefully this whole thing does not become 
> too volatile.

The patches looked fairly straightforward to me.  Maybe I missed something ;)

> You are keeping this separate from the other material that 
> is intended for 2.6.18 right?

yup.

> > > +			const int __user *nodes,
> > > +			int __user *status, int flags)
> > > +{
> > 
> > I expect this is going to be a bitch to write compat emulation for.  If we
> > want to support this syscall for 32-bit userspace.
> 
> Page migration on a 32 bit platform? Do we really need that?

sys_migrate_pages is presently wired up in the x86 syscall table.  And it's
available in x86_64's 32-bit mode.

> > If there's any possibility of that then perhaps we should revisit these
> > types, see if we can design this syscall so that it doesn't need a compat
> > wrapper.
> > 
> > The `status' array should be char*, surely?
> 
> Could be. But then its an integer status and not a character so I thought 
> that an int would be cleaner.

As it's just a status result it's hard to see that we'd ever need more
bits.  Might as well get the speed and space savings of using a char?

> > > +	/*
> > > +	 * Check if this process has the right to modify the specified
> > > +	 * process. The right exists if the process has administrative
> > > +	 * capabilities, superuser privileges or the same
> > > +	 * userid as the target process.
> > > +	 */
> > > +	if ((current->euid != task->suid) && (current->euid != task->uid) &&
> > > +	    (current->uid != task->suid) && (current->uid != task->uid) &&
> > > +	    !capable(CAP_SYS_NICE)) {
> > > +		err = -EPERM;
> > > +		goto out2;
> > > +	}
> > 
> > We have code which looks very much like this in maybe five or more places. 
> > Someone should fix it ;)
> 
> hmmm. yes this seems to be duplicated quite a bit.
> 
> > > +	task_nodes = cpuset_mems_allowed(task);
> > > +	pm = kmalloc(GFP_KERNEL, (nr_pages + 1) * sizeof(struct page_to_node));
> > 
> > A horrid bug.  If userspace passes in a sufficiently large nr_pages, the
> > multiplication will overflow and we'll allocate far too little memory and
> > we'll proceed to scrog kernel memory.
> 
> nr_pages is a 32 bit entity. On a 64 bit platform it will be difficult to 
> overflow the result. So we only have an issue if we support move_pages() 
> on 32 bit.

nr_pages is declared as unsigned long.

> > (OK, that's what would happen if you'd got the kmalloc args the correct way
> > around.  As it stands, heaven knows what it'll do ;))
> 
> It survived the test (ROTFL). But why did we add this gfp_t type if it 
> does not cause the compiler to spit out a warning? We only get a warning 
> with sparse checking?
> 
> > > +		err = -EFAULT;
> > > +		if (get_user(addr, pages + i))
> > > +			goto putback;
> > 
> > No, we cannot run get_user() inside down_read(mmap_sem).  Because that ends
> > up taking mmap_sem recursively and an intervening down_write() from another
> > process will deadlock the kernel.
> 
> Ok. Will fix the numerous bugs next week unless there are more concerns on 
> a basic conceptual level.

Who else is interested in these features apart from the high-end ia64
people?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
