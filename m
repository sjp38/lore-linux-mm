Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF83B6B0347
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 11:44:57 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a136so21316139pfa.5
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 08:44:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x18si17102479pfi.296.2016.11.04.08.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 08:44:56 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA4FiNae073375
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 11:44:56 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26gqqf76t9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 04 Nov 2016 11:44:56 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 4 Nov 2016 15:44:54 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id EECAD2190056
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 15:44:05 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA4FipAE27918442
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 15:44:51 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA4FioX1023107
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 09:44:51 -0600
Date: Fri, 4 Nov 2016 09:44:40 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 25/33] userfaultfd: shmem: add userfaultfd hook for
 shared memory faults
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-26-git-send-email-aarcange@redhat.com>
 <07ce01d23679$c2be2670$483a7350$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <07ce01d23679$c2be2670$483a7350$@alibaba-inc.com>
Message-Id: <20161104154438.GD5605@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, 'Mike Kravetz' <mike.kravetz@oracle.com>, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@virtuozzo.com>

On Fri, Nov 04, 2016 at 04:59:32PM +0800, Hillf Danton wrote:
> > @@ -1542,7 +1544,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
> >   */
> >  static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
> >  	struct page **pagep, enum sgp_type sgp, gfp_t gfp,
> > -	struct mm_struct *fault_mm, int *fault_type)
> > +	struct vm_area_struct *vma, struct vm_fault *vmf, int *fault_type)
> >  {
> >  	struct address_space *mapping = inode->i_mapping;
> >  	struct shmem_inode_info *info;
> > @@ -1597,7 +1599,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
> >  	 */
> >  	info = SHMEM_I(inode);
> >  	sbinfo = SHMEM_SB(inode->i_sb);
> > -	charge_mm = fault_mm ? : current->mm;
> > +	charge_mm = vma ? vma->vm_mm : current->mm;
> > 
> >  	if (swap.val) {
> >  		/* Look it up and read it in.. */
> > @@ -1607,7 +1609,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
> >  			if (fault_type) {
> >  				*fault_type |= VM_FAULT_MAJOR;
> >  				count_vm_event(PGMAJFAULT);
> > -				mem_cgroup_count_vm_event(fault_mm, PGMAJFAULT);
> > +				mem_cgroup_count_vm_event(vma->vm_mm,
> > +							  PGMAJFAULT);
> Seems vma is not valid in some cases.
> 
> >  			}
> >  			/* Here we actually start the io */
> >  			page = shmem_swapin(swap, gfp, info, index);
> 

Below is the updated patch that uses charge_mm instead of vma which might
be not valid.
