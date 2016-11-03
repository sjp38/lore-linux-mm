Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DEB5280250
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 13:52:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 83so13770297pfx.1
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 10:52:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l11si10952203pgc.55.2016.11.03.10.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 10:52:49 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA3HnSn9100184
	for <linux-mm@kvack.org>; Thu, 3 Nov 2016 13:52:48 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26g765t6w7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 03 Nov 2016 13:52:48 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 3 Nov 2016 17:52:47 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 6D2031B08023
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 17:54:54 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA3HqiKm30605486
	for <linux-mm@kvack.org>; Thu, 3 Nov 2016 17:52:44 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA3Hqhxh002526
	for <linux-mm@kvack.org>; Thu, 3 Nov 2016 11:52:43 -0600
Date: Thu, 3 Nov 2016 11:52:32 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 11/33] userfaultfd: non-cooperative: Add mremap() event
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-12-git-send-email-aarcange@redhat.com>
 <072901d235a5$a8826700$f9873500$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <072901d235a5$a8826700$f9873500$@alibaba-inc.com>
Message-Id: <20161103175231.GA21803@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Shaohua Li <shli@fb.com>, Pavel Emelyanov <xemul@virtuozzo.com>

(changed 'CC:
- Michael Rapoport <RAPOPORT@il.ibm.com>,
- Dr. David Alan Gilbert@v2.random,  <dgilbert@redhat.com>,
+ Dr. David Alan Gilbert  <dgilbert@redhat.com>,
- Pavel Emelyanov <xemul@parallels.com>@v2.random
+ Pavel Emelyanov <xemul@virtuozzo.com>
)

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

Thanks, will fix.

> 
> >  	return ret;
> >  }
> > 
> 

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
