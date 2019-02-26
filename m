Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 419A2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:44:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA4D7213A2
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:44:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA4D7213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83A738E0004; Tue, 26 Feb 2019 01:44:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E9338E0002; Tue, 26 Feb 2019 01:44:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68A098E0004; Tue, 26 Feb 2019 01:44:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB4D8E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:44:03 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u12so4984643edo.5
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:44:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=hvjYjwHw9BhznjaBKo6VPFZdw85WBC+PsabC7jzHKXw=;
        b=hQvt9P+rrlieLj0wC1XtAkfkwqEykFMy3do68F19HvVJaNtNSMtYZc55ijjtxsVNxm
         OcYN3e4BNH/C3ncdJ3UE4WMa9r3MJ0FYrqkg8Vq3rV0QC/iHV5zLWYp33bC2b7YjdBuc
         4FPiYaQ2zt16xBKwgGCM/Lgu8gpwfAIH3K8eaS1H5/iCjimk5R2vfvurSV377UnTM5KI
         f42/moOCrCwX6j7H88xGXQCZk4XQ27ZtgxUCFON2zZltlMUV9AQeV4xM7n45O6LzYZxJ
         Rl/GhPQou3crr1HrdNh5TparyZZLJI7M63XkiWhNZUYIo2UAmzP8qc9DKzB/m5WrRaUd
         cQog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZPvt8KC8h088KbA8FmQ+GU3A1p9okHXoHQiz/G4v9EX5PU7c7C
	EcptJOQNmHm/cZoiREs9Iml3CV+m6rl6Qy9iss5cxR66ulBWc45B/zPwBEw6MM/NbPvYrQHtB0L
	rVgQE+IekitTIaqsWPiqw4ygMSlMuHOFGYluPisVdMD7JvcWxTW/dwzXkVB5Cq7wsKQ==
X-Received: by 2002:a17:906:49d9:: with SMTP id w25mr13947518ejv.52.1551163442560;
        Mon, 25 Feb 2019 22:44:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbU1YrmOC0WO3zgfH1pPs/c8pu5MBYAHh8GSmhZTuAPB2IxwIuPV3G34HXNgzuylo5+rJyM
X-Received: by 2002:a17:906:49d9:: with SMTP id w25mr13947484ejv.52.1551163441731;
        Mon, 25 Feb 2019 22:44:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551163441; cv=none;
        d=google.com; s=arc-20160816;
        b=flDW0F9BDdiGFRwfZzMJ7bdrLvGgv0c+4KNC0MOjXLW55mT04gwoRaPdo0WR/LjyYR
         r9UcVnCeC9EI3jWV3wy/BPTr2zEdCPNqKBZtaTlYTu9v4erJI0RxwiB2k13LIBHgx2J4
         F9u9K7aKG9FjiplTj4OGbhST/m+4zMdB774QwVqIDINvmRlXSPrkrVcSsa04LS4sPuCX
         gdgIlGz7RMeUWeuMuhWkEypo1RYlkjylalpc+KL4ZExdSKDSorzYQgSKp/fNBLhCA0pS
         vgoUkZ9zl0gUGIt9rFol6XU7j55DCKyT1wf2z1szXitpLhRrTaDjFjKDdm776UP/MKaw
         WpQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=hvjYjwHw9BhznjaBKo6VPFZdw85WBC+PsabC7jzHKXw=;
        b=Ytzbm7Dtpu6alIRxK6ohc912+ySG6hSvVBAXBfR+lCqIthXbAOXvgnslTKYZHuHS3D
         wvzGNI8rzYFzH0u+kFT8SSYiXq+3hjZkKn96AHClUBG8Fkdu8bGhxyE0i6C4jaHEX7mc
         fqJrwh9FDgnaCxVuYxQw9h07PwhumVGdgMJPeBCilWjrOrpR8ruAYLRVBcM0aO0qvYGy
         w90qS0UXg7N3XX44CKOH4pgc55Z27IQXI2RxDD1A/WX9dNwHvD2VVDoxuRtCus1Lnup7
         biVpKJMYe4bGVk+jDaDmuJokgvwNKtAv3ysY8KOL1EvAtSyeAkHWKYzFT26kYidFtZke
         oKNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x9si33928edx.107.2019.02.25.22.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 22:44:01 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1Q6havW172896
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:44:00 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qvym2t97h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:44:00 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 06:43:58 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 06:43:52 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1Q6hoQX25296898
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 26 Feb 2019 06:43:51 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E114011C04A;
	Tue, 26 Feb 2019 06:43:50 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7BF4511C052;
	Tue, 26 Feb 2019 06:43:49 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 06:43:49 +0000 (GMT)
Date: Tue, 26 Feb 2019 08:43:47 +0200
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226060627.GG13653@xz-x1>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022606-0028-0000-0000-0000034D0EEF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022606-0029-0000-0000-0000240B6098
Message-Id: <20190226064347.GB5873@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260051
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 02:06:27PM +0800, Peter Xu wrote:
> On Mon, Feb 25, 2019 at 10:52:34PM +0200, Mike Rapoport wrote:
> > On Tue, Feb 12, 2019 at 10:56:26AM +0800, Peter Xu wrote:
> > > From: Shaohua Li <shli@fb.com>
> > > 
> > > Add API to enable/disable writeprotect a vma range. Unlike mprotect,
> > > this doesn't split/merge vmas.
> > > 
> > > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > > Cc: Rik van Riel <riel@redhat.com>
> > > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > > Cc: Mel Gorman <mgorman@suse.de>
> > > Cc: Hugh Dickins <hughd@google.com>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Signed-off-by: Shaohua Li <shli@fb.com>
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > [peterx:
> > >  - use the helper to find VMA;
> > >  - return -ENOENT if not found to match mcopy case;
> > >  - use the new MM_CP_UFFD_WP* flags for change_protection
> > >  - check against mmap_changing for failures]
> > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > > ---
> > >  include/linux/userfaultfd_k.h |  3 ++
> > >  mm/userfaultfd.c              | 54 +++++++++++++++++++++++++++++++++++
> > >  2 files changed, 57 insertions(+)
> > > 
> > > diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> > > index 765ce884cec0..8f6e6ed544fb 100644
> > > --- a/include/linux/userfaultfd_k.h
> > > +++ b/include/linux/userfaultfd_k.h
> > > @@ -39,6 +39,9 @@ extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
> > >  			      unsigned long dst_start,
> > >  			      unsigned long len,
> > >  			      bool *mmap_changing);
> > > +extern int mwriteprotect_range(struct mm_struct *dst_mm,
> > > +			       unsigned long start, unsigned long len,
> > > +			       bool enable_wp, bool *mmap_changing);
> > > 
> > >  /* mm helpers */
> > >  static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
> > > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > > index fefa81c301b7..529d180bb4d7 100644
> > > --- a/mm/userfaultfd.c
> > > +++ b/mm/userfaultfd.c
> > > @@ -639,3 +639,57 @@ ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
> > >  {
> > >  	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing, 0);
> > >  }
> > > +
> > > +int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
> > > +			unsigned long len, bool enable_wp, bool *mmap_changing)
> > > +{
> > > +	struct vm_area_struct *dst_vma;
> > > +	pgprot_t newprot;
> > > +	int err;
> > > +
> > > +	/*
> > > +	 * Sanitize the command parameters:
> > > +	 */
> > > +	BUG_ON(start & ~PAGE_MASK);
> > > +	BUG_ON(len & ~PAGE_MASK);
> > > +
> > > +	/* Does the address range wrap, or is the span zero-sized? */
> > > +	BUG_ON(start + len <= start);
> > 
> > I'd replace these BUG_ON()s with
> > 
> > 	if (WARN_ON())
> > 		 return -EINVAL;
> 
> I believe BUG_ON() is used because these parameters should have been
> checked in userfaultfd_writeprotect() already by the common
> validate_range() even before calling mwriteprotect_range().  So I'm
> fine with the WARN_ON() approach but I'd slightly prefer to simply
> keep the patch as is to keep Jerome's r-b if you won't disagree. :)

Right, userfaultfd_writeprotect() should check these parameters and if it
didn't it was a bug indeed. But still, it's not severe enough to crash the
kernel.

I hope Jerome wouldn't mind to keep his r-b with s/BUG_ON/WARN_ON ;-)

With this change you can also add 

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
 
> Thanks,
> 
> -- 
> Peter Xu
> 

-- 
Sincerely yours,
Mike.

