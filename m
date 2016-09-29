Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 419126B0253
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:06:33 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id p135so60190135itb.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:06:33 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v66si14322754pfj.183.2016.09.29.06.06.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 06:06:13 -0700 (PDT)
Message-ID: <1475154343.16655.1.camel@vmm.sh.intel.com>
Subject: Re: [PATCH v3 1/2] mm, proc: Fix region lost in /proc/self/smaps
From: Robert Hu <robert.hu@vmm.sh.intel.com>
Reply-To: robert.hu@intel.com
Date: Thu, 29 Sep 2016 21:05:43 +0800
In-Reply-To: <20160923145301.GU4478@dhcp22.suse.cz>
References: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
	 <20160923135635.GB28734@redhat.com> <20160923145301.GU4478@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Robert Ho <robert.hu@intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, dan.j.williams@intel.com, dave.hansen@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On Fri, 2016-09-23 at 16:53 +0200, Michal Hocko wrote:
> On Fri 23-09-16 15:56:36, Oleg Nesterov wrote:
> > On 09/23, Robert Ho wrote:
> > >
> > > --- a/fs/proc/task_mmu.c
> > > +++ b/fs/proc/task_mmu.c
> > > @@ -147,7 +147,7 @@ m_next_vma(struct proc_maps_private *priv, struct vm_area_struct *vma)
> > >  static void m_cache_vma(struct seq_file *m, struct vm_area_struct *vma)
> > >  {
> > >  	if (m->count < m->size)	/* vma is copied successfully */
> > > -		m->version = m_next_vma(m->private, vma) ? vma->vm_start : -1UL;
> > > +		m->version = m_next_vma(m->private, vma) ? vma->vm_end : -1UL;
> > >  }
> > 
> > OK.
> > 
> > >  static void *m_start(struct seq_file *m, loff_t *ppos)
> > > @@ -176,14 +176,14 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
> > >  
> > >  	if (last_addr) {
> > >  		vma = find_vma(mm, last_addr);
> > > -		if (vma && (vma = m_next_vma(priv, vma)))
> > > +		if (vma)
> > >  			return vma;
> > >  	}
> > 
> > I think we can simplify this patch. And imo make it better. How about
> 
> it is certainly less subtle because it doesn't report "sub-vmas".
> 
> > 	if (last_addr) {
> > 		vma = find_vma(mm, last_addr - 1);
> > 		if (vma && vma->vm_start <= last_addr)
> > 			vma = m_next_vma(priv, vma);
> > 		if (vma)
> > 			return vma;
> > 	}
> 
> we would still miss a VMA if the last one got shrunk/split but at least
> it would provide monotonic results. So definitely an improvement but
> I guess we really want to document that only full reads provide a
> consistent (at some moment in time) output.

Indeed an improvement. I prefer Oleg's approach as well.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
