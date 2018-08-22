Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD6A6B24E3
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:07:33 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w194-v6so515581oiw.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 08:07:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s8-v6si1328798oia.120.2018.08.22.08.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 08:07:32 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7MEx5x3035285
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:07:31 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2m17s7q3v4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:07:29 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 22 Aug 2018 16:07:27 +0100
Date: Wed, 22 Aug 2018 08:07:18 -0700
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC v8 PATCH 2/5] uprobes: introduce has_uprobes helper
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-3-git-send-email-yang.shi@linux.alibaba.com>
 <e7147e14-bc38-03d0-90a4-5e0ca7e40050@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <e7147e14-bc38-03d0-90a4-5e0ca7e40050@suse.cz>
Message-Id: <20180822150718.GB52756@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, liu.song.a23@gmail.com, ravi.bangoria@linux.ibm.com, linux-kernel@vger.kernel.org

* Vlastimil Babka <vbabka@suse.cz> [2018-08-22 12:55:59]:

> On 08/15/2018 08:49 PM, Yang Shi wrote:
> > We need check if mm or vma has uprobes in the following patch to check
> > if a vma could be unmapped with holding read mmap_sem. The checks and
> > pre-conditions used by uprobe_munmap() look just suitable for this
> > purpose.
> > 
> > Extracting those checks into a helper function, has_uprobes().
> > 
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
> > Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
> > Cc: Jiri Olsa <jolsa@redhat.com>
> > Cc: Namhyung Kim <namhyung@kernel.org>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> > ---
> >  include/linux/uprobes.h |  7 +++++++
> >  kernel/events/uprobes.c | 23 ++++++++++++++++-------
> >  2 files changed, 23 insertions(+), 7 deletions(-)
> > 
> > diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
> > index 0a294e9..418764e 100644
> > --- a/include/linux/uprobes.h
> > +++ b/include/linux/uprobes.h
> > @@ -149,6 +149,8 @@ struct uprobes_state {
> >  extern bool arch_uprobe_ignore(struct arch_uprobe *aup, struct pt_regs *regs);
> >  extern void arch_uprobe_copy_ixol(struct page *page, unsigned long vaddr,
> >  					 void *src, unsigned long len);
> > +extern bool has_uprobes(struct vm_area_struct *vma, unsigned long start,
> > +			unsigned long end);
> >  #else /* !CONFIG_UPROBES */
> >  struct uprobes_state {
> >  };
> > @@ -203,5 +205,10 @@ static inline void uprobe_copy_process(struct task_struct *t, unsigned long flag
> >  static inline void uprobe_clear_state(struct mm_struct *mm)
> >  {
> >  }
> > +static inline bool has_uprobes(struct vm_area_struct *vma, unsigned long start,
> > +			       unsgined long end)
> > +{
> > +	return false;
> > +}
> >  #endif /* !CONFIG_UPROBES */
> >  #endif	/* _LINUX_UPROBES_H */
> > diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> > index aed1ba5..568481c 100644
> > --- a/kernel/events/uprobes.c
> > +++ b/kernel/events/uprobes.c
> > @@ -1114,22 +1114,31 @@ int uprobe_mmap(struct vm_area_struct *vma)
> >  	return !!n;
> >  }
> >  
> > -/*
> > - * Called in context of a munmap of a vma.
> > - */
> > -void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned long end)
> > +bool
> > +has_uprobes(struct vm_area_struct *vma, unsigned long start, unsigned long end)
> 
> The name is not really great...

I too feel the name is not apt. 
Can you make this vma_has_uprobes and convert the current
vma_has_uprobes to __vma_has_uprobes?

> 
> >  {
> >  	if (no_uprobe_events() || !valid_vma(vma, false))
> > -		return;
> > +		return false;
> >  
> >  	if (!atomic_read(&vma->vm_mm->mm_users)) /* called by mmput() ? */
> > -		return;
> > +		return false;
> >  
> >  	if (!test_bit(MMF_HAS_UPROBES, &vma->vm_mm->flags) ||
> >  	     test_bit(MMF_RECALC_UPROBES, &vma->vm_mm->flags))
> 
> This means that vma might have uprobes, but since RECALC is already set,
> we don't need to set it again. That's different from "has uprobes".
> 
> Perhaps something like vma_needs_recalc_uprobes() ?
> 
> But I also worry there might be a race where we initially return false
> because of MMF_RECALC_UPROBES, then the flag is cleared while vma's
> still have uprobes, then we downgrade mmap_sem and skip uprobe_munmap().
> Should be checked if e.g. mmap_sem and vma visibility changes protects
> this case from happening.

That is a very good observation.

One think we can probably do is pass an extra parameter to
has_uprobes(), depending on which we should skip this check.
such that when we call from uprobes_munmap(), we continue as is
but when calling from do_munmap_zap_rlock(), we skip the check.


> 
> > -		return;
> > +		return false;
> >  
> >  	if (vma_has_uprobes(vma, start, end))
> > +		return true;
> > +
> > +	return false;
> 
> Simpler:
> 	return vma_has_uprobes(vma, start, end);
> 
> > +}
> > +
> > +/*
> > + * Called in context of a munmap of a vma.
> > + */
> > +void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned long end)
> > +{
> > +	if (has_uprobes(vma, start, end))
> >  		set_bit(MMF_RECALC_UPROBES, &vma->vm_mm->flags);
> >  }

-- 
Thanks and Regards
Srikar Dronamraju
