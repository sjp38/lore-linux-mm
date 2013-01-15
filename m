Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id D6DA16B0069
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 13:46:25 -0500 (EST)
Date: Tue, 15 Jan 2013 19:46:15 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: mmotm 2013-01-11-15-47 (trouble starting kvm)
In-Reply-To: <50F18594.7070004@iskon.hr>
Message-ID: <alpine.LRH.2.00.1301151943390.32259@twin.jikos.cz>
References: <20130111234813.170A620004E@hpza10.eem.corp.google.com> <50F18594.7070004@iskon.hr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Sat, 12 Jan 2013, Zlatko Calusic wrote:

> > A git tree which contains the memory management portion of this tree is
> > maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> > by Michal Hocko.  It contains the patches which are between the
> 
> The last commit I see in this tree is:
> 
> commit a0d271cbfed1dd50278c6b06bead3d00ba0a88f9
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Sun Sep 30 16:47:46 2012 -0700
> 
>     Linux 3.6
> 
> Is it dead? Or am I doing something wrong?
> 
> > A full copy of the full kernel tree with the linux-next and mmotm patches
> > already applied is available through git within an hour of the mmotm
> > release.  Individual mmotm releases are tagged.  The master branch always
> > points to the latest release, so it's constantly rebasing.
> > 
> > http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary
> > 
> > This mmotm tree contains the following patches against 3.8-rc3:
> > (patches marked "*" will be included in linux-next)
> > 
> > * lockdep-rwsem-provide-down_write_nest_lock.patch
> > * mm-mmap-annotate-vm_lock_anon_vma-locking-properly-for-lockdep.patch
> 
> Had to revert the above two patches to start KVM (win7) successfully.
> Otherwise it would livelock on some semaphore, it seems. Couldn't kill it, ps
> output would stuck, even reboot didn't work (had to use SysRQ).

Copy/pasting from my response to the other thread at 
https://lkml.org/lkml/2013/1/15/440


====
Thorough and careful review and analysis revealed that the rootcause very 
likely is that I am a complete nitwit.

Could you please try the patch below and report backt? Thanks.



From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] lockdep, rwsem: fix down_write_nest_lock() if !CONFIG_DEBUG_LOCK_ALLOC

Commit 1b963c81b1 ("lockdep, rwsem: provide down_write_nest_lock()") 
contains a bug in a codepath when CONFIG_DEBUG_LOCK_ALLOC is disabled, 
which causes down_read() to be called instead of down_write() by mistake 
on such configurations. Fix that.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 include/linux/rwsem.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index 413cc11..8da67d6 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -135,7 +135,7 @@ do {								\
 
 #else
 # define down_read_nested(sem, subclass)		down_read(sem)
-# define down_write_nest_lock(sem, nest_lock)	down_read(sem)
+# define down_write_nest_lock(sem, nest_lock)	down_write(sem)
 # define down_write_nested(sem, subclass)	down_write(sem)
 #endif
 
-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
