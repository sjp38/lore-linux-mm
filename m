Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3E01D6B004D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 16:21:43 -0400 (EDT)
Date: Thu, 2 Apr 2009 13:18:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] don't show pgoff of vma if vma is pure ANON (was
 Re: mmotm 2009-01-12-16-53 uploaded)
Message-Id: <20090402131816.54724d4e.akpm@linux-foundation.org>
In-Reply-To: <20090115114312.e42a0dba.kamezawa.hiroyu@jp.fujitsu.com>
References: <200901130053.n0D0rhev023334@imap1.linux-foundation.org>
	<20090113181317.48e910af.kamezawa.hiroyu@jp.fujitsu.com>
	<496CC9D8.6040909@google.com>
	<20090114162245.923c4caf.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0901141349410.5465@blonde.anvils>
	<20090115114312.e42a0dba.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: hugh@veritas.com, mikew@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, yinghan@google.com
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 11:43:12 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 14 Jan 2009 14:08:35 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > On Wed, 14 Jan 2009, KAMEZAWA Hiroyuki wrote:
> > > Hmm, is this brutal ?
> > > 
> > > ==
> > > Recently, it's argued that what proc/pid/maps shows is ugly when a
> > > 32bit binary runs on 64bit host.
> > > 
> > > /proc/pid/maps outputs vma's pgoff member but vma->pgoff is of no use
> > > information is the vma is for ANON.
> > > By this patch, /proc/pid/maps shows just 0 if no file backing store.
> > > 
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > ---
> > 
> > Brutal, but sensible enough: revert to how things looked before
> > we ever starting putting vm_pgoff to work on anonymous areas.
> > 
> > I slightly regret losing that visible clue to whether an anonymous
> > vma has ever been mremap moved.  But have I ever actually used that
> > info?  No, never.
> > 
> > I presume you test !vma->vm_file so the lines fit in, fair enough.
> > But I think you'll find checkpatch.pl protests at "(!vma->vm_file)?"
> > 
> > I dislike its decisions on the punctuation of the ternary operator
> > - perhaps even more than Andrew dislikes the operator itself!
> > Do we write a space before a question mark? no: nor before a colon;
> > but I also dislike getting into checkpatch.pl arguments!
> > 
> > While you're there, I'd also be inclined to make task_nommu.c
> > use the same loff_t cast as task_mmu.c is using.
> > 
> Ok, I'll try to update to reasonable style.
> 

afaik this update never happened?

Here's what I have at present:

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Recently, it's argued that what proc/pid/maps shows is ugly when a 32bit
binary runs on 64bit host.

/proc/pid/maps outputs vma's pgoff member but vma->pgoff is of no use
information is the vma is for ANON.  With this patch, /proc/pid/maps shows
just 0 if no file backing store.

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mike Waychison <mikew@google.com>
Reported-by: Ying Han <yinghan@google.com>
Cc: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/proc/task_mmu.c   |    3 ++-
 fs/proc/task_nommu.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff -puN fs/proc/task_mmu.c~proc-pid-maps-dont-show-pgoff-of-pure-anon-vmas fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~proc-pid-maps-dont-show-pgoff-of-pure-anon-vmas
+++ a/fs/proc/task_mmu.c
@@ -220,7 +220,8 @@ static void show_map_vma(struct seq_file
 			flags & VM_WRITE ? 'w' : '-',
 			flags & VM_EXEC ? 'x' : '-',
 			flags & VM_MAYSHARE ? 's' : 'p',
-			((loff_t)vma->vm_pgoff) << PAGE_SHIFT,
+			(!vma->vm_file) ? 0 :
+				((loff_t)vma->vm_pgoff) << PAGE_SHIFT,
 			MAJOR(dev), MINOR(dev), ino, &len);
 
 	/*
diff -puN fs/proc/task_nommu.c~proc-pid-maps-dont-show-pgoff-of-pure-anon-vmas fs/proc/task_nommu.c
--- a/fs/proc/task_nommu.c~proc-pid-maps-dont-show-pgoff-of-pure-anon-vmas
+++ a/fs/proc/task_nommu.c
@@ -143,7 +143,8 @@ static int nommu_vma_show(struct seq_fil
 		   flags & VM_WRITE ? 'w' : '-',
 		   flags & VM_EXEC ? 'x' : '-',
 		   flags & VM_MAYSHARE ? flags & VM_SHARED ? 'S' : 's' : 'p',
-		   (unsigned long long) vma->vm_pgoff << PAGE_SHIFT,
+		   (!vma->vm_file) ? 0 :
+			(unsigned long long) vma->vm_pgoff << PAGE_SHIFT,
 		   MAJOR(dev), MINOR(dev), ino, &len);
 
 	if (file) {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
