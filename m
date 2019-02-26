Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEC21C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 08:00:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4B0D2147C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 08:00:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4B0D2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36BBC8E0006; Tue, 26 Feb 2019 03:00:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31BAB8E0002; Tue, 26 Feb 2019 03:00:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E4FD8E0006; Tue, 26 Feb 2019 03:00:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D3EC08E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:00:45 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id t26so8991888pgu.18
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 00:00:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=OM7SqJ6wa4yAG1IO5UjQZw1SOlSwLyas5UqMYyRIneQ=;
        b=bw54GWFqTMoizSPDBh+SoXD3mr3Dsc8l3cbIEtDevoqefh0UcHawr+DJNFSShOl/VR
         G/aQqFrMPcrN+MaLocY7nMDJBb8k66pd8oFMrpbLZ6fScS9I5JpL0+EWFuaqaS+1Xh3o
         aOhctCNt66jfZiqvF6Wx4Y1gRssl9hBDGGJi/lF4xYdeVdWRR0IZLwOsgwIdrMK65Se6
         CbdtTjoy/wo0jaS2PphLCdyFq0f05I7pJYdcM8sLOGmLAc6ptfWitPepWkg2RrLmbsUn
         LZ89eDcuzyKUefjhjp1DOQWFjuppX7eWcAcUCMXYjB4J08ZiKVcbCUh6cJlXYdm4ElaO
         1/SQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaSw4cQq07WFsMTBa3Mn3/hW/rg0VnPj4HVtL2rhUKYnA8mjVEe
	wy+q8GkwChH7j491WH2GJVlSMdCohxJ8txM6YPr98zBZaX7DDQ+gd4skhi62kSTrXmoY9osrzoJ
	ieEiHo6LWnfj1EnMZ7Is8TjT28/QQriG21FIfBrFIGqgxzdZGwgGtBinMoKnHxFrCCg==
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr25107300plp.34.1551168045472;
        Tue, 26 Feb 2019 00:00:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ1Cgn8z54NbQ3aPBu5vpqV3DvqOA193xDk33Yryo2aydnNzAlyhcNCeSNhJsVfVUTEjdHM
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr25107207plp.34.1551168044370;
        Tue, 26 Feb 2019 00:00:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551168044; cv=none;
        d=google.com; s=arc-20160816;
        b=pna/kal9mqQSa279wfwYVE/C2JKz6i1WP8v3OTOtpBkmN+fTHAgHrbMdztCVBEJqTV
         t/k0beomQNarc7UYU6x5Js4MHgpRtWKC7GRBnYjpj4me23RwvgUSZg9QSz5o+cfb6o1Z
         CSSBszxAzUvLt0aqe0HrfbLPjq+TZtfINGxU9Yfujn+cuxaAdKiOezk7I5T+dUkBUGF/
         A/eDlSwpYzj+N1u8mhjQcc5Ri5NI6kJfTN9nHW6eP8Bv9eccCL5ocjNRo5UDN3qB24jd
         2RR/EzYl8VUOc2UTfeAVX+wi7xGwAss2Z+i7hgaFSgeUkrMZ8MwAgm2iDunEpAwx0PeR
         Jg1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=OM7SqJ6wa4yAG1IO5UjQZw1SOlSwLyas5UqMYyRIneQ=;
        b=PTDiZM3dAKgfloXXH8qDEOh2q51HVEc4/oId7UtXDyJmfzSxTrXz2PV20UZsgfzeOK
         /1r1ff9l+cpeRL/QxqHwlgXEiwhV0DXSWkFIokez6T/F21uUmhm+Ek/eBeNlYDVnhRC1
         m67rszP0Uwvz3OylBxCW057Lg5JcDSgnCTeOU5eD4P4WQgrAWlH4ODT3S2aPHABUzSYz
         HBH6wy1bqSUdilQz2JkLTZvaxavLIsDPMbPP14mjX8elh8V/1j78OYHWv18+9jpn7w1I
         IHHRI0tNrIzdTQERwAIB9AQVd8gn8v9/sPVD2HyuVV+VJj+fGkGL2YvF2aTLFv3xuYlm
         1U1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x14si11199154plr.259.2019.02.26.00.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 00:00:44 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1Q7wjgR027558
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:00:43 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qw00jckbs-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:00:42 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 08:00:40 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 08:00:35 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1Q80YG753346316
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 26 Feb 2019 08:00:34 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D9C25AE053;
	Tue, 26 Feb 2019 08:00:32 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8A3EBAE056;
	Tue, 26 Feb 2019 08:00:31 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 08:00:31 +0000 (GMT)
Date: Tue, 26 Feb 2019 10:00:29 +0200
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
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 23/26] userfaultfd: wp: don't wake up when doing write
 protect
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-24-peterx@redhat.com>
 <20190225210934.GE10454@rapoport-lnx>
 <20190226062424.GH13653@xz-x1>
 <20190226072933.GF5873@rapoport-lnx>
 <20190226074117.GL13653@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226074117.GL13653@xz-x1>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022608-0016-0000-0000-0000025AF7CF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022608-0017-0000-0000-000032B55890
Message-Id: <20190226080029.GH5873@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260061
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 03:41:17PM +0800, Peter Xu wrote:
> On Tue, Feb 26, 2019 at 09:29:33AM +0200, Mike Rapoport wrote:
> > On Tue, Feb 26, 2019 at 02:24:52PM +0800, Peter Xu wrote:
> > > On Mon, Feb 25, 2019 at 11:09:35PM +0200, Mike Rapoport wrote:
> > > > On Tue, Feb 12, 2019 at 10:56:29AM +0800, Peter Xu wrote:
> > > > > It does not make sense to try to wake up any waiting thread when we're
> > > > > write-protecting a memory region.  Only wake up when resolving a write
> > > > > protected page fault.
> > > > > 
> > > > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > > > > ---
> > > > >  fs/userfaultfd.c | 13 ++++++++-----
> > > > >  1 file changed, 8 insertions(+), 5 deletions(-)
> > > > > 
> > > > > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > > > > index 81962d62520c..f1f61a0278c2 100644
> > > > > --- a/fs/userfaultfd.c
> > > > > +++ b/fs/userfaultfd.c
> > > > > @@ -1771,6 +1771,7 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> > > > >  	struct uffdio_writeprotect uffdio_wp;
> > > > >  	struct uffdio_writeprotect __user *user_uffdio_wp;
> > > > >  	struct userfaultfd_wake_range range;
> > > > > +	bool mode_wp, mode_dontwake;
> > > > > 
> > > > >  	if (READ_ONCE(ctx->mmap_changing))
> > > > >  		return -EAGAIN;
> > > > > @@ -1789,18 +1790,20 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> > > > >  	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
> > > > >  			       UFFDIO_WRITEPROTECT_MODE_WP))
> > > > >  		return -EINVAL;
> > > > > -	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
> > > > > -	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
> > > > > +
> > > > > +	mode_wp = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP;
> > > > > +	mode_dontwake = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE;
> > > > > +
> > > > > +	if (mode_wp && mode_dontwake)
> > > > >  		return -EINVAL;
> > > > 
> > > > This actually means the opposite of the commit message text ;-)
> > > > 
> > > > Is any dependency of _WP and _DONTWAKE needed at all?
> > > 
> > > So this is indeed confusing at least, because both you and Jerome have
> > > asked the same question... :)
> > > 
> > > My understanding is that we don't have any reason to wake up any
> > > thread when we are write-protecting a range, in that sense the flag
> > > UFFDIO_WRITEPROTECT_MODE_DONTWAKE is already meaningless in the
> > > UFFDIO_WRITEPROTECT ioctl context.  So before everything here's how
> > > these flags are defined:
> > > 
> > > struct uffdio_writeprotect {
> > > 	struct uffdio_range range;
> > > 	/* !WP means undo writeprotect. DONTWAKE is valid only with !WP */
> > > #define UFFDIO_WRITEPROTECT_MODE_WP		((__u64)1<<0)
> > > #define UFFDIO_WRITEPROTECT_MODE_DONTWAKE	((__u64)1<<1)
> > > 	__u64 mode;
> > > };
> > > 
> > > To make it clear, we simply define it as "DONTWAKE is valid only with
> > > !WP".  When with that, "mode_wp && mode_dontwake" is indeed a
> > > meaningless flag combination.  Though please note that it does not
> > > mean that the operation ("don't wake up the thread") is meaningless -
> > > that's what we'll do no matter what when WP==1.  IMHO it's only about
> > > the interface not the behavior.
> > > 
> > > I don't have a good way to make this clearer because firstly we'll
> > > need the WP flag to mark whether we're protecting or unprotecting the
> > > pages.  Later on, we need DONTWAKE for page fault handling case to
> > > mark that we don't want to wake up the waiting thread now.  So both
> > > the flags have their reason to stay so far.  Then with all these in
> > > mind what I can think of is only to forbid using DONTWAKE in WP case,
> > > and that's how above definition comes (I believe, because it was
> > > defined that way even before I started to work on it and I think it
> > > makes sense).
> > 
> > There's no argument how DONTWAKE can be used with !WP. The
> > userfaultfd_writeprotect() is called in response of the uffd monitor to WP
> > page fault, it asks to clear write protection to some range, but it does
> > not want to wake the faulting thread yet but rather it will use uffd_wake()
> > later.
> > 
> > Still, I can't grok the usage of DONTWAKE with WP=1. In my understanding,
> > in this case userfaultfd_writeprotect() is called unrelated to page faults,
> > and the monitored thread runs freely, so why it should be waked at all?
> 
> Exactly this is how I understand it.  And that's why I wrote this
> patch to remove the extra wakeup() since I think it's unecessary.
> 
> > 
> > And what happens, if the thread is waiting on a missing page fault and we
> > do userfaultfd_writeprotect(WP=1) at the same time?
> 
> Then IMHO the userfaultfd_writeprotect() will be a noop simply because
> the page is still missing.  Here if with the old code (before this
> patch) we'll probably even try to wake up this thread but this thread
> should just fault again on the same address due to the fact that the
> page is missing.  After this patch the monitored thread should
> continue to wait on the missing page.

So, my understanding of what we have is:

userfaultfd_writeprotect() can be used either to mark a region as write
protected or to resolve WP page fault.
In the first case DONTWAKE does not make sense and we forbid setting it
with WP=1.
In the second case it's the uffd monitor decision whether to wake up the
faulting thread immediately after #PF is resolved or later, so with WP=0 we
allow DONTWAKE.

I suggest to extend the comment in the definition of 
'struct uffdio_writeprotect' to something like

/*
 * Write protecting a region (WP=1) is unrelated to page faults, therefore
 * DONTWAKE flag is meaningless with WP=1.
 * Removing write protection (WP=0) in response to a page fault wakes the
 * faulting task unless DONTWAKE is set.
 */
 
And a documentation update along these lines would be appreciated :)

> Thanks,
> 
> -- 
> Peter Xu
> 

-- 
Sincerely yours,
Mike.

