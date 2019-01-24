Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Thu, 24 Jan 2019 01:24:55 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190124002455.GA23181@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm>
 <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jikos@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote on Thu, Jan 24, 2019:
> I've reverted the 'let's try to just remove the code' part in my tree.
> But I didn't apply the two other patches yet. Any final comments
> before that should happen?

I mentionned when sending the updated version that just checking file
permission might not be enough, e.g. a git tree is full of read-only
objects that someone might want to preload and think we might really
want to check both despite the overhead in the denied case.

Josh agreed and I meant to send a new version since nothing was
happening but work priorities got the better of me, and I was kind of
waiting for the ltp testcases[1] as well because aside from the few
tests I ran by hand I'm not sure the few hours of ltp/xfstests Jiri ran
did much but this is probably going to be a chicken-or-egg problem..

[1] https://github.com/linux-test-project/ltp/issues/461

Jiri Kosina wrote on Thu, Jan 24, 2019:
> On Thu, 24 Jan 2019, Linus Torvalds wrote:
> 
> > Side note: the inode_permission() addition to can_do_mincore() in that
> > patch 0002, seems to be questionable. We do
> > 
> > +static inline bool can_do_mincore(struct vm_area_struct *vma)
> > +{
> > +       return vma_is_anonymous(vma)
> > +               || (vma->vm_file && (vma->vm_file->f_mode & FMODE_WRITE))
> > +               || inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;
> > +}
> > 
> > note how it tests whether vma->vm_file is NULL for the FMODE_WRITE
> > test, but not for the inode_permission() test.
> > 
> > So either we test unnecessarily in the second line, or we don't
> > properly test it in the third one.
> > 
> > I think the "test vm_file" thing may be unnecessary, because a
> > non-anonymous mapping should always have a file pointer and an inode.
> > But I could  imagine some odd case (vdso mapping, anyone?) that
> > doesn't have a vm_file, but also isn't anonymous.
> 
> Hmm, good point.
> 
> So dropping the 'vma->vm_file' test and checking whether given vma is 
> special mapping should hopefully provide the desired semantics, shouldn't 
> it?

I think it's probably better to keep this simple, if we're going to
check something before accessing vm_file we might as well directly check
it.

I was thinking of something along the lines of:
	return vma_is_anonymous(vma) || (vma->vm_file &&
			(inode_owner_or_capable(file_inode(vma->vm_file))
			 || inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0));

I dropped the first f_mode check because none of the known mincore users
open the files read-write, and the check is redundant with
inode_permission() so while it would probably be an optimisation in some
cases I do not think it is useful in practice.
On the other hand, I have no idea how expensive the inode_permission and
owner checks really are - do they try to refresh attributes on a
networked filesystem or would it trust the cache or is it fs dependant?

Honestly this is more a case of "the people who's be interested in
seeing this have no idea what they're doing" than lack of interest.. I
wouldn't mind if there were tests doing mincore on a bunch of special
files/mappings but I just tried on a few regular files by hand, this
isn't proper coverage; I'll try to take more time to test various
mappings today (JST).


Thanks,
-- 
Dominique
