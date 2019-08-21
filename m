Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5540FC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:29:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 247A5206BA
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:29:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 247A5206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAF3D6B02ED; Wed, 21 Aug 2019 11:29:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B39B86B02EE; Wed, 21 Aug 2019 11:29:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FF2B6B02EF; Wed, 21 Aug 2019 11:29:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0006.hostedemail.com [216.40.44.6])
	by kanga.kvack.org (Postfix) with ESMTP id 77F576B02ED
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:29:39 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1348B814F
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:29:39 +0000 (UTC)
X-FDA: 75846819678.01.tree13_36ff3415b8430
X-HE-Tag: tree13_36ff3415b8430
X-Filterd-Recvd-Size: 4876
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:29:37 +0000 (UTC)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7LFMgBt021008
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:29:36 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uh66m7qak-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:29:36 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 21 Aug 2019 16:29:33 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 21 Aug 2019 16:29:30 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7LFTTFv31391964
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 21 Aug 2019 15:29:29 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A313E11C050;
	Wed, 21 Aug 2019 15:29:29 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CCED811C04C;
	Wed, 21 Aug 2019 15:29:28 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.59])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 21 Aug 2019 15:29:28 +0000 (GMT)
Date: Wed, 21 Aug 2019 18:29:27 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
        x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: consolidate pgtable_cache_init() and pgd_cache_init()
References: <1566400018-15607-1-git-send-email-rppt@linux.ibm.com>
 <20190821151544.GC28819@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821151544.GC28819@bombadil.infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19082115-0016-0000-0000-000002A1280D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082115-0017-0000-0000-000033015D0E
Message-Id: <20190821152926.GF26713@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-21_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=889 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908210162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 08:15:44AM -0700, Matthew Wilcox wrote:
> On Wed, Aug 21, 2019 at 06:06:58PM +0300, Mike Rapoport wrote:
> > +++ b/arch/alpha/include/asm/pgtable.h
> > @@ -362,7 +362,6 @@ extern void paging_init(void);
> >  /*
> >   * No page table caches to initialise
> >   */
> > -#define pgtable_cache_init()	do { } while (0)
> 
> Delete the comment too?
> 
> > +++ b/arch/arc/include/asm/pgtable.h
> > @@ -398,7 +398,6 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
> >  /*
> >   * No page table caches to initialise
> >   */
> > -#define pgtable_cache_init()   do { } while (0)
> 
> ditto
> 
> > +++ b/arch/arm/include/asm/pgtable.h
> > @@ -368,7 +368,6 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
> >  #define HAVE_ARCH_UNMAPPED_AREA
> >  #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
> >  
> > -#define pgtable_cache_init() do { } while (0)
> >  
> >  #endif /* !__ASSEMBLY__ */
> 
> delete one of the two blank lines?
> 
> > +++ b/arch/c6x/include/asm/pgtable.h
> > @@ -62,7 +62,6 @@ extern unsigned long empty_zero_page;
> >  /*
> >   * No page table caches to initialise
> >   */
> > -#define pgtable_cache_init()   do { } while (0)
> 
> delete comment ... more of these.

Actually, most of them :)
Thanks for spotting this.
 

-- 
Sincerely yours,
Mike.


