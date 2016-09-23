Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id F004428024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 09:57:36 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e1so33686927itb.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 06:57:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x11si4624152ita.12.2016.09.23.06.57.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 06:57:36 -0700 (PDT)
Date: Fri, 23 Sep 2016 15:56:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3 1/2] mm, proc: Fix region lost in /proc/self/smaps
Message-ID: <20160923135635.GB28734@redhat.com>
References: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Ho <robert.hu@intel.com>
Cc: pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, dave.hansen@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On 09/23, Robert Ho wrote:
>
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -147,7 +147,7 @@ m_next_vma(struct proc_maps_private *priv, struct vm_area_struct *vma)
>  static void m_cache_vma(struct seq_file *m, struct vm_area_struct *vma)
>  {
>  	if (m->count < m->size)	/* vma is copied successfully */
> -		m->version = m_next_vma(m->private, vma) ? vma->vm_start : -1UL;
> +		m->version = m_next_vma(m->private, vma) ? vma->vm_end : -1UL;
>  }

OK.

>  static void *m_start(struct seq_file *m, loff_t *ppos)
> @@ -176,14 +176,14 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
>  
>  	if (last_addr) {
>  		vma = find_vma(mm, last_addr);
> -		if (vma && (vma = m_next_vma(priv, vma)))
> +		if (vma)
>  			return vma;
>  	}

I think we can simplify this patch. And imo make it better. How about

	if (last_addr) {
		vma = find_vma(mm, last_addr - 1);
		if (vma && vma->vm_start <= last_addr)
			vma = m_next_vma(priv, vma);
		if (vma)
			return vma;
	}

?

This way we do not need other changes in show_map_vma(), and the same vma
won't be reported twice (as 2 different vma's) if it grows in between.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
