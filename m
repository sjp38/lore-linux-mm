Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2CCEC10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 12:37:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EB362184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 12:37:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EB362184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 138B66B0003; Wed, 20 Mar 2019 08:37:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 098206B0006; Wed, 20 Mar 2019 08:37:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2C646B0007; Wed, 20 Mar 2019 08:37:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7216B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:37:10 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h15so2382100pfj.22
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 05:37:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=SABs/0AeBYS/+bUfulEB6XWTskl33r0TyHFFO9l5Juo=;
        b=SOZcY6EoG0gznNF4ji4zEP20/tGy3aumqQPS+AnsvmOoJf9udTWDKlJF0ENApp7WGm
         xp1zwEZDB5thgOZw68ASGdNrPDPPsf4myPbj65SR6bKwywXJtcKotRGQ17RIBKSR9lgn
         evkQYTrTbg4FReU5eRC+DTiioKdvQErd6rhoF5muLzUTT+zN2WceO3TYIP0nOc1ysPs6
         aMrepF2BLmLZVUkNMmK2lqISZBgVqepbK+Gye1KlIygHrhKWB+yEp/QoBsDqpn51vWfk
         08WKCCdHXLXYgFC/IWZF9fhv9RZDVa5DC80nq58+xnzE6jHDnaJOIFuIGDfiNweAaz6L
         k5Gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXUuTIaZvRAAN6BsCHU0dFw2vCLOrOUqGEZYbugZwuGhKSC2ypg
	y/XBvBa+bI2UDpwQU9z27jU8rqNbvQyIJDY/K/0hnPC9jBXaZvWgMf1n9EvV5RqaLp3OI4c+wIH
	LqpzdQwSxb3SIoXK5f0GzTumfxXPEQsObgS27fyWxNsS+cdRav7yL1iAOg1dyGtqYjg==
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr7745555plk.126.1553085430228;
        Wed, 20 Mar 2019 05:37:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIsqHny610OEfmxPPlSYACBaFdiXJ+aCGMb6iGemzYqtCnXdedK9s/C/WcK1Mk6qoSSDF0
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr7745491plk.126.1553085429566;
        Wed, 20 Mar 2019 05:37:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553085429; cv=none;
        d=google.com; s=arc-20160816;
        b=KhwtdIgS2QQGMeuVA0+SS3lO5MR09QUzBQ3KLii50x6I6ne/DzlHrUVIXTzx2jF2Sw
         2BgtQA0RJ3xsGI29FO2sT3L+RPzVb8aO0C9VeBJK1CAg/QQLNVIoo0x5Sq3DxlCJELCS
         KNFXTIyeP/Xyti6fnQZjP1KxZel6WTvkk50T2v/kk+5qdk2UE7B/v3j5uumGh8fK4VxG
         K/HYRLx9fW1PnhaykG6YbBUbGqV761yRwQcw8BTKra2Xzc7bQll48mEhgTXKw1PaY64P
         YhZE2UV5QPCDzZ7JcoVCjdNiVF1jwBjMo40QLqk9RAykowO/xoMAmBDqGyXmScUNwRw2
         xFAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=SABs/0AeBYS/+bUfulEB6XWTskl33r0TyHFFO9l5Juo=;
        b=lAd1b3Nc0KIFCT4SLFEjTKN5pouml3mbC4ec2019a+iieNJO2XzRSfP5w5t8QGghNm
         FPM96jmUYw+rE3nTHWcBUZrc8yfOrTu4kqU8gMHqRST/MwOxmlApVjLSTUbNsCcwyZwk
         /jv1axEwBhRhIogdkvUGUHxDRBBHpQdHYEliZGzbfngjxqElippO/G74g7Wt14bmBqAt
         HvwcfKBSL7jjyF/RQwUZurw9yR12Ioe1rq58c93cLUC7+skIwPBOU5acA+6f3VrFEXrd
         klrqOTgWg9AYDUEfW9ZEqvMNXeIrewOAH0hPCLAwXW2JHJ3f8orq5K9ICtSkRM8TGzvY
         TxKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e190si1607293pfc.63.2019.03.20.05.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 05:37:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2KCJXvS022376
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:37:08 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rbkxcp9gg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:37:08 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 20 Mar 2019 12:37:00 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 20 Mar 2019 12:36:57 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2KCb17843581486
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Mar 2019 12:37:01 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 368A4A4055;
	Wed, 20 Mar 2019 12:37:01 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 66C66A404D;
	Wed, 20 Mar 2019 12:37:00 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 20 Mar 2019 12:37:00 +0000 (GMT)
Date: Wed, 20 Mar 2019 14:36:58 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Oscar Salvador <osalvador@suse.de>, Baoquan He <bhe@redhat.com>,
        linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        pasha.tatashin@oracle.com, mhocko@suse.com, rppt@linux.vnet.ibm.com,
        richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320111959.GV19508@bombadil.infradead.org>
 <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
 <20190320122243.GX19508@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320122243.GX19508@bombadil.infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032012-0008-0000-0000-000002CF88EF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032012-0009-0000-0000-0000223BA054
Message-Id: <20190320123658.GF13626@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-20_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=845 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903200097
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 05:22:43AM -0700, Matthew Wilcox wrote:
> On Wed, Mar 20, 2019 at 01:20:15PM +0100, Oscar Salvador wrote:
> > On Wed, Mar 20, 2019 at 04:19:59AM -0700, Matthew Wilcox wrote:
> > > On Wed, Mar 20, 2019 at 03:35:38PM +0800, Baoquan He wrote:
> > > >  /*
> > > > - * returns the number of sections whose mem_maps were properly
> > > > - * set.  If this is <=0, then that means that the passed-in
> > > > - * map was not consumed and must be freed.
> > > > + * sparse_add_one_section - add a memory section
> > > > + * @nid:	The node to add section on
> > > > + * @start_pfn:	start pfn of the memory range
> > > > + * @altmap:	device page map
> > > > + *
> > > > + * Return 0 on success and an appropriate error code otherwise.
> > > >   */
> > > 
> > > I think it's worth documenting what those error codes are.  Seems to be
> > > just -ENOMEM and -EEXIST, but it'd be nice for users to know what they
> > > can expect under which circumstances.
> > > 
> > > Also, -EEXIST is a bad errno to return here:
> > > 
> > > $ errno EEXIST
> > > EEXIST 17 File exists
> > > 
> > > What file?  I think we should be using -EBUSY instead in case this errno
> > > makes it back to userspace:
> > > 
> > > $ errno EBUSY
> > > EBUSY 16 Device or resource busy
> > 
> > We return -EEXIST in case the section we are trying to add is already
> > there, and that error is being caught by __add_pages(), which ignores the
> > error in case is -EXIST and keeps going with further sections.
> > 
> > Sure we can change that for -EBUSY, but I think -EEXIST makes more sense,
> > plus that kind of error is never handed back to userspace.
> 
> Not returned to userspace today.  It's also bad precedent for other parts
> of the kernel where errnos do get returned to userspace.

There are more than a thousand -EEXIST in the kernel, I really doubt all of
them mean "File exists" ;-)

-- 
Sincerely yours,
Mike.

