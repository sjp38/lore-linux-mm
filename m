Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B5ABA6B0253
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 13:02:42 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k70so7998752itk.11
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 10:02:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c63si1669752itg.168.2017.10.19.10.02.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 10:02:41 -0700 (PDT)
Date: Thu, 19 Oct 2017 13:02:38 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [rfc 2/2] smaps: Show zone device memory used
Message-ID: <20171019170238.GB3044@redhat.com>
References: <20171018063123.21983-1-bsingharora@gmail.com>
 <20171018063123.21983-2-bsingharora@gmail.com>
 <d33c5a32-2b1a-85c7-be68-d006517b1ecd@linux.vnet.ibm.com>
 <20171019064858.11c812e6@MiWiFi-R3-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171019064858.11c812e6@MiWiFi-R3-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, mhocko@suse.com

On Thu, Oct 19, 2017 at 06:48:58AM +1100, Balbir Singh wrote:
> On Wed, 18 Oct 2017 12:40:43 +0530
> Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:
> 
> > On 10/18/2017 12:01 PM, Balbir Singh wrote:
> > > With HMM, we can have either public or private zone
> > > device pages. With private zone device pages, they should
> > > show up as swapped entities. For public zone device pages  
> > 
> > Might be missing something here but why they should show up
> > as swapped entities ? Could you please elaborate.
> >
> 
> For migrated entries, my use case is to
> 
> 1. malloc()/mmap() memory
> 2. call migrate_vma()
> 3. Look at smaps
> 
> It's probably not clear in the changelog.

My only worry is about API, is smaps consider as userspace API ?
My fear here is that maybe we will want to report device memory
differently in the future and have different category of device
memory. Even thought right now i can only think of wanting to
differentiate between public and private device memory but right
now as you pointed out this is reported as swap out.

Otherwise patches looks good and you got:

Reviewed-by: Jerome Glisse <jglisse@redhat.com>

> 
> > > the smaps output can be confusing and incomplete.
> > > 
> > > This patch adds a new attribute to just smaps to show
> > > device memory usage.  
> > 
> > If we are any way adding a new entry here then why not one
> > more for private device memory pages as well. Just being
> > curious.
> > 
> 
> Well, how do you define visibility of device private memory?
> Device private is either seen as swapped out or when migrated
> back is visible as a part of the mm. Am I missing anything?
> 
> > > 
> > > Signed-off-by: Balbir Singh <bsingharora@gmail.com>
> > > ---
> > >  fs/proc/task_mmu.c | 17 +++++++++++++++--
> > >  1 file changed, 15 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > > index 9f1e2b2b5f5a..b7f32f42ee93 100644
> > > --- a/fs/proc/task_mmu.c
> > > +++ b/fs/proc/task_mmu.c
> > > @@ -451,6 +451,7 @@ struct mem_size_stats {
> > >  	unsigned long shared_hugetlb;
> > >  	unsigned long private_hugetlb;
> > >  	unsigned long first_vma_start;
> > > +	unsigned long device_memory;
> > >  	u64 pss;
> > >  	u64 pss_locked;
> > >  	u64 swap_pss;
> > > @@ -463,12 +464,22 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
> > >  	int i, nr = compound ? 1 << compound_order(page) : 1;
> > >  	unsigned long size = nr * PAGE_SIZE;
> > >  
> > > +	/*
> > > +	 * We don't want to process public zone device pages further
> > > +	 * than just showing how much device memory we have
> > > +	 */
> > > +	if (is_zone_device_page(page)) {  
> > 
> > Should not this contain both public and private device pages.
> > 
> 
> This page is received from _vm_normal_page(.., true), I don't
> think device private pages show up here.
> 
> > > +		mss->device_memory += size;
> > > +		return;
> > > +	}
> > > +
> > >  	if (PageAnon(page)) {
> > >  		mss->anonymous += size;
> > >  		if (!PageSwapBacked(page) && !dirty && !PageDirty(page))
> > >  			mss->lazyfree += size;
> > >  	}
> > >  
> > > +  
> > 
> > Stray new line.
> > 
> 
> I can remove it
> 
> > >  	mss->resident += size;
> > >  	/* Accumulate the size in pages that have been accessed. */
> > >  	if (young || page_is_young(page) || PageReferenced(page))
> > > @@ -833,7 +844,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
> > >  			   "Private_Hugetlb: %7lu kB\n"
> > >  			   "Swap:           %8lu kB\n"
> > >  			   "SwapPss:        %8lu kB\n"
> > > -			   "Locked:         %8lu kB\n",
> > > +			   "Locked:         %8lu kB\n"  
> > 
> > Stray changed line.
> 
> ?? The line has changed
> 
> 
> Thanks for the review!
> 
> Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
