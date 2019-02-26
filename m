Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58BE2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:46:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 182FB2173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:46:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 182FB2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3F758E0006; Tue, 26 Feb 2019 02:46:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC7AB8E0002; Tue, 26 Feb 2019 02:46:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 942738E0006; Tue, 26 Feb 2019 02:46:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1F08E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:46:27 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 202so9011008pgb.6
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:46:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=khpbn2cLaNjCrKLITy+APA7Y0j1TJ0kvTIuxMXHPE5s=;
        b=r1ze4DAGCoX1yivFmDtRuu/WcmbPdqhX4oKROfp0KvWOOg2OAaZxFf4QMSk6lsD5qQ
         +D7Cn6nlBZ2sJstFxD0VvWsCXEWbFKct+3nZwho0dxKeQ9DSQtrycxS0O+4zYyAZZwds
         BkByEEtaxcEh47kdHHQCDeQdKQqu6EhsqrDYrpOoRInP/p25KfMTlWTcfSuyA1J2Y5yT
         Rq8QKCjWU2EXOkkYMpah7kUSiRoaKYZdRy+CB6GkW270GEmBqTZ0gOTR3YymDSIpOkHf
         CFCWS/WOA00FcYqyxoGpjtyRWqilLBRkX7YajRWCNftRAJWXf6kZVJy7D3Pu/03wstfG
         5QgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubp1wB4Qv64ZCNPIBZYa/fxpAzm/4S7YLznB7rcmmMyjMGGTlZq
	HDGcic0VI+Gr64/CgJZ29EFj5Qno+NmWHY3WWYyYGCIdXD68enNt5/QIt3wkoPSq+CtBEDHxWYq
	S1EPAK8UMccN6BEgXw1xEgJMYPeoa/7SSUCZF12f3rQSGH5FSZJUqf7sD7QtWhzSx8A==
X-Received: by 2002:a62:b801:: with SMTP id p1mr11567178pfe.25.1551167186954;
        Mon, 25 Feb 2019 23:46:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYuOHcUGIL6a9TpfuY3KigNG1Tdhb6qpT/3t/w2b3su07qcR8ObUwXjPzZnRF/7JJtp/NHu
X-Received: by 2002:a62:b801:: with SMTP id p1mr11567130pfe.25.1551167185935;
        Mon, 25 Feb 2019 23:46:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551167185; cv=none;
        d=google.com; s=arc-20160816;
        b=yvnhsifp5euJ2KqgSSyMcIT1Q3Kgsujg30af5erXwSQKdUrKmvaDFO2wHFvUZAT+QD
         ukP0HUjZyGOWhjYhM0Dqf6IBn+z4Ig7LsG0E7sV6N/DcqscWV7FbaboaLe4xdRqcE1UO
         qQkZxlbn5ypJdONHttxZMzHww9Rlbzr7av2oNMAX0VB3o3TMU7DBqiL3epx51mM91SAG
         ehEVQwV0qDhxRwDchJRDrf93WWfokdLKUmm2dpJ1wHgk+6Qa3FPx+lOxWeYjhgpp3Zee
         FVjmVVLlezxCcqOVm7AefSQS/DsOyP0t0aEVA3DxAV8oztvlujjY8RroE+Zh8TA+nTOs
         wjbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=khpbn2cLaNjCrKLITy+APA7Y0j1TJ0kvTIuxMXHPE5s=;
        b=OrAUCWLh6ZMhnRjfZdciSkK+5W8CAAzaZdI3B9XahRuwgKVWuBXwYwyPumAa+/s3li
         /nV+Tb3sbwJVRqIMNxqaVP6bs0t8IElGIbLPfJKz595EtLIKBQAESvZ39tRSbBw5r6Aa
         K0UVVcOgZzoge2HU1thPst9/Y1thruir/XSG1/i1d6wddMl9dXUblhI7lwKYImW6Zzev
         sIeGX8aJElM5Hd1OrN9Fg3s5oBKgjraEDuHcyHtjjv9r3+pw2zmk31j+HGWWTM/ab2KP
         q5vtVToApWoBi35vVrAbSURGJGCm7izrvHPKXuzzc1AhAisVsCTCzME2pvLArZASFMtF
         d3fA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i10si12149726pfj.186.2019.02.25.23.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 23:46:25 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1Q7iVAZ066608
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:46:25 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qw00jbyj1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:46:25 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 07:46:22 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 07:46:16 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1Q7kFvv59703536
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 26 Feb 2019 07:46:15 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B7B55AE045;
	Tue, 26 Feb 2019 07:46:15 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 459F6AE053;
	Tue, 26 Feb 2019 07:46:14 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 07:46:14 +0000 (GMT)
Date: Tue, 26 Feb 2019 09:46:12 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Marty McFadden <mcfadden8@llnl.gov>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>,
        Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v2 20/26] userfaultfd: wp: support write protection for
 userfault vma range
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-21-peterx@redhat.com>
 <20190225205233.GC10454@rapoport-lnx>
 <20190226060627.GG13653@xz-x1>
 <20190226064347.GB5873@rapoport-lnx>
 <20190226072027.GK13653@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226072027.GK13653@xz-x1>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022607-4275-0000-0000-000003140664
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022607-4276-0000-0000-0000382244BC
Message-Id: <20190226074612.GG5873@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260059
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 03:20:28PM +0800, Peter Xu wrote:
> On Tue, Feb 26, 2019 at 08:43:47AM +0200, Mike Rapoport wrote:
> > On Tue, Feb 26, 2019 at 02:06:27PM +0800, Peter Xu wrote:
> > > On Mon, Feb 25, 2019 at 10:52:34PM +0200, Mike Rapoport wrote:
> > > > On Tue, Feb 12, 2019 at 10:56:26AM +0800, Peter Xu wrote:
> > > > > From: Shaohua Li <shli@fb.com>
> > > > > 
> > > > > Add API to enable/disable writeprotect a vma range. Unlike mprotect,
> > > > > this doesn't split/merge vmas.
> > > > > 
> > > > > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > > > > Cc: Rik van Riel <riel@redhat.com>
> > > > > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > > > > Cc: Mel Gorman <mgorman@suse.de>
> > > > > Cc: Hugh Dickins <hughd@google.com>
> > > > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > > > Signed-off-by: Shaohua Li <shli@fb.com>
> > > > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > > > [peterx:
> > > > >  - use the helper to find VMA;
> > > > >  - return -ENOENT if not found to match mcopy case;
> > > > >  - use the new MM_CP_UFFD_WP* flags for change_protection
> > > > >  - check against mmap_changing for failures]
> > > > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > > > > ---
> > > > >  include/linux/userfaultfd_k.h |  3 ++
> > > > >  mm/userfaultfd.c              | 54 +++++++++++++++++++++++++++++++++++
> > > > >  2 files changed, 57 insertions(+)
> > > > > 
> > > > > diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> > > > > index 765ce884cec0..8f6e6ed544fb 100644
> > > > > --- a/include/linux/userfaultfd_k.h
> > > > > +++ b/include/linux/userfaultfd_k.h
> > > > > @@ -39,6 +39,9 @@ extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
> > > > >  			      unsigned long dst_start,
> > > > >  			      unsigned long len,
> > > > >  			      bool *mmap_changing);
> > > > > +extern int mwriteprotect_range(struct mm_struct *dst_mm,
> > > > > +			       unsigned long start, unsigned long len,
> > > > > +			       bool enable_wp, bool *mmap_changing);
> > > > > 
> > > > >  /* mm helpers */
> > > > >  static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
> > > > > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > > > > index fefa81c301b7..529d180bb4d7 100644
> > > > > --- a/mm/userfaultfd.c
> > > > > +++ b/mm/userfaultfd.c
> > > > > @@ -639,3 +639,57 @@ ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
> > > > >  {
> > > > >  	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing, 0);
> > > > >  }
> > > > > +
> > > > > +int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
> > > > > +			unsigned long len, bool enable_wp, bool *mmap_changing)
> > > > > +{
> > > > > +	struct vm_area_struct *dst_vma;
> > > > > +	pgprot_t newprot;
> > > > > +	int err;
> > > > > +
> > > > > +	/*
> > > > > +	 * Sanitize the command parameters:
> > > > > +	 */
> > > > > +	BUG_ON(start & ~PAGE_MASK);
> > > > > +	BUG_ON(len & ~PAGE_MASK);
> > > > > +
> > > > > +	/* Does the address range wrap, or is the span zero-sized? */
> > > > > +	BUG_ON(start + len <= start);
> > > > 
> > > > I'd replace these BUG_ON()s with
> > > > 
> > > > 	if (WARN_ON())
> > > > 		 return -EINVAL;
> > > 
> > > I believe BUG_ON() is used because these parameters should have been
> > > checked in userfaultfd_writeprotect() already by the common
> > > validate_range() even before calling mwriteprotect_range().  So I'm
> > > fine with the WARN_ON() approach but I'd slightly prefer to simply
> > > keep the patch as is to keep Jerome's r-b if you won't disagree. :)
> > 
> > Right, userfaultfd_writeprotect() should check these parameters and if it
> > didn't it was a bug indeed. But still, it's not severe enough to crash the
> > kernel.
> > 
> > I hope Jerome wouldn't mind to keep his r-b with s/BUG_ON/WARN_ON ;-)
> > 
> > With this change you can also add 
> > 
> > Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> 
> Thanks!  Though before I change anything... please note that the
> BUG_ON()s are really what we've done in existing MISSING code.  One
> example is userfaultfd_copy() which did validate_range() first, then
> in __mcopy_atomic() we've used BUG_ON()s.  They make sense to me
> becauase userspace should never be able to trigger it.  And if we
> really want to change the BUG_ON()s in this patch, IMHO we probably
> want to change the other BUG_ON()s as well, then that can be a
> standalone patch or patchset to address another issue...

Yeah, we have quite a lot of them, so doing the replacement in a separate
patch makes perfect sense.
 
> (and if we really want to use WARN_ON, I would prefer WARN_ON_ONCE, or
>  directly return the errors to avoid DOS).

Agree.

> I'll see how you'd prefer to see how I should move on with this patch.

Let's keep this patch as is and make the replacement on top of the WP
series. Feel free to add r-b.
 
> Thanks,
> 
> -- 
> Peter Xu
> 

-- 
Sincerely yours,
Mike.

