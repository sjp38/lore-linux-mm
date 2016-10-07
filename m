Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DED886B0038
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 22:14:47 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hm5so15436163pac.4
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 19:14:47 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n3si6038236pfn.77.2016.10.06.19.14.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Oct 2016 19:14:46 -0700 (PDT)
Message-ID: <1475806642.6073.10.camel@vmm.sh.intel.com>
Subject: Re: [PATCH v4 1/2] mm, proc: Fix region lost in /proc/self/smaps
From: Robert Hu <robert.hu@vmm.sh.intel.com>
Reply-To: robert.hu@intel.com
Date: Fri, 07 Oct 2016 10:17:22 +0800
In-Reply-To: <20161003115210.GA26768@dhcp22.suse.cz>
References: <1475296958-27652-1-git-send-email-robert.hu@intel.com>
	 <20161003115210.GA26768@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Robert Ho <robert.hu@intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, oleg@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On Mon, 2016-10-03 at 13:52 +0200, Michal Hocko wrote:
> On Sat 01-10-16 12:42:37, Robert Ho wrote:
> > Recently, Redhat reported that nvml test suite failed on QEMU/KVM,
> > more detailed info please refer to:
> >    https://bugzilla.redhat.com/show_bug.cgi?id=1365721
> > 
[trim...]
> > 
> > In order to fix this bug, we make 'file->version' indicate the end address
> > of current VMA
> 
> I guess you wanted to finish that sentence, right?
> "
> m_start will then look up a vma which with vma_start < last_vm_end and
> moves on to the next vma if we found the same or an overlapping vma.
> This will guarantee that we will not miss an exclusive vma but we can
> still miss one if the previous vma was shrunk. This is acceptable
> because guaranteeing "never miss a vma" is simply not feasible. User has
> to cope with some inconsistencies if the file is not read in one go.
> "

Yes, you're right. Sorry that I didn't complement that in v4.
I see the patch is already moved to -mm tree (by you?) with the above
complemented. So I'm not supposed to work a v5 patch, am I right?
>  
> > Changelog:
> > v4:
> > 	Thank Oleg Nesterov <oleg@redhat.com>'s contribution, making the patch
> > more simplified. We now only need to 1) use vm_end in m->version for remember
> > last vma 2) in m_start(), by judging the found vma's vm_start, determine
> > whether use it or its successor.
> > 
> > v3:
> > 	Thank Michal's pointing. Fix the incompletion of v2's fixing:
> > "/proc/<pid>/smaps will report counters for the full vma range while
> > the header (aka show_map_vma) will report shorter (non-overlapping) range"
> >     Add description in Documentation/filesystems/proc.txt, regarding maps,
> > smaps reading's guaruntees.
> > 
> > v2:
> > Thanks to Dave Hansen's comments, this version fixes the issue in v1 that
> > same virtual address range may be outputted twice, e.g:
> 
> I am not sure how the two above are helpful as the patch has been
> reworked basically.
> 
I might be wrong, I thought the change log should honestly write each
version's changes, although it indeed looks confusing if looks at this
single version only.

So I learned from you now that change log shall only reflect the final
adopted changes only, right?

> > Take two example VMAs:
> > 
> > 	vma-A: (0x1000 -> 0x2000)
> > 	vma-B: (0x2000 -> 0x3000)
> > 
> > read() #1: prints vma-A, sets m->version=0x2000
> > 
> > Now, merge A/B to make C:
> > 
> > 	vma-C: (0x1000 -> 0x3000)
> > 
> > read() #2: find_vma(m->version=0x2000), returns vma-C, prints vma-C
> > 
> > The user will see two VMAs in their output:
> > 
> > 	A: 0x1000->0x2000
> > 	C: 0x1000->0x3000
> > 
> 
> {Suggested,Signed-off}-by: Oleg Nesterov <oleg@redhat.com>
> ?
> 
Indeed. I had thought about this. But because I'm new here; and thought
'signed-off-by' shall be authorized first, then added by another person.
Anyway, I should have asked Oleg for this before sending the patch.

> > Acked-by: Dave Hansen <dave.hansen@intel.com>
> > Signed-off-by: Xiao Guangrong <guangrong.xiao@linux.intel.com>
> > Signed-off-by: Robert Hu <robert.hu@intel.com>
> 
> Anyway this is definitely an improvement!
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks Michal and Oleg for Acking. I see the patch is added to -mm tree.
So I'm not going to bake v5 patch, though I see still some formatting
improvement shall be. I will improve those in my future patches.
> 
> > ---
> >  fs/proc/task_mmu.c | 8 +++++---
> >  1 file changed, 5 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index f6fa99e..45f42c8 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -147,7 +147,7 @@ m_next_vma(struct proc_maps_private *priv, struct vm_area_struct *vma)
> >  static void m_cache_vma(struct seq_file *m, struct vm_area_struct *vma)
> >  {
> >  	if (m->count < m->size)	/* vma is copied successfully */
> > -		m->version = m_next_vma(m->private, vma) ? vma->vm_start : -1UL;
> > +		m->version = m_next_vma(m->private, vma) ? vma->vm_end : -1UL;
> >  }
> >  
> >  static void *m_start(struct seq_file *m, loff_t *ppos)
> > @@ -175,8 +175,10 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
> >  	priv->tail_vma = get_gate_vma(mm);
> >  
> >  	if (last_addr) {
> > -		vma = find_vma(mm, last_addr);
> > -		if (vma && (vma = m_next_vma(priv, vma)))
> > +		vma = find_vma(mm, last_addr - 1);
> > +		if (vma && vma->vm_start <= last_addr)
> > +			vma = m_next_vma(priv, vma);
> > +		if (vma)
> >  			return vma;
> >  	}
> >  
> > -- 
> > 1.8.3.1
> > 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
