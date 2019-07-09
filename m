Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6B45C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:05:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 981B220861
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:05:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 981B220861
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B0DF8E0044; Tue,  9 Jul 2019 06:05:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23AFB8E0032; Tue,  9 Jul 2019 06:05:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DBAE8E0044; Tue,  9 Jul 2019 06:05:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAD068E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 06:05:10 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id i70so11807407ybg.5
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 03:05:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=1+VBQHXcBo0nPXSJWzGzOEXs7xTs2J7UpLzDAkti684=;
        b=KfrLzHla/7dkhZspxCVwCiYp7ZN0WPycO3oYY0cZT+PXRejK6+92x3IPPh1G/Pv4aq
         k3+zUCSievg0U63hkzErsR47T0n9aiBTlnUS0rT+oWlhHkxQ2964O/+Sv/AgqyO+Qyp8
         nSaQD9jWPBmg3yQ76thFwoEX4PxpePX6WyzyXLUPd7AV3zFvbhUwathB4Nn7aJNCEumD
         dvi1wzP6cO7zMkiXNeOIJw5gNvn8vj874Dj+d/6JcPF5icwZfIfK6rv0moMlMY7Hiujw
         9V7xi9Db1jQXB4g2mJiUR4jX5EBqsR4HP+L6BU9X3ickMyFanvxo0N/L9etGuo+Y/F4C
         rg3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXHxvGMywe8oCzVQnDrYFNEPd0v0IAusxj7OgLCBlgJ3AgZYmm5
	F1o6j5fuj6rGxNMp84NHHSjn+oG61GWoHRLCbbv7fse2djHrnG7cOrNOwFFDN/2+YUBwxuVAXzM
	tAs0gBha6IEzZjyW4irsjEz3D8HHiIopl37B2+2RVOjwW6CRqUKBc8yTP1OQhnXzJaQ==
X-Received: by 2002:a81:1dc5:: with SMTP id d188mr13230698ywd.185.1562666710600;
        Tue, 09 Jul 2019 03:05:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlbT0ViV20LmaevxhiNsMY3thL1em59Rezaw5fx5gIRm4PCjannS3Rs03TsK6z8KbVUTbi
X-Received: by 2002:a81:1dc5:: with SMTP id d188mr13230671ywd.185.1562666710114;
        Tue, 09 Jul 2019 03:05:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562666710; cv=none;
        d=google.com; s=arc-20160816;
        b=pdiJrRSo7ILe+IWxzB0d/xlVB5kE7X64+FRnESFLVKBO6DeklFUi4HMoYJMZTw2XWh
         In1LSJfgB1L8NmgCeg7WlndeizIGUYwNrss7w9W8xYiEzSqRLAdM5EHXMrGD4zqbY81x
         9OdFfh3WICBPkmLielD8ATCUoSxA9w3S7FGatSwf4gfZO24IcH1ZYEPCf0fqQz1Jqvli
         TldFQCTL8wInoUvIO0F1uj+x4xH5T0QaGNiNbIPkrczPPrRfszUWl9rM1OKip6aFPQgV
         03Qz+y95vIMJoqN+wfYfP3DZj93imLqcwbNNargfIYVndT5Lpb3wvtXIby3EyYIT2Uid
         cTUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=1+VBQHXcBo0nPXSJWzGzOEXs7xTs2J7UpLzDAkti684=;
        b=mx+Q/kO7/Z6nzg/ncWoxmdxzdIGpUDV7q2Qc6kyyPlOaA6LhGJXJpq+xmX1/6dCpI2
         SorfQm6bAZy3J02nFWxmkBOlb5ZC9aU5sDklftvmkdNrllDjHyez6oS1aeCDCN3YssJj
         riP31vUWwhMT7wcogW1EcZSlT39iIpgJvsf8ceRp715GmBSjXwWlmZOYoWlgWM0kjD5M
         Rra/GWuw4Y4H1fd30w8dbjelKUbtZOMSeJjFWJLmHeg7tH1+Nt57J0trdKny16Vhiam4
         RlWnqwHKR1v7vmZn9vU7SQlHx1tkV7p3k109NNq107ZElohX6npGQtLMzEfFBp6BWNGW
         PKxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a13si3473817ybs.84.2019.07.09.03.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 03:05:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69A2P1C090776
	for <linux-mm@kvack.org>; Tue, 9 Jul 2019 06:05:09 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2tmrh10yc1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jul 2019 06:05:09 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 9 Jul 2019 11:05:08 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Jul 2019 11:05:06 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69A54O233292518
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 10:05:05 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C955642049;
	Tue,  9 Jul 2019 10:05:04 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 10D964203F;
	Tue,  9 Jul 2019 10:05:03 +0000 (GMT)
Received: from in.ibm.com (unknown [9.85.81.51])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue,  9 Jul 2019 10:05:02 +0000 (GMT)
Date: Tue, 9 Jul 2019 15:34:57 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com
Subject: Re: [PATCH v4 3/6] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE
 hcalls
Reply-To: bharata@linux.ibm.com
References: <20190528064933.23119-1-bharata@linux.ibm.com>
 <20190528064933.23119-4-bharata@linux.ibm.com>
 <20190617053756.z4disbs5vncxneqj@oak.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617053756.z4disbs5vncxneqj@oak.ozlabs.ibm.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19070910-0016-0000-0000-000002909318
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070910-0017-0000-0000-000032EE4565
Message-Id: <20190709100457.GB27933@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090122
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 03:37:56PM +1000, Paul Mackerras wrote:
> On Tue, May 28, 2019 at 12:19:30PM +0530, Bharata B Rao wrote:
> > H_SVM_INIT_START: Initiate securing a VM
> > H_SVM_INIT_DONE: Conclude securing a VM
> > 
> > As part of H_SVM_INIT_START register all existing memslots with the UV.
> > H_SVM_INIT_DONE call by UV informs HV that transition of the guest
> > to secure mode is complete.
> 
> It is worth mentioning here that setting any of the flag bits in
> kvm->arch.secure_guest will cause the assembly code that enters the
> guest to call the UV_RETURN ucall instead of trying to enter the guest
> directly.  That's not necessarily obvious to the reader as this patch
> doesn't touch that assembly code.

Documented this in the commit message.

> 
> Apart from that this patch looks fine.
> 
> > Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> 
> Acked-by: Paul Mackerras <paulus@ozlabs.org>

Thanks,
Bharata.

