Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 081746B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 07:43:01 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id 18so21163082qtt.10
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 04:43:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c132si389299qkg.379.2017.11.27.04.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 04:43:00 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vARCdGtY008818
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 07:42:59 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2egjcq24sh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 07:42:58 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 27 Nov 2017 12:42:56 -0000
Date: Mon, 27 Nov 2017 14:42:49 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm,madvise: bugfix of madvise systemcall infinite loop
 under special circumstances.
References: <20171127115318.911-1-guoxuenan@huawei.com>
 <20171127115847.7b65btmfl762552d@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171127115847.7b65btmfl762552d@dhcp22.suse.cz>
Message-Id: <20171127124248.GA10946@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: guoxuenan <guoxuenan@huawei.com>, akpm@linux-foundation.org, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yi.zhang@huawei.com, miaoxie@huawei.com, shli@fb.com, aarcange@redhat.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, rientjes@google.com, khandual@linux.vnet.ibm.com, riel@redhat.com

On Mon, Nov 27, 2017 at 12:58:47PM +0100, Michal Hocko wrote:
> On Mon 27-11-17 19:53:18, guoxuenan wrote:
> > From: chenjie <chenjie6@huawei.com>
> > 
> > The madvise() system call supported a set of "conventional" advice values,
> > the MADV_WILLNEED parameter has possibility of triggering an infinite loop under
> > direct access mode(DAX).
> > 
> > Infinite loop situation:
> > 1a??initial state [ start = vam->vm_start < vam->vm_end < end ].
> > 2a??madvise_vma() using MADV_WILLNEED parameter;
> >    madvise_vma() -> madvise_willneed() -> return 0 && the value of [prev] is not updated.
> > 
> > In function SYSCALL_DEFINE3(madvise,...)
> > When [start = vam->vm_start] the program enters "for" loop,
> > find_vma_prev() will set the pointer vma and the pointer prev(prev = vam->vm_prev).
> > Normally ,madvise_vma() will always move the pointer prev ,but when use DAX mode,
> > it will never update the value of [prev].
> > 
> > =======================================================================
> > SYSCALL_DEFINE3(madvise,...)
> > {
> > 	[...]
> > 	//start = vam->start  => prev=vma->prev
> >     vma = find_vma_prev(current->mm, start, &prev);
> > 	[...]
> > 	for(;;)
> > 	{
> > 	      update [start = vma->vm_start]
> > 
> > 	con0: if (start >= end)                 //false always;
> > 	    goto out;
> > 	       tmp = vma->vm_end;
> > 
> > 	//do not update [prev] and always return 0;
> > 	       error = madvise_willneed();
> > 
> > 	con1: if (error)                        //false always;
> > 	    goto out;
> > 
> > 	//[ vam->vm_start < start = vam->vm_end  <end ]
> > 	       update [start = tmp ]
> > 
> > 	con2: if (start >= end)                 //false always ;
> > 	    goto out;
> > 
> > 	//because of pointer [prev] did not change,[vma] keep as it was;
> > 	       update [ vma = prev->vm_next ]
> > 	}
> > 	[...]
> > }
> > =======================================================================
> > After the first cycle ;it will always keep
> > vam->vm_start < start = vam->vm_end  < end  && vma = prev->vm_next;
> > since Circulation exit conditions (con{0,1,2}) will never meet ,the
> > program stuck in infinite loop.
> 
> I find your changelog a bit hard to parse. What would you think about
> the following:
> "
> MADVISE_WILLNEED has always been a noop for DAX (formerly XIP) mappings.
> Unfortunatelly madvise_willneed doesn't communicate this information
> properly to the generic madvise syscall implementation. The calling
> converion is quite subtle there. madvise_vma is supposed to either

spelling: "The calling convention"

> return an error or update &prev otherwise the main loop will never
> advance to the next vma and it will keep looping for ever without a way
> to get out of the kernel.
> 
> It seems this has been broken since introduced. Nobody has noticed
> because nobody seems to be using MADVISE_WILLNEED on these DAX mappings.
> 
> Fixes: fe77ba6f4f97 ("[PATCH] xip: madvice/fadvice: execute in place")
> Cc: stable
> "
> 
> > Signed-off-by: chenjie <chenjie6@huawei.com>
> > Signed-off-by: guoxuenan <guoxuenan@huawei.com>
> 
> Other than that
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> > ---
> >  mm/madvise.c | 4 +---
> >  1 file changed, 1 insertion(+), 3 deletions(-)
> > 
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 375cf32..751e97a 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -276,15 +276,14 @@ static long madvise_willneed(struct vm_area_struct *vma,
> >  {
> >  	struct file *file = vma->vm_file;
> >  
> > +	*prev = vma;
> >  #ifdef CONFIG_SWAP
> >  	if (!file) {
> > -		*prev = vma;
> >  		force_swapin_readahead(vma, start, end);
> >  		return 0;
> >  	}
> >  
> >  	if (shmem_mapping(file->f_mapping)) {
> > -		*prev = vma;
> >  		force_shm_swapin_readahead(vma, start, end,
> >  					file->f_mapping);
> >  		return 0;
> > @@ -299,7 +298,6 @@ static long madvise_willneed(struct vm_area_struct *vma,
> >  		return 0;
> >  	}
> >  
> > -	*prev = vma;
> >  	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> >  	if (end > vma->vm_end)
> >  		end = vma->vm_end;
> > -- 
> > 2.9.5
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
