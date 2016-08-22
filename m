Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C801B6B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 03:24:17 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so68048281lfw.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 00:24:17 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id u138si14986834wmu.42.2016.08.22.00.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 00:24:16 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o80so12102897wme.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 00:24:16 -0700 (PDT)
Date: Mon, 22 Aug 2016 09:24:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] proc: task_mmu: Reduce output processing cpu time
Message-ID: <20160822072414.GB13596@dhcp22.suse.cz>
References: <cover.1471679737.git.joe@perches.com>
 <2c1ea0d8f35fa5ddea477369b273d6d91c5bf2e2.1471679737.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2c1ea0d8f35fa5ddea477369b273d6d91c5bf2e2.1471679737.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org

On Sat 20-08-16 01:00:17, Joe Perches wrote:
[...]
>  static int proc_maps_open(struct inode *inode, struct file *file,
>  			const struct seq_operations *ops, int psize)
>  {
> -	struct proc_maps_private *priv = __seq_open_private(file, ops, psize);
> +	struct proc_maps_private *priv;
> +	struct mm_struct *mm;
> +
> +	mm = proc_mem_open(inode, PTRACE_MODE_READ);
> +	if (IS_ERR(mm))
> +		return PTR_ERR(mm);
>  
> +	priv = __seq_open_private_bufsize(file, ops, psize,
> +					  mm && mm->map_count ?
> +					  mm->map_count * 0x300 : PAGE_SIZE);

NAK to this! Seriously, this just gives any random user access to user
defined amount of memory which not accounted, not reclaimable and a
potential consumer of any higher order blocks.

Besides that, at least one show_smap output will always fit inside the
single page and AFAIR (it's been quite a while since I've looked into
seq_file internals) the buffer grows only when the single show doesn't
fit in.

>  	if (!priv)
>  		return -ENOMEM;
>  
>  	priv->inode = inode;
> -	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
> -	if (IS_ERR(priv->mm)) {
> -		int err = PTR_ERR(priv->mm);
> -
> -		seq_release_private(inode, file);
> -		return err;
> -	}
> +	priv->mm = mm;
>  
>  	return 0;
>  }
> @@ -721,6 +723,25 @@ void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
>  {
>  }
>  
> +static void show_val_kb(struct seq_file *m, const char *s, unsigned long num)
> +{
> +	char v[32];
> +	static const char blanks[7] = {' ', ' ', ' ', ' ',' ', ' ', ' '};
> +	int len;
> +
> +	len = num_to_str(v, sizeof(v), num >> 10);
> +
> +	seq_write(m, s, 16);
> +
> +	if (len > 0) {
> +		if (len < 8)
> +			seq_write(m, blanks, 8 - len);
> +
> +		seq_write(m, v, len);
> +	}
> +	seq_write(m, " kB\n", 4);
> +}
> +

I really do not understand why you insist on code duplication rather
than reuse but if you really insist then just make this (without the
above __seq_open_private_bufsize, re-measure and add the results to the
changelog and repost.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
