Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 935C16B0032
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 15:36:10 -0500 (EST)
Received: by mail-qa0-f50.google.com with SMTP id dc16so1970440qab.9
        for <linux-mm@kvack.org>; Sat, 20 Dec 2014 12:36:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g9si15630391qgg.79.2014.12.20.12.36.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Dec 2014 12:36:09 -0800 (PST)
Date: Sat, 20 Dec 2014 17:44:58 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] proc: task_mmu: show page size in /proc/<pid>/numa_maps
Message-ID: <20141220194457.GA3166@x61.redhat.com>
References: <c97f30472ec5fe79cb8fa8be66cc3d8509777990.1419079617.git.aquini@redhat.com>
 <20141220183613.GA19229@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141220183613.GA19229@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, oleg@redhat.com, dave.hansen@linux.intel.com, rientjes@google.com, linux-mm@kvack.org

On Sat, Dec 20, 2014 at 01:36:13PM -0500, Johannes Weiner wrote:
> On Sat, Dec 20, 2014 at 08:54:45AM -0500, Rafael Aquini wrote:
> > This patch introduces 'pagesize' line element to /proc/<pid>/numa_maps
> > report file in order to help disambiguating the size of pages that are
> > backing memory areas mapped by a task. When the VMA backing page size
> > is observed different from kernel's default PAGE_SIZE, the new element 
> > is printed out to complement report output. This is specially useful to
> > help differentiating between HUGE and GIGANTIC page VMAs.
> > 
> > This patch is based on Dave Hansen's proposal and reviewer's follow ups 
> > taken from this dicussion: https://lkml.org/lkml/2011/9/21/454
> > 
> > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> > ---
> >  fs/proc/task_mmu.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 246eae8..9f2e2c8 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -1479,6 +1479,7 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
> >  	struct mm_struct *mm = vma->vm_mm;
> >  	struct mm_walk walk = {};
> >  	struct mempolicy *pol;
> > +	unsigned long page_size;
> >  	char buffer[64];
> >  	int nid;
> >  
> > @@ -1533,6 +1534,10 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
> >  	if (!md->pages)
> >  		goto out;
> >  
> > +	page_size = vma_kernel_pagesize(vma);
> > +	if (page_size != PAGE_SIZE)
> > +		seq_printf(m, " pagesize=%lu", page_size);
> 
> It would be simpler to include this unconditionally.  Otherwise you
> are forcing everybody parsing the file and trying to run calculations
> of it to check for its presence, and then have them fall back and get
> the value from somewhere else if not.

I'm fine either way, it makes the change even simpler. Also, if we
decide to get rid of page_size != PAGE_SIZE condition I believe we can 
also get rid of that "huge" hint being conditionally printed out too.

-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
