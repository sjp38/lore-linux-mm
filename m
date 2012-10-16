Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id C9ADB6B005A
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 20:48:35 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so6078821pad.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 17:48:35 -0700 (PDT)
Date: Mon, 15 Oct 2012 17:48:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: mpol_to_str revisited.
In-Reply-To: <20121008205213.GA23211@redhat.com>
Message-ID: <alpine.DEB.2.00.1210151748010.31712@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <alpine.DEB.2.00.1210081330160.18768@chino.kir.corp.google.com> <20121008205213.GA23211@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, bhutchings@solarflare.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 8 Oct 2012, Dave Jones wrote:

>  > > diff -durpN '--exclude-from=/home/davej/.exclude' src/git-trees/kernel/linux/fs/proc/task_mmu.c linux-dj/fs/proc/task_mmu.c
>  > > --- src/git-trees/kernel/linux/fs/proc/task_mmu.c	2012-05-31 22:32:46.778150675 -0400
>  > > +++ linux-dj/fs/proc/task_mmu.c	2012-10-04 19:31:41.269988984 -0400
>  > > @@ -1162,6 +1162,7 @@ static int show_numa_map(struct seq_file
>  > >  	struct mm_walk walk = {};
>  > >  	struct mempolicy *pol;
>  > >  	int n;
>  > > +	int ret;
>  > >  	char buffer[50];
>  > >  
>  > >  	if (!mm)
>  > > @@ -1178,7 +1179,11 @@ static int show_numa_map(struct seq_file
>  > >  	walk.mm = mm;
>  > >  
>  > >  	pol = get_vma_policy(proc_priv->task, vma, vma->vm_start);
>  > > -	mpol_to_str(buffer, sizeof(buffer), pol, 0);
>  > > +	memset(buffer, 0, sizeof(buffer));
>  > > +	ret = mpol_to_str(buffer, sizeof(buffer), pol, 0);
>  > > +	if (ret < 0)
>  > > +		return 0;
>  > 
>  > We should need the mpol_cond_put(pol) here before returning.
> 
> good catch. I'll respin the patch later with this changed.
> 

Did you get a chance to fix this issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
