Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Thu, 24 Jan 2019 13:45:01 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190124124501.GA18012@nautica>
References: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm>
 <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
 <20190124002455.GA23181@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190124002455.GA23181@nautica>
Sender: linux-kernel-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jikos@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Dominique Martinet wrote on Thu, Jan 24, 2019:
> I was thinking of something along the lines of:
> 	return vma_is_anonymous(vma) || (vma->vm_file &&
> 			(inode_owner_or_capable(file_inode(vma->vm_file))
> 			 || inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0));
> 
> I dropped the first f_mode check because none of the known mincore users
> open the files read-write, and the check is redundant with
> inode_permission() so while it would probably be an optimisation in some
> cases I do not think it is useful in practice.
> On the other hand, I have no idea how expensive the inode_permission and
> owner checks really are - do they try to refresh attributes on a
> networked filesystem or would it trust the cache or is it fs dependant?
> 
> Honestly this is more a case of "the people who's be interested in
> seeing this have no idea what they're doing" than lack of interest.. I
> wouldn't mind if there were tests doing mincore on a bunch of special
> files/mappings but I just tried on a few regular files by hand, this
> isn't proper coverage; I'll try to take more time to test various
> mappings today (JST).

I've done some tests with this, it appears OK.

Obviously the tests I previously had done still work:
 - user's own files are ok, even if read-only now.
 - non-user writable files are ok.
 - non-user non-writable files (e.g. system libs) aren't.
 - root can still do anything.

On new tests:
 - there are vmas with no file that aren't anonymous and come all the
way there (vvar and vdso), so factoring vma->vm_file check is definitely
needed.
 - vsyscall doesn't reach can_do_mincore()
 - [heap] [stack] and other fileless regular maps are anonymous

 - I tried a char device (/dev/zero) and it was marked anonymous despite
mapping with MAP_SHARED, which is somewhat expected I guess?
 - I couldn't map /proc or /sys files (no such device), so no mincore
there.


I'd post my test program but I actually added pr_info messages in
can_do_mincore to check what it returned because madvise dontneed isn't
guaranteed to evict pages so we can't rely on madvise dontneed + mincore
to return 0; not sure what to do for ltp... If anyone has a good idea of
how to check if mincore actually got granted permissions without
drop_caches I'll post to the ltp github.


Anything else to try?

Jiri, you've offered resubmitting the last two patches properly, can you
incorporate this change or should I just send this directly? (I'd take
most of your commit message and add your name somewhere)


Thanks,
-- 
Dominique
