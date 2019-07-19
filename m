Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57FACC76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 08:14:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13C972184E
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 08:14:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13C972184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A92DC6B0007; Fri, 19 Jul 2019 04:14:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A43F86B0008; Fri, 19 Jul 2019 04:14:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 932328E0001; Fri, 19 Jul 2019 04:14:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 749936B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 04:14:45 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id c70so23206828ywa.20
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 01:14:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=ZJO+rwRVtH9Cvben3nmBuV70KOtDcujRiA4dKg2Cpng=;
        b=Sncdq1xYnlxUmw5nSWl7LTbjEr5Sz8Xa7ifRRGH4mBFXoEIm2zQ4ViiHqvOY76sG3m
         FibI4TKeUDWi6TA1Rj3nLBxuyTOaml7lQ1XsIw8jB55IJj0uDxsTokIqQYGNJDY4tfBc
         TRgEyHpFtDvF8Hj2R3QM70t8kQv3GdKHmT0hMC7xH1zejW57C7O2rojerWKrmgXZpbGV
         gAKAPxilIlQPRw4I+/kIz1qhp1fMfVnU0de5nsjSDjR2wMRjMmlIsMSTdMekd+Fo71S6
         eaG6YxurvwOCFVb2DeNHlW76vY2MP7QVyDxfDzG1P0Qk9GZsWTwDV4ZlBLcl6SyUABy/
         bHGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVLClPbtAanVi16rjZf/G6PYak9+V89ywPqnDeAv9Eiiw2dkj9H
	dDf7vlTb2cynktDuTltMlsGaDwI+3VUUu/JRheYMCHvf8nRFqq+9QHZ7JuyPQ1REnsem38jujTr
	hlXj4xmIs4Wm5MtGlrABMdAcGnxoZ+Aha9JkRrnbdQHMcsD+Hnvf3INGfLSxxYZoZAg==
X-Received: by 2002:a25:c5ce:: with SMTP id v197mr33087604ybe.404.1563524085248;
        Fri, 19 Jul 2019 01:14:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxU1JSYdOsV5txGiRPz1JzqF0QXdDs2FxGP4hGyVlyeGcxKyi2gLXpV4+RpqLRCc1C7Q7de
X-Received: by 2002:a25:c5ce:: with SMTP id v197mr33087589ybe.404.1563524084754;
        Fri, 19 Jul 2019 01:14:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563524084; cv=none;
        d=google.com; s=arc-20160816;
        b=RCn6YK73cngIskN++dkEtCuWtceDOOPhIw4x31c/Kq3OJ5i8ta/Rz52cJwJdnfdwyb
         DMQzIW/u7PUVbmHNBiGdFFa7MyrzUibG2xYVw5cYscWYCIfPRZymfMS4UU99E9QEde2p
         SKCK3UKbyp44mq/vMaj/7P66vf2jL/RbVgImQYdwJVNnMbflk26XNEnThnzsku7QYIhE
         BHiyW7EycylSYZpXpMiQi/1Q1W0kOOg6Hw3rbJlK1BEsoHMdVJ5/MRMFq24yyAfjBrRt
         LvVVIn9WSGji824G3mh0ErxxU2B3qkgfYrwaZmC3QPx5esqpF7ORRibFT0bGH7hf/D+1
         FooQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=ZJO+rwRVtH9Cvben3nmBuV70KOtDcujRiA4dKg2Cpng=;
        b=uMrw6r4ZS+feEfT3qhgot4hJArwce82FLpHAhRWdqJo8gsxLeI+iK1aS/2XcrhY7BV
         +bV9wqD8QrFX1QtMSeuCbpEGRXciebXgkUYinvA9tPeuIUNZEWWByjiIDXfIE9K1JrZm
         DShw8vU/MqHRc+cTqqNph9kIWdU6WgTnQHDi75ztWZ/zfNE/yXACrMDPJTGEquBMYMpU
         tKJ1Tq2K25yLELNriYHu7W1X/bxKy1h9SZGv6w39wCJ0iQVRlolJPoZ+JtkogjfA77pT
         l05KWeHRfFsXRrwoatX9l6dMIjKLecTf0Y1rLm70TJpRElsyprUpL37aJ0lsl6JeOmqj
         2V+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m81si11464925ywb.248.2019.07.19.01.14.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 01:14:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6J8CUB4134891
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 04:14:44 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2tu9upgugw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 04:14:44 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Fri, 19 Jul 2019 09:14:42 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 19 Jul 2019 09:14:38 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6J8EbSS43712524
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 19 Jul 2019 08:14:37 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0178AAE051;
	Fri, 19 Jul 2019 08:14:37 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D9FABAE056;
	Fri, 19 Jul 2019 08:14:34 +0000 (GMT)
Received: from in.ibm.com (unknown [9.124.35.65])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri, 19 Jul 2019 08:14:34 +0000 (GMT)
Date: Fri, 19 Jul 2019 13:44:32 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, linuxram@us.ibm.com,
        cclaudio@linux.ibm.com, kvm-ppc@vger.kernel.org,
        Linuxppc-dev <linuxppc-dev-bounces+janani=linux.ibm.com@lists.ozlabs.org>,
        linux-mm@kvack.org, jglisse@redhat.com, janani <janani@linux.ibm.com>,
        aneesh.kumar@linux.vnet.ibm.com, paulus@au1.ibm.com,
        sukadev@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v5 1/7] kvmppc: HMM backend driver to manage pages of
 secure guest
Reply-To: bharata@linux.ibm.com
References: <20190709102545.9187-1-bharata@linux.ibm.com>
 <20190709102545.9187-2-bharata@linux.ibm.com>
 <29e536f225036d2a93e653c56a961fcb@linux.vnet.ibm.com>
 <20190710134734.GB2873@ziepe.ca>
 <20190711050848.GB12321@in.ibm.com>
 <20190719064641.GA29238@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190719064641.GA29238@infradead.org>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19071908-0012-0000-0000-00000334517F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071908-0013-0000-0000-0000216DD618
Message-Id: <20190719081432.GA4077@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-19_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=916 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907190094
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 11:46:41PM -0700, Christoph Hellwig wrote:
> On Thu, Jul 11, 2019 at 10:38:48AM +0530, Bharata B Rao wrote:
> > Hmmm... I still find it in upstream, guess it will be removed soon?
> > 
> > I find the below commit in mmotm.
> 
> Please take a look at the latest hmm code in mainline, there have
> also been other significant changes as well.

Yes, my next version of this patchset will be based on those recent
HMM related changes.

Regards,
Bharata.

