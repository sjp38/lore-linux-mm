Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB88EC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 07:24:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D6722075D
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 07:24:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D6722075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 170168E0020; Thu,  7 Feb 2019 02:24:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11EBA8E0002; Thu,  7 Feb 2019 02:24:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F28D88E0020; Thu,  7 Feb 2019 02:24:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADFC48E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 02:24:38 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id e89so7270713pfb.17
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 23:24:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:mime-version:content-disposition:user-agent:message-id;
        bh=IUY+5BisFQh80w9guk5ATwvAnz/Zbjel2n8H3TmYmyg=;
        b=mj2tbmHDudKM8LRF/BI8sC/Hyqb3MiBFIl0XxtA1HXBIkMyYl1gA+LeFvvWEcaHHhP
         RmM1lHRYKjP/BWkdDsfWR6I8hB561snY0FXaOMyia/x1gzXzxnowk6t+K2qygc/LEL7z
         teZrLOK7Foja3uRRZoficL89Kv3OUqIQfH2F7tHun0BdF/KEA94K+VjLqpM1NsbjNlB/
         7kNP0bHqkUh9NH4hSVGwHWZyr5io2DO0Nn8Af4bGlBlnIatoqxvrWAwvg1KSEXiHUDlQ
         p6KhRzjkQfwnUcfR2OekV/y7VkeFg+DWm6RKgd4WE7jOEr62J0Vn9wVvSdhJJL7bLeDc
         4HzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaWkML+zm+LmYdu6qyRJ19Jv/l113UDKn3NyVpZbjG1vXuLSAd/
	Vx7L2kjB4jMj0vMES+H1ijF1CxCIWkHR0Q4IlhzmTMvhYtfRw7i+cfvwMZ6YhhU5iZotQ6dJAzo
	p9KeJ3qFIUnAOC1mzuYw4UgJmmnF3FyEdrQ8tjtf89LZXVmBrrQn2G6zpCqEApCdt+g==
X-Received: by 2002:a17:902:aa8d:: with SMTP id d13mr13401553plr.293.1549524278327;
        Wed, 06 Feb 2019 23:24:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY10GzyE17rFX8CGYgOzNMrBWCTskgcnLeXfKaRuPGGhZFeiCQ/WLfhg6RB4KX6HvZZK0Ik
X-Received: by 2002:a17:902:aa8d:: with SMTP id d13mr13401509plr.293.1549524277363;
        Wed, 06 Feb 2019 23:24:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549524277; cv=none;
        d=google.com; s=arc-20160816;
        b=ubckANIQMBKtIObP6Yw4h5YzQooOCtFfQojLDlIQtsBZD1Ry7t7ODwZGNq7EtrsjbE
         DTNBg96Uj4kqCYJ7/thlrFYoZULQZphTtjO3qeNedIFNGTgAaRIB49DFxE6yme9P+dhR
         y3e1uQeLKVuiyuayxpV3tNL2K1wYlVFnS9tQLLB4UkNsmvOWY+IPYO5aia0W0TJvNM4+
         3PLSl4KwoxzBjXkdNNksPMMbfkcQEVbDF7UiGJYKG5cOQGHi3a0OEBo2pbqSvzFwZCVA
         84pxAqNIRGL+VuJiAHkQricPpfJk4c5SLo34yj1v78arkzb5kAkeQAnMy94aIXG/Wt+c
         Fp1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:content-disposition:mime-version:subject:cc
         :to:from:date;
        bh=IUY+5BisFQh80w9guk5ATwvAnz/Zbjel2n8H3TmYmyg=;
        b=Qgba5pmB82E6KmdwiU4X0CEL8+SYaparXYwC8gVJ5fB6OppYXZFYk3a8lhNiNvmnIc
         dQh1+EkCVjwKwCOnIDkyAX5zXmw13LDr0Z4SnDPkLAXitw6/K3vo2FEszomDkcgt51eO
         49wXMnfh67z8K0pcG8XO56+yEYdbHW9cS7P0TbNvV/cXIheG9+nvyDysbZRl9Tm/oVl+
         +Q4TQNdzpbgjsf/eC3aNF8xaExUA4PS9RYrapkv7FpaAa4EizMettuSZbGwQkF4WSNw5
         OKd8EkiYpW1IhdsruMkroenkpwDGLTPaIsD/9/FAzjdpSKnUVKWDJet33PMxUMDUOPlo
         i+Vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v19si4855451pfa.80.2019.02.06.23.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 23:24:37 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x177Ihws101466
	for <linux-mm@kvack.org>; Thu, 7 Feb 2019 02:24:36 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qgd5kpk8p-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 07 Feb 2019 02:24:36 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 7 Feb 2019 07:24:27 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 7 Feb 2019 07:24:25 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x177OOxG3670478
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 7 Feb 2019 07:24:24 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 183B142041;
	Thu,  7 Feb 2019 07:24:24 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B5F294203F;
	Thu,  7 Feb 2019 07:24:23 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  7 Feb 2019 07:24:23 +0000 (GMT)
Date: Thu, 7 Feb 2019 09:24:22 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: [LSF/MM TOPIC] Address space isolation inside the kernel
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19020707-4275-0000-0000-0000030C7E07
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020707-4276-0000-0000-0000381A8576
Message-Id: <20190207072421.GA9120@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-07_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=846 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902070058
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(Joint proposal with James Bottomley)

Address space isolation has been used to protect the kernel from the
userspace and userspace programs from each other since the invention of
the virtual memory.

Assuming that kernel bugs and therefore vulnerabilities are inevitable
it might be worth isolating parts of the kernel to minimize damage
that these vulnerabilities can cause.

There is already ongoing work in a similar direction, like XPFO [1] and
temporary mappings proposed for the kernel text poking [2].

We have several vague ideas how we can take this even further and make
different parts of kernel run in different address spaces:
* Remove most of the kernel mappings from the syscall entry and add a
  trampoline when the syscall processing needs to call the "core
  kernel".
* Make the parts of the kernel that execute in a namespace use their
  own mappings for the namespace private data
* Extend EXPORT_SYMBOL to include a trampoline so that the code
  running in modules won't map the entire kernel
* Execute BFP programs in a dedicated address space

These are very general possible directions. We are exploring some of
them now to understand if the security value is worth the complexity
and the performance impact.

We believe it would be helpful to discuss the general idea of address
space isolation inside the kernel, both from the technical aspect of
how it can be achieved simply and efficiently and from the isolation
aspect of what actual security guarantees it usefully provides.

[1] https://lore.kernel.org/lkml/cover.1547153058.git.khalid.aziz@oracle.com/
[2] https://lore.kernel.org/lkml/20190129003422.9328-4-rick.p.edgecombe@intel.com/

-- 
Sincerely yours,
Mike.

