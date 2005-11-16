Date: Wed, 16 Nov 2005 10:21:07 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 2/2] Fold numa_maps into mempolicy.c
In-Reply-To: <20051115231051.5437e25b.pj@sgi.com>
Message-ID: <Pine.LNX.4.62.0511161017010.15723@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511081520540.32262@schroedinger.engr.sgi.com>
 <Pine.LNX.4.62.0511081524570.32262@schroedinger.engr.sgi.com>
 <20051115231051.5437e25b.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Nov 2005, Paul Jackson wrote:

> Christoph wrote:
> > + * Must hold mmap_sem until memory pointer is no longer in use
> > + * or be called from the current task.
> > + */
> > +struct mempolicy *get_vma_policy(struct task_struct *task,
> 
> Twenty (well, four) questions time.
> 
> Hmmm ... is that true - that get_vma_policy() can be called for the
> current task w/o holding mmap_sem?

Hmm. You are right. The current task must be holding map_sem in order to 
have the vma not vanish under it. So mmap_sem must be held 
unconditionally to use this function.

> Except for /proc output, is there any call to get_vma_policy made on any
> task other than current?

There is currently no use except by /proc/<pid>/numa_stats.
 
> What does "until memory pointer is no longer in use" mean?

There will be no references to struct mempolicy * after unlock 
mmap_sem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
