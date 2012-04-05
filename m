Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 80C6C6B0083
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 17:45:11 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <matthltc@us.ibm.com>;
	Thu, 5 Apr 2012 15:45:10 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id BE41A1FF0038
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 15:45:07 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q35LioJZ102918
	for <linux-mm@kvack.org>; Thu, 5 Apr 2012 15:44:51 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q35LioIk031525
	for <linux-mm@kvack.org>; Thu, 5 Apr 2012 15:44:50 -0600
Date: Thu, 5 Apr 2012 14:44:47 -0700
From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-ID: <20120405214447.GC7761@count0.beaverton.ibm.com>
References: <20120331091049.19373.28994.stgit@zurg>
 <20120331092929.19920.54540.stgit@zurg>
 <20120331201324.GA17565@redhat.com>
 <20120402230423.GB32299@count0.beaverton.ibm.com>
 <4F7A863C.5020407@openvz.org>
 <20120403181631.GD32299@count0.beaverton.ibm.com>
 <20120403193204.GE3370@moon>
 <20120405202904.GB7761@count0.beaverton.ibm.com>
 <4F7E08EB.5070600@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F7E08EB.5070600@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Matt Helsley <matthltc@us.ibm.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "oprofile-list@lists.sf.net" <oprofile-list@lists.sf.net>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

On Fri, Apr 06, 2012 at 01:04:43AM +0400, Konstantin Khlebnikov wrote:
> Matt Helsley wrote:
> >On Tue, Apr 03, 2012 at 11:32:04PM +0400, Cyrill Gorcunov wrote:
> >>On Tue, Apr 03, 2012 at 11:16:31AM -0700, Matt Helsley wrote:
> >>>On Tue, Apr 03, 2012 at 09:10:20AM +0400, Konstantin Khlebnikov wrote:
> >>>>Matt Helsley wrote:
> >>>>>On Sat, Mar 31, 2012 at 10:13:24PM +0200, Oleg Nesterov wrote:
> >>>>>>On 03/31, Konstantin Khlebnikov wrote:
> >>>>>>>
> >>>>>>>comment from v2.6.25-6245-g925d1c4 ("procfs task exe symlink"),
> >>>>>>>where all this stuff was introduced:
> >>>>>>>
> >>>>>>>>...
> >>>>>>>>This avoids pinning the mounted filesystem.
> >>>>>>>
> >>>>>>>So, this logic is hooked into every file mmap/unmmap and vma split/merge just to
> >>>>>>>fix some hypothetical pinning fs from umounting by mm which already unmapped all
> >>>>>>>its executable files, but still alive. Does anyone know any real world example?
> >>>>>>
> >>>>>>This is the question to Matt.
> >>>>>
> >>>>>This is where I got the scenario:
> >>>>>
> >>>>>https://lkml.org/lkml/2007/7/12/398
> >>>>
> >>>>Cyrill Gogcunov's patch "c/r: prctl: add ability to set new mm_struct::exe_file"
> >>>>gives userspace ability to unpin vfsmount explicitly.
> >>>
> >>>Doesn't that break the semantics of the kernel ABI?
> >>
> >>Which one? exe_file can be changed iif there is no MAP_EXECUTABLE left.
> >>Still, once assigned (via this prctl) the mm_struct::exe_file can't be changed
> >>again, until program exit.
> >
> >The prctl() interface itself is fine as it stands now.
> >
> >As far as I can tell Konstantin is proposing that we remove the unusual
> >counter that tracks the number of mappings of the exe_file and require
> >userspace use the prctl() to drop the last reference. That's what I think
> >will break the ABI because after that change you *must* change userspace
> >code to use the prctl(). It's an ABI change because the same sequence of
> >system calls with the same input bits produces different behavior.
> 
> But common software does not require this at all. I did not found real examples,
> only hypothesis by Al Viro: https://lkml.org/lkml/2007/7/12/398
> libhugetlbfs isn't good example too, the man proc says: /proc/[pid]/exe is alive until
> main thread is alive, but in case libhugetlbfs /proc/[pid]/exe disappears too early.

*shrug*

Where did you look for real examples? chroot? pivot_root? various initrd
systems? Which versions?

This sort of argument brings up classic questions. How do we know when
to stop looking given the incredible amount of obscure code that's out
there -- most of which we're unlikely to even be aware of? Even if we
only look at "popular" distros how far back do we go? etc.

Perhaps before going through all that effort it would be better to
verify that removing that code impacts performance enough to care. Do
you have numbers? If the numbers aren't there then why bother with
exhaustive and exhausting code searches?

>
> Also I would not call it ABI, this corner-case isn't documented, I'm afraid only few
> people in the world knows about it =)

I don't think the definition of an ABI is whether there's documentation
for it. It's whether the interface is used or not. At least that's the
impression I've gotten from reading Linus' rants over the years.

I think of the ABI as bits input versus behavior (including bits) out. If
the input bits remain the same the qualitative behavior should remain the
same unless there is a bug. Here, roughly speaking, the input bits are the
arguments passed to a sequence of one or more munmap() calls followed by a
umount(). The output is a 0 return value from the umount. Your proposal
would change that output value to -1 -- different bits and different
behavior.

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
