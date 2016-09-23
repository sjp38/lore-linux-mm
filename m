Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5817828024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 10:53:05 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so19980544wmg.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 07:53:05 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id fg10si7932889wjb.82.2016.09.23.07.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 07:53:03 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w84so3207806wmg.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 07:53:03 -0700 (PDT)
Date: Fri, 23 Sep 2016 16:53:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/2] mm, proc: Fix region lost in /proc/self/smaps
Message-ID: <20160923145301.GU4478@dhcp22.suse.cz>
References: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
 <20160923135635.GB28734@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160923135635.GB28734@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Robert Ho <robert.hu@intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, dan.j.williams@intel.com, dave.hansen@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On Fri 23-09-16 15:56:36, Oleg Nesterov wrote:
> On 09/23, Robert Ho wrote:
> >
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -147,7 +147,7 @@ m_next_vma(struct proc_maps_private *priv, struct vm_area_struct *vma)
> >  static void m_cache_vma(struct seq_file *m, struct vm_area_struct *vma)
> >  {
> >  	if (m->count < m->size)	/* vma is copied successfully */
> > -		m->version = m_next_vma(m->private, vma) ? vma->vm_start : -1UL;
> > +		m->version = m_next_vma(m->private, vma) ? vma->vm_end : -1UL;
> >  }
> 
> OK.
> 
> >  static void *m_start(struct seq_file *m, loff_t *ppos)
> > @@ -176,14 +176,14 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
> >  
> >  	if (last_addr) {
> >  		vma = find_vma(mm, last_addr);
> > -		if (vma && (vma = m_next_vma(priv, vma)))
> > +		if (vma)
> >  			return vma;
> >  	}
> 
> I think we can simplify this patch. And imo make it better. How about

it is certainly less subtle because it doesn't report "sub-vmas".

> 	if (last_addr) {
> 		vma = find_vma(mm, last_addr - 1);
> 		if (vma && vma->vm_start <= last_addr)
> 			vma = m_next_vma(priv, vma);
> 		if (vma)
> 			return vma;
> 	}

we would still miss a VMA if the last one got shrunk/split but at least
it would provide monotonic results. So definitely an improvement but
I guess we really want to document that only full reads provide a
consistent (at some moment in time) output.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
