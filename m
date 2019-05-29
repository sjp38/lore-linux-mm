Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2B85C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:38:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA0F72407A
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:38:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WrBZnM6Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA0F72407A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47C0D6B0266; Wed, 29 May 2019 14:38:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 451B26B026A; Wed, 29 May 2019 14:38:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 341266B026B; Wed, 29 May 2019 14:38:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 005D96B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:38:33 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z10so502927pgf.15
        for <linux-mm@kvack.org>; Wed, 29 May 2019 11:38:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=THamC/necnAG3k0b6m2lzotQxZzYf7wS5P936VQIGeY=;
        b=oEig7per8bH07WvudBIB9yT83m+xu9nUMH481JP8Vigiy2jM+QXIMQgCgdtWB2PrDu
         ucXeduw711N5UNfV95noPr2kJ1IzCASbrgl3saCC1r4jOawq1+kSbdOoXPZdQ3xjcy1r
         MRDn57PAY1EaS0pwHlzizX3OCOln2YsN+v5Vyz8LWOP93OQSWv/cjSpLcmLK6jHU5P0M
         QEqJfcu1HKAOtLNHEyvbEm/nOglfLDRaB6TslV4ukEfGP2VBTd956rX9zgLYZftPxev/
         yXGTSSV37NRyz0xAuGWMZuDjh1gSnKEjnokQn1SRET06qDMPjkHbhuyZE31mWygpk9CG
         NYRA==
X-Gm-Message-State: APjAAAXbNmJdguNl6YumHpP6KatlaV/xk7rwGbL4KBfkvZdAfEV5HHVG
	u4GQTBVTtaBn0Pam2FhCYub9TOVVDbKbgrGXCy/X6dYdd5KNzXFty5y6rC7HLEZ4Ttb8MiUu9IA
	HunV3qJAHt8FaWLRcAO/7mH61VirAe3iRThOsJZ59uPyj2xXt8XxnaPPX8lyWUwJyKw==
X-Received: by 2002:a65:500d:: with SMTP id f13mr65497235pgo.151.1559155112390;
        Wed, 29 May 2019 11:38:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfERysAqtYgjwFbIjfkHNJdHkK4fhg+bycKpU8XjyM279MxXys1V0j3tVaFWp5OcMFbK57
X-Received: by 2002:a65:500d:: with SMTP id f13mr65497117pgo.151.1559155111140;
        Wed, 29 May 2019 11:38:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559155111; cv=none;
        d=google.com; s=arc-20160816;
        b=YozeDAzYLMEftUfQQ14W52AfZQnlxhOhGv61q2yJmqv5GaKcB5gsX/Gi/2ve5exsS1
         0JjzeiOtyummE161i//0Rtj05eTv51asHJxEy2Pel+C9I1RxNwOQDA4KSY7PvpslgO3z
         civvmTmx1IwXdwVdcSGq36CmuDAhosJl30Q8Tog397XYOi3jDIjB0bL/VZob9Dqm9iWt
         LePTlAZDP9TCMWkjutmsnDRnBHO0hKf3IPNSPWl2tOYUmlePGdfuf2Dk16jQHzMblQDQ
         m9S1N4behZgqT4szZFlE5/lGAESiHghMVZ9H4AuI7RHxx8cYRhMObnbrS7Pa5JNb2zv8
         PxSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=THamC/necnAG3k0b6m2lzotQxZzYf7wS5P936VQIGeY=;
        b=pQBimaNZ1oTwIvGXEccMd0vTXLlcvk93a+SkEcLbp6mptZawersuoXrW1Yk+40zsAS
         ODVNWk3c+Z2KeNYW9Rg/YPUt5PgQxnUxTL5PeK7NqC908nl3FfWi/b5sMuSUVFDRi73x
         TfDTk3DTPyKA6GelMdrEGapfnt8vvPU0wRxHfqIZJY5Ll3KzOBGpdcEmy1Q2E/hSuYW7
         MlNGCjYllXC8cHk89nQ8MWU0zwAb58Lj/GymKrNoXd2wpKu89YhxXKqxV4PHNk2M8e/J
         5wW+xk4ACWnnCh0E0VZADZFPPNKbVuqOAtyxG+wxD07FVG6llD8W38bClEfonFYNK+8A
         Ynjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WrBZnM6Z;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t67si234528pjb.22.2019.05.29.11.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 11:38:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WrBZnM6Z;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4TIXRk1051803;
	Wed, 29 May 2019 18:38:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=THamC/necnAG3k0b6m2lzotQxZzYf7wS5P936VQIGeY=;
 b=WrBZnM6ZmVcJlPylNNIR/dfOAgxQ1n5mBVtox4d3xjQyTPWqyy6eMNHnrmBnlkjatlvA
 uGOysuC9TQIkhHoRn4A0EY8PusDh25gpV/Wi4bOglzrKwaHlZYMsOaCkMAEh7Oc1zG4H
 o5aBY3h0pke87yaD6FFtpEWCGOFT3e22OuLLNMpFqQBRqJf1s1U9+ZhsZbUHtiEJimhk
 CCZzlWi4wabkYmp44sPv7LEg5Mh5sXvNW2aC2mg7bGejM8GPo82kSDE92MGxM5yTU4Sv
 FYNjz+9EfB1A2l+UFVFPM/S+5WCUb8cfNrvM8MGDkLXLQ+KQUnKnAuC5N9DwD7JNDbJI ZQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2spw4tktvv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 18:38:10 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4TIa26f039849;
	Wed, 29 May 2019 18:36:10 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2sr31ve7qt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 18:36:09 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4TIZxGZ002287;
	Wed, 29 May 2019 18:35:59 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 29 May 2019 11:35:59 -0700
Date: Wed, 29 May 2019 14:35:59 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
        Alexey Kardashevskiy <aik@ozlabs.ru>, Alan Tull <atull@kernel.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Lameter <cl@linux.com>,
        Christophe Leroy <christophe.leroy@c-s.fr>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Jason Gunthorpe <jgg@mellanox.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
        Paul Mackerras <paulus@ozlabs.org>,
        Steve Sistare <steven.sistare@oracle.com>, Wu Hao <hao.wu@intel.com>,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm: add account_locked_vm utility function
Message-ID: <20190529183559.jzkpvbdiimnp3n2m@ca-dmjordan1.us.oracle.com>
References: <de375582-2c35-8e8a-4737-c816052a8e58@ozlabs.ru>
 <20190524175045.26897-1-daniel.m.jordan@oracle.com>
 <20190529180547.GA16182@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529180547.GA16182@iweiny-DESK2.sc.intel.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=18 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905290120
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=18 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905290120
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 11:05:48AM -0700, Ira Weiny wrote:
> On Fri, May 24, 2019 at 01:50:45PM -0400, Daniel Jordan wrote:
> > +static inline int account_locked_vm(struct mm_struct *mm, unsigned long pages,
> > +				    bool inc)
> > +{
> > +	int ret;
> > +
> > +	if (pages == 0 || !mm)
> > +		return 0;
> > +
> > +	down_write(&mm->mmap_sem);
> > +	ret = __account_locked_vm(mm, pages, inc, current,
> > +				  capable(CAP_IPC_LOCK));
> > +	up_write(&mm->mmap_sem);
> > +
> > +	return ret;
> > +}
> > +
...snip...
> > +/**
> > + * __account_locked_vm - account locked pages to an mm's locked_vm
> > + * @mm:          mm to account against, may be NULL
> 
> This kernel doc is wrong.  You dereference mm straight away...
...snip...
> > +
> > +	locked_vm = mm->locked_vm;
> 
> here...
> 
> Perhaps the comment was meant to document account_locked_vm()?

Yes, the comment got out of sync when I moved the !mm check outside
__account_locked_vm.  Thanks for catching, will fix.

