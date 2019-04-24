Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 749BAC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:35:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F54C21773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:35:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F54C21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C633B6B0005; Wed, 24 Apr 2019 07:35:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C14E06B0006; Wed, 24 Apr 2019 07:35:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADC186B0007; Wed, 24 Apr 2019 07:35:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 88EAC6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:35:18 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id i80so14304436ybg.22
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 04:35:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=FlhC8iImmmGyoPjc6wsM2UbEv/6KnXsKI2ivySOC34U=;
        b=nbHLAIDyt2V7iHjoAACC6Gh/69KbvzA3lrc/XGXCRXGJz/KYyN1swhIFqSrLsPRR2i
         V6p1+1DaAI7Bm+KEM1RPAZAMw9ADvY2IlS9yu+m5q/NT+E/qTZbDQjVDMbfH3q06XxIT
         vUyiaLz+3LluPxlZfQp8SMSRC0KGat7fCTXR6sdG66LypJX7t4eLbRdtlg0FmkRT3SRS
         FqRYOeoHo53yNt9DfYqILLiRKhL4mJnXNEJ8VD7fLOPVTUWdift2pG8YfhMqWU1XQ1QV
         RDzpX0X8Q3Znpw39ROEEOje7z8ed6TFzjzYuS5BWRRU4ZlJvtmBNW27jTIKL9IYGSx1u
         unGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVN/0+h8Jana216BQnyLdQ8XKiGy4LW0o+gp2OdykF2LrNLqHVN
	+qd11R9iVNSzvY8M/8uTZH9K9pQikLwxnJrjm8hsZsGyZJSyG4zAOr5cn6ep8+yMsZXM/5SmbCd
	Lbyf0MB0P3nMQcBZxPDQmtG3vA2YKGvlQAqFh+RXCD/7ZCcLJd/Z6oFAvbRqQHTPT9Q==
X-Received: by 2002:a81:b610:: with SMTP id u16mr6377898ywh.320.1556105718295;
        Wed, 24 Apr 2019 04:35:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0jckFzwU8FHSCC+8yMf8gysHcSLOMphMXaztgchXhMoAzzvtycD8DKyca2db0elZ7L+23
X-Received: by 2002:a81:b610:: with SMTP id u16mr6377854ywh.320.1556105717610;
        Wed, 24 Apr 2019 04:35:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556105717; cv=none;
        d=google.com; s=arc-20160816;
        b=JLinEfHK0W6E21i0pMSGfaYYqIk9+qOe/YNQOsIM050gOvEUZdxDZTWCL34jCBFn4b
         9I+QEyN3dhkDAsk7zHHdSgGjgNSCYFcETlDbZrjoGSdrCNRn0/YeWEnAqTRJcYMmUmK+
         522i06e8QIGONmSKzE5cFF3jR8cle4jim3dA3JYMf2OABrmVBz8WwaBvPQ6y78hUzh+s
         xTiUo0rTSUu9a37UFca2Fisq6To8YDe+c8RCAOIyNJe3BBv1XswiHkRNCuOoXrRGJH/W
         0XJIM5ZOsc2bbZ/cs5f4evPe2lBEwIoPV8wyiIEU54GhChIsaN1y7j1fbjidg8e2c6lv
         8yqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=FlhC8iImmmGyoPjc6wsM2UbEv/6KnXsKI2ivySOC34U=;
        b=MDQp+xznTkQCfCLrLg1tYaoshRBq3xinmBLA9uRt33InpXUK6jrixJocOWaQ0sarkr
         GKMRrabtDz4jK6LJaF0LFKB+VQ4e230xtlfcB5n9IibPisKXnJMSSd0era8oGYUMCG3L
         Fz+e/eL7Drj8VbKLhBDA36yI6XWUXto4/KVrsMRQvv6yocIgYm4CwZdwNswhiz9EQ+r2
         gNYClFs8E9dweFaRcKzZSjJCEykEnEJ99Kh8cZ1vyfub2qXSoR86bJLcOb4MijFh8ece
         YNqp89JdgImOFnRKwF1GxMfarP2hUOY0p+XulHfq05a7vr3dOtckE4JCdYEYSl1duZUt
         mMog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 193si12825214ywd.155.2019.04.24.04.35.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 04:35:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OBTqoW016190
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:35:17 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s2np7m8m6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:35:17 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 24 Apr 2019 12:35:15 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 12:35:12 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3OBZCfJ57606294
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 11:35:12 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F3A425205F;
	Wed, 24 Apr 2019 11:35:11 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 897E85204F;
	Wed, 24 Apr 2019 11:35:11 +0000 (GMT)
Date: Wed, 24 Apr 2019 14:35:09 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] docs/vm: add documentation of memory models
References: <1556101715-31966-1-git-send-email-rppt@linux.ibm.com>
 <bbde10af-0e9f-08be-30d6-1513c50e0d17@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bbde10af-0e9f-08be-30d6-1513c50e0d17@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19042411-0016-0000-0000-00000272FB6B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042411-0017-0000-0000-000032CF6C95
Message-Id: <20190424113509.GB6278@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=976 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240095
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 04:20:02PM +0530, Anshuman Khandual wrote:
> 
> 
> On 04/24/2019 03:58 PM, Mike Rapoport wrote:
> > +To use vmemmap, an architecture has to reserve a range of virtual
> > +addresses that will map the physical pages containing the memory
> > +map. and make sure that `vmemmap` points to that range. In addition,
> > +the architecture should implement :c:func:`vmemmap_populate` method
> > +that will allocate the physical memory and create page tables for the
> > +virtual memory map. If an architecture does not have any special
> > +requirements for the vmemmap mappings, it can use default
> > +:c:func:`vmemmap_populate_basepages` provided by the generic memory
> > +management.
> 
> Just to complete it, could you also include struct vmem_altmap and how it
> can contribute towards the physical backing for vmemmap virtual mapping.
> Otherwise the write up looks complete.

Sure, but I'd prefer having it as a separate patch. 

-- 
Sincerely yours,
Mike.

