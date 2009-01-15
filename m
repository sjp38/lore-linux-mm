Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0BE366B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 21:44:19 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F2iHsq029674
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 11:44:17 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 48BA22AEA81
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:44:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 15EF31EF082
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:44:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F1A21E08001
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:44:16 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A12C61DB8043
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:44:16 +0900 (JST)
Date: Thu, 15 Jan 2009 11:43:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] don't show pgoff of vma if vma is pure ANON (was
 Re: mmotm 2009-01-12-16-53 uploaded)
Message-Id: <20090115114312.e42a0dba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0901141349410.5465@blonde.anvils>
References: <200901130053.n0D0rhev023334@imap1.linux-foundation.org>
	<20090113181317.48e910af.kamezawa.hiroyu@jp.fujitsu.com>
	<496CC9D8.6040909@google.com>
	<20090114162245.923c4caf.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0901141349410.5465@blonde.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Mike Waychison <mikew@google.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, yinghan@google.com
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jan 2009 14:08:35 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> On Wed, 14 Jan 2009, KAMEZAWA Hiroyuki wrote:
> > Hmm, is this brutal ?
> > 
> > ==
> > Recently, it's argued that what proc/pid/maps shows is ugly when a
> > 32bit binary runs on 64bit host.
> > 
> > /proc/pid/maps outputs vma's pgoff member but vma->pgoff is of no use
> > information is the vma is for ANON.
> > By this patch, /proc/pid/maps shows just 0 if no file backing store.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> 
> Brutal, but sensible enough: revert to how things looked before
> we ever starting putting vm_pgoff to work on anonymous areas.
> 
> I slightly regret losing that visible clue to whether an anonymous
> vma has ever been mremap moved.  But have I ever actually used that
> info?  No, never.
> 
> I presume you test !vma->vm_file so the lines fit in, fair enough.
> But I think you'll find checkpatch.pl protests at "(!vma->vm_file)?"
> 
> I dislike its decisions on the punctuation of the ternary operator
> - perhaps even more than Andrew dislikes the operator itself!
> Do we write a space before a question mark? no: nor before a colon;
> but I also dislike getting into checkpatch.pl arguments!
> 
> While you're there, I'd also be inclined to make task_nommu.c
> use the same loff_t cast as task_mmu.c is using.
> 
Ok, I'll try to update to reasonable style.

Thanks,
-Kame


> Hugh
> 
> > Index: mmotm-2.6.29-Jan13/fs/proc/task_mmu.c
> > ===================================================================
> > --- mmotm-2.6.29-Jan13.orig/fs/proc/task_mmu.c
> > +++ mmotm-2.6.29-Jan13/fs/proc/task_mmu.c
> > @@ -220,7 +220,8 @@ static void show_map_vma(struct seq_file
> >  			flags & VM_WRITE ? 'w' : '-',
> >  			flags & VM_EXEC ? 'x' : '-',
> >  			flags & VM_MAYSHARE ? 's' : 'p',
> > -			((loff_t)vma->vm_pgoff) << PAGE_SHIFT,
> > +			(!vma->vm_file)? 0 :
> > +				((loff_t)vma->vm_pgoff) << PAGE_SHIFT,
> >  			MAJOR(dev), MINOR(dev), ino, &len);
> >  
> >  	/*
> > Index: mmotm-2.6.29-Jan13/fs/proc/task_nommu.c
> > ===================================================================
> > --- mmotm-2.6.29-Jan13.orig/fs/proc/task_nommu.c
> > +++ mmotm-2.6.29-Jan13/fs/proc/task_nommu.c
> > @@ -143,7 +143,8 @@ static int nommu_vma_show(struct seq_fil
> >  		   flags & VM_WRITE ? 'w' : '-',
> >  		   flags & VM_EXEC ? 'x' : '-',
> >  		   flags & VM_MAYSHARE ? flags & VM_SHARED ? 'S' : 's' : 'p',
> > -		   (unsigned long long) vma->vm_pgoff << PAGE_SHIFT,
> > +		   (!vma->vm_file) ? 0 :
> > +			(unsigned long long) vma->vm_pgoff << PAGE_SHIFT,
> >  		   MAJOR(dev), MINOR(dev), ino, &len);
> >  
> >  	if (file) {
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
