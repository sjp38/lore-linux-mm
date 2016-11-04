Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3227D6B0343
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 11:40:22 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id rf5so40234346pab.3
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 08:40:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 26si17125980pfo.279.2016.11.04.08.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 08:40:21 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA4FdKoq023465
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 11:40:20 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26gw5ng373-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 04 Nov 2016 11:40:20 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 4 Nov 2016 15:40:18 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id DFDBA219006D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 15:39:30 +0000 (GMT)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA4FeG8912124526
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 15:40:16 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA4FeFUs025629
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 09:40:16 -0600
Date: Fri, 4 Nov 2016 09:40:07 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 11/33] userfaultfd: non-cooperative: Add mremap() event
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-12-git-send-email-aarcange@redhat.com>
 <072901d235a5$a8826700$f9873500$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <072901d235a5$a8826700$f9873500$@alibaba-inc.com>
Message-Id: <20161104154005.GB5605@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Shaohua Li <shli@fb.com>, Pavel Emelyanov <xemul@virtuozzo.com>

On Thu, Nov 03, 2016 at 03:41:15PM +0800, Hillf Danton wrote:
> On Thursday, November 03, 2016 3:34 AM Andrea Arcangeli wrote:
> > @@ -576,7 +581,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
> >  			goto out;
> >  		}
> > 
> > -		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked);
> > +		ret = move_vma(vma, addr, old_len, new_len, new_addr,
> > +			       &locked, &uf);
> >  	}
> >  out:
> >  	if (offset_in_page(ret)) {
> > @@ -586,5 +592,6 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
> >  	up_write(&current->mm->mmap_sem);
> >  	if (locked && new_len > old_len)
> >  		mm_populate(new_addr + old_len, new_len - old_len);
> > +	mremap_userfaultfd_complete(uf, addr, new_addr, old_len);
> 
> nit: s/uf/&uf/
> 
> >  	return ret;
> >  }
> > 

Below is the updated patch.
