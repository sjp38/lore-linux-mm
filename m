Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A221C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:40:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21E82206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:40:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21E82206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B80718E0003; Wed, 31 Jul 2019 02:40:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B08E38E0001; Wed, 31 Jul 2019 02:40:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A9358E0003; Wed, 31 Jul 2019 02:40:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 621128E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:40:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i2so42581101pfe.1
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 23:40:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=mpMM3JBur1Z8vQXVArkHpieI8Q7Ew2TC70K5Xe7/Zc8=;
        b=bz/ALJsjG6MI31DO85iFrO/mzp8rDh+zj2cXgM8smXaOGwecjrvALj2sHkQI5+jBe0
         K3AgWh6UPglNh5tZgRnL0C7TEps+3LFzAhcShVMucMFFmYprsB+q9ISXpNLCzHJC0IqR
         VJrpalHRbeLGC1wgxBhWsLvCR5wa6IFnJ1aY5NhXWCTQ+Vc+uaNrb7i3MKibqyYslxhO
         z+WGu+xbasoRWws0ML3cDb3cfbLp7xlsOB37ExkJpdLEBNXZMfYp6NmeAsnfBTeSz5ru
         choOP96tbLSO/NIqCasnRrMStHyA8cfySx1t3qIbuTnJ9fEdOWPWXGFMECH/1F9vmmHU
         FQsw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXT5naAyDPiZWzjHTXjSmlAlRGA6MGJlTLn47Qr6TGrxMEGvD3u
	aAu1sPj1CZJKb6oUUT5Z6O4faziNG3N4UC+Q03xFj+cbOasgWNl9tyZxlZnzkBbmwM8E9JyFxs5
	DXRGQr4+BbwpowgKt2nN687UoOhzxiTvXtTo/ao1fGSs3PgzDDWOWKELbSOtQmck=
X-Received: by 2002:a17:90a:e397:: with SMTP id b23mr1274672pjz.140.1564555224101;
        Tue, 30 Jul 2019 23:40:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4Fd5NArWZau055KG0t8SkUezzVXC443IY5CZZYXEXV7Ilr7+fl2hWsKgB5HlRgW9U6QL+
X-Received: by 2002:a17:90a:e397:: with SMTP id b23mr1274617pjz.140.1564555223258;
        Tue, 30 Jul 2019 23:40:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564555223; cv=none;
        d=google.com; s=arc-20160816;
        b=kTxvJGlfqNDaFAo89vDu8js6xt9udkYLTRl8Za+lHp2k/LFUFK3QxPRHna9NL8/vUg
         Yo4jynubcE3fLCLrKheyxbW5yXPiLHgJ/LJN5M1iXq5kti83/Wzv+j8inY/7u96pm4U9
         LbBY0Qn9zVl8TX+Zd0M+vsyAl3Chkt5838SgY/Drsn1qYw2aJxViO4Z93AZajKdhyQov
         8W4fiyzEXWeJp+uPyqSph4oFB6IYYqG1fr8xKsJqwY1TzbCHYaNDiDSwGX8rxU95urGW
         dL+UcTSbuMb+xxbtr469FHRehldsqvhjz1gihuOhxP6xzBSuYzE5b23vcmgXfZWJGWNI
         MPCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=mpMM3JBur1Z8vQXVArkHpieI8Q7Ew2TC70K5Xe7/Zc8=;
        b=NsV8qee3MlOrolt3SqNISaETTYHt5OkifnI3w3y9R7C+sV+QDG6uX1T23GFvSWBlM5
         4NjaObI9tU6kfFeENy2u3mjcexk++k3hZx8l3ipXe9KdFKQFKswnCkLBFevhkcd6L4+S
         V9rUwRKan8HQaPx0A5DZdr75/aApfJDAdQO3+xCXaUIqHMXg+H51+wbw3rlgf1/vPIJ3
         /q7Ph7Y8gTJUZLMBPemyVgT1uKILvF8Yw1SDXAkHNM0uAcjORIoWUIdvBaMk7zsf8GjO
         YvWK4Xgj2TWCL7ExUg3MD0yHhg8R/7TAU+npRiepFzuqgBVjQBUUGS3DsfG0IZLKaw4L
         EBBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l44si791460pjb.23.2019.07.30.23.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 23:40:23 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6V6avp6090251
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:40:22 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u34gdb8p5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:40:22 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 31 Jul 2019 07:40:20 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 31 Jul 2019 07:40:16 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6V6eFDo55312580
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 06:40:15 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1DA52A4069;
	Wed, 31 Jul 2019 06:40:15 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 63AD8A4040;
	Wed, 31 Jul 2019 06:40:13 +0000 (GMT)
Received: from linux.vnet.ibm.com (unknown [9.126.150.29])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with SMTP;
	Wed, 31 Jul 2019 06:40:13 +0000 (GMT)
Date: Wed, 31 Jul 2019 12:10:12 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        akpm@linux-foundation.org, matthew.wilcox@oracle.com,
        kirill.shutemov@linux.intel.com, oleg@redhat.com, kernel-team@fb.com,
        william.kucharski@oracle.com
Subject: Re: [PATCH v11 2/4] uprobe: use original page when all uprobes are
 removed
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20190730193100.2295258-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190730193100.2295258-1-songliubraving@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-TM-AS-GCONF: 00
x-cbid: 19073106-0028-0000-0000-0000038985C1
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19073106-0029-0000-0000-00002449D54E
Message-Id: <20190731064012.GA11365@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-31_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=923 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907310069
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Song Liu <songliubraving@fb.com> [2019-07-30 12:30:59]:

> Currently, uprobe swaps the target page with a anonymous page in both
> install_breakpoint() and remove_breakpoint(). When all uprobes on a page
> are removed, the given mm is still using an anonymous page (not the
> original page).
> 
> This patch allows uprobe to use original page when possible (all uprobes
> on the page are already removed, and the original page is in page cache
> and uptodate).
> 
> As suggested by Oleg, we unmap the old_page and let the original page
> fault in.
> 
> Suggested-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>

Looks good to me.

Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

-- 
Thanks and Regards
Srikar Dronamraju

