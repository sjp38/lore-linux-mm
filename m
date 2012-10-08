Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id E90E66B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 16:52:17 -0400 (EDT)
Date: Mon, 8 Oct 2012 16:52:13 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: mpol_to_str revisited.
Message-ID: <20121008205213.GA23211@redhat.com>
References: <20121008150949.GA15130@redhat.com>
 <alpine.DEB.2.00.1210081330160.18768@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1210081330160.18768@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, bhutchings@solarflare.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 08, 2012 at 01:35:42PM -0700, David Rientjes wrote:

 > > unanswered question: why are the buffer sizes here different ? which is correct?
 > > 
 > Given the current set of mempolicy modes and flags, it's 34, but this can 
 > change if new modes or flags are added with longer names.  I see no reason 
 > why shmem shouldn't round up to the nearest power-of-2 of 64 like it 
 > already does, but 50 is certainly safe as well in task_mmu.c.

Ok. I'll leave that for now.
 
 > > diff -durpN '--exclude-from=/home/davej/.exclude' src/git-trees/kernel/linux/fs/proc/task_mmu.c linux-dj/fs/proc/task_mmu.c
 > > --- src/git-trees/kernel/linux/fs/proc/task_mmu.c	2012-05-31 22:32:46.778150675 -0400
 > > +++ linux-dj/fs/proc/task_mmu.c	2012-10-04 19:31:41.269988984 -0400
 > > @@ -1162,6 +1162,7 @@ static int show_numa_map(struct seq_file
 > >  	struct mm_walk walk = {};
 > >  	struct mempolicy *pol;
 > >  	int n;
 > > +	int ret;
 > >  	char buffer[50];
 > >  
 > >  	if (!mm)
 > > @@ -1178,7 +1179,11 @@ static int show_numa_map(struct seq_file
 > >  	walk.mm = mm;
 > >  
 > >  	pol = get_vma_policy(proc_priv->task, vma, vma->vm_start);
 > > -	mpol_to_str(buffer, sizeof(buffer), pol, 0);
 > > +	memset(buffer, 0, sizeof(buffer));
 > > +	ret = mpol_to_str(buffer, sizeof(buffer), pol, 0);
 > > +	if (ret < 0)
 > > +		return 0;
 > 
 > We should need the mpol_cond_put(pol) here before returning.

good catch. I'll respin the patch later with this changed.

thanks,
 
	Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
