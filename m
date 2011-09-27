Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BAF8D9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 08:47:58 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8RCloUE006583
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 06:47:50 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8RCllH6077640
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 06:47:48 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8RCliUp022634
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 06:47:46 -0600
Date: Tue, 27 Sep 2011 18:02:25 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 18/26]   uprobes: slot allocation.
Message-ID: <20110927123225.GC15435@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
 <1317124177.15383.46.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1317124177.15383.46.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Stephen Smalley <sds@tycho.nsa.gov>, LKML <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>

* Peter Zijlstra <peterz@infradead.org> [2011-09-27 13:49:37]:

> On Tue, 2011-09-20 at 17:33 +0530, Srikar Dronamraju wrote:
> > +static int xol_add_vma(struct uprobes_xol_area *area)
> > +{
> > +       const struct cred *curr_cred;
> > +       struct vm_area_struct *vma;
> > +       struct mm_struct *mm;
> > +       unsigned long addr;
> > +       int ret = -ENOMEM;
> > +
> > +       mm = get_task_mm(current);
> > +       if (!mm)
> > +               return -ESRCH;
> > +
> > +       down_write(&mm->mmap_sem);
> > +       if (mm->uprobes_xol_area) {
> > +               ret = -EALREADY;
> > +               goto fail;
> > +       }
> > +
> > +       /*
> > +        * Find the end of the top mapping and skip a page.
> > +        * If there is no space for PAGE_SIZE above
> > +        * that, mmap will ignore our address hint.
> > +        *
> > +        * override credentials otherwise anonymous memory might
> > +        * not be granted execute permission when the selinux
> > +        * security hooks have their way.
> > +        */
> > +       vma = rb_entry(rb_last(&mm->mm_rb), struct vm_area_struct, vm_rb);
> > +       addr = vma->vm_end + PAGE_SIZE;
> > +       curr_cred = override_creds(&init_cred);
> > +       addr = do_mmap_pgoff(NULL, addr, PAGE_SIZE, PROT_EXEC, MAP_PRIVATE, 0);
> > +       revert_creds(curr_cred);
> > +
> > +       if (addr & ~PAGE_MASK)
> > +               goto fail;
> > +       vma = find_vma(mm, addr);
> > +
> > +       /* Don't expand vma on mremap(). */
> > +       vma->vm_flags |= VM_DONTEXPAND | VM_DONTCOPY;
> > +       area->vaddr = vma->vm_start;
> > +       if (get_user_pages(current, mm, area->vaddr, 1, 1, 1, &area->page,
> > +                               &vma) > 0)
> > +               ret = 0;
> > +
> > +fail:
> > +       up_write(&mm->mmap_sem);
> > +       mmput(mm);
> > +       return ret;
> > +} 
> 
> So is that the right way? I looked back to the previous discussion with
> Eric and couldn't really make up my mind either way. The changelog is
> entirely without detail and Eric isn't CC'ed.

This is based on what Stephen Smalley suggested on the same thread
https://lkml.org/lkml/2011/4/20/224

I used to keep the changelog after the marker after Christoph Hellwig
had suggested that https://lkml.org/lkml/2010/7/20/5
However "stg export" removes lines after the --- marker.

I agree that I should have copied Eric and Stephen atleast on this
patch. However if the number of to/cc are greater than 20, the LKML
archive cool ignore the mail.

I know that these arent problems faced by others and open to suggestions
on how they have overcome the same.

> 
> What's the point of having these discussions if all traces of them
> disappear on the next posting?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
