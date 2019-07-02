Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9F7AC5B578
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 03:34:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9C8221479
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 03:34:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9C8221479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EB986B0005; Mon,  1 Jul 2019 23:34:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 376B28E0003; Mon,  1 Jul 2019 23:34:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EF568E0002; Mon,  1 Jul 2019 23:34:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECA1B6B0005
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 23:34:04 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id y205so1511599ywy.19
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 20:34:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=SsukyqT7aa9hL3VMDZOys8cGXk1QoLyMoYZQeS81ZdU=;
        b=MynFwTQdw7wnylyuVuKY4sKOBOTHV3HGOi37zlSdxXLnS34hPDvw2xwIz3OtXLpX9T
         q7Z9tGFp0KdvgzAGMVdqeY7XuyzcPpSJvSFYLr5gR5HMB2ErhSMbQkWaBAoP2Xa5w0pw
         AehIsyXL0GrusD0ZqjytrU+whMf8UwNS+X0OdK1VGDOWARyd11e+rDdF22hRtRK0Kwuk
         cgESayTzdJBl9aBm8R267M4QIUZevDP887EeFdnCKbEN61x658oghjymOz6emXZnB1i3
         NaQY9dH44nWiFBV824I85Y7PJ25U0/bEWsytbPE+PUKsV/m7yGN7Gl62Jlothw/RiX9Z
         HrEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXgazQyYDKvYkMr/cMTEJFks3PyFdkUM6WYJ/rrh4FDTqhujr/T
	NMsAqCreAh7VYhgU8WpXpwQcAqcxU6MdTZtRGebERJg84AYddr2NhKyNhfdGXLW/wO4Zz4hfcxi
	MxhY9HDGo5nkOtrcIb8XDQ6p9td0r9MEdd5MTvSWxnCaZczwqCjACP2BctqG70mP8fQ==
X-Received: by 2002:a25:358a:: with SMTP id c132mr17943364yba.36.1562038444643;
        Mon, 01 Jul 2019 20:34:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy18bmq9X1+f92GzfyaIh+cy4Yjcp0+uIOO48HnjD0npTxOoJ73QP2UWSr6tRx1F4bIbrwC
X-Received: by 2002:a25:358a:: with SMTP id c132mr17943347yba.36.1562038444080;
        Mon, 01 Jul 2019 20:34:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562038444; cv=none;
        d=google.com; s=arc-20160816;
        b=NxwRCoUZrQa5pu7qRzZl17L1bI7IVLDRCeykoEaB01okX95vSu2jIu0F5SaDr+N5fr
         x+3zs7fGHEU1tT9ojHx1R4c6QjdOl3I0hQRVSYUS9x4qhbMpEIpvKXhgVsWbdllzvzQu
         6k4xgvQB2VBA1tKwO3VzIyoI7hZOWvJSAylDUZfBat00whjTyWhoX0mNhuQy/tSFvt6l
         uzg0/0fc2MXXQTkSi9eRqSb5ptbZtVKe8a+jtav+xmItdmcdKKw0aQzNLFit2neLD8PW
         I+bykDBSSPv8vddgOQgBlZ8cUpHeTVQZ7c7YxwwfYMub96D/LIxYYAWtwojyb7valap5
         7KtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=SsukyqT7aa9hL3VMDZOys8cGXk1QoLyMoYZQeS81ZdU=;
        b=VaO0A3hf0erc0WZ1URemgUA4zM1LREppGS/6MeqPjZZT2d1THcOJGkoMPUy8xbTQY8
         vXT1Ertz318X9639gtxfFf6m5JMKQU7GMHNnac2Y+R+DN94QDLqtiaNv4avEjH2wG/ZP
         NblkMW2HxpK12JJYZISNIXi57Sl1SP6zOBXYm6aiPeL/4Qqnxr2DiDgzdCayWzHlVmtl
         PlgoiJP0bw2jBwW2ZMTQZFIfiWRLMJq5lOk+ilvsZzCy9bRFbDz8rcWrfb3afRRna5BO
         Mby1WfmsBF2Zj+lj5GQ4w8zaBV3Kyw5bQKJyZo34BtPRicxsJmGZBAcvq3hHnqlRLkHi
         cHJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l139si5193563ywl.22.2019.07.01.20.34.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 20:34:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x623X9O8122282
	for <linux-mm@kvack.org>; Mon, 1 Jul 2019 23:34:03 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2tfx8y2asr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 Jul 2019 23:34:03 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 2 Jul 2019 04:34:02 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 2 Jul 2019 04:33:58 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x623Xk7G33030492
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 2 Jul 2019 03:33:46 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 763C64C046;
	Tue,  2 Jul 2019 03:33:57 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2857A4C044;
	Tue,  2 Jul 2019 03:33:56 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.91.212])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue,  2 Jul 2019 03:33:55 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dan.j.williams@intel.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH] mm/nvdimm: Add is_ioremap_addr and use that to check ioremap address
In-Reply-To: <20190701165152.7a55299eb670b0ca326f24dd@linux-foundation.org>
References: <20190701134038.14165-1-aneesh.kumar@linux.ibm.com> <20190701165152.7a55299eb670b0ca326f24dd@linux-foundation.org>
Date: Tue, 02 Jul 2019 09:03:54 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19070203-0008-0000-0000-000002F8F824
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070203-0009-0000-0000-000022663F0B
Message-Id: <87r2792jq5.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-02_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=706 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907020036
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Mon,  1 Jul 2019 19:10:38 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
>
>> Architectures like powerpc use different address range to map ioremap
>> and vmalloc range. The memunmap() check used by the nvdimm layer was
>> wrongly using is_vmalloc_addr() to check for ioremap range which fails for
>> ppc64. This result in ppc64 not freeing the ioremap mapping. The side effect
>> of this is an unbind failure during module unload with papr_scm nvdimm driver
>
> The patch applies to 5.1.  Does it need a Fixes: and a Cc:stable?

Actually, we want it to be backported to an older kernel possibly one
that added papr-scm driver, b5beae5e224f ("powerpc/pseries: Add driver
for PAPR SCM regions"). But that doesn't apply easily. It does apply
without conflicts to 5.0

-aneesh

