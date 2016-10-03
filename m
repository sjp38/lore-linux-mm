Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D70256B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 11:52:24 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f6so94602836qtd.2
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 08:52:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j31si12135923qtb.6.2016.10.03.08.52.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 08:52:24 -0700 (PDT)
Date: Mon, 3 Oct 2016 17:51:12 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4 1/2] mm, proc: Fix region lost in /proc/self/smaps
Message-ID: <20161003155111.GA4758@redhat.com>
References: <1475296958-27652-1-git-send-email-robert.hu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475296958-27652-1-git-send-email-robert.hu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Ho <robert.hu@intel.com>
Cc: pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, dave.hansen@intel.com, dan.j.williams@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On 10/01, Robert Ho wrote:
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
>  
>  static void *m_start(struct seq_file *m, loff_t *ppos)
> @@ -175,8 +175,10 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
>  	priv->tail_vma = get_gate_vma(mm);
>  
>  	if (last_addr) {
> -		vma = find_vma(mm, last_addr);
> -		if (vma && (vma = m_next_vma(priv, vma)))
> +		vma = find_vma(mm, last_addr - 1);
> +		if (vma && vma->vm_start <= last_addr)
> +			vma = m_next_vma(priv, vma);
> +		if (vma)
>  			return vma;
>  	}

Acked-by: Oleg Nesterov <oleg@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
