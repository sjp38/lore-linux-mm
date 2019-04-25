Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29DA0C282E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:22:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9673214AE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:22:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9673214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A0436B0005; Thu, 25 Apr 2019 04:22:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44E7D6B0006; Thu, 25 Apr 2019 04:22:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 318476B0007; Thu, 25 Apr 2019 04:22:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDF1F6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:22:49 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l74so13556458pfb.23
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 01:22:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=86ej6AFPgp0K+2jwAZQqD9mO+s20zKvhtCMT24j/Jog=;
        b=rh8+YS3MJq31H8ZoRhl9n87HX2LAiO9GI7zASwpimFWnLHjmgjFd+leGdF2RZlq5e5
         UgOZUvAFLCK6YOiFmdGVUnA1DsDZOTGp//W8qqm3OWrWFmH6iLJxYKXgqYL2ly+/McgV
         jt9tU38Y7mRJ0g/l6aEPKFGSoSO1KcLZGq3ewbd6zr5Rhj+AAmNEMAqNjYhuZb13QDwN
         7yHwAWM6S2Zk5+mDx3EvCBg7p2qTP+JPpZnOrlL7xSrDSc2X7w5ekDnrz9IfMx0o03sg
         cjXagpASdN5NCh6JtsfmzgM8IHo+6L1yebGeB449y55rRM271y9J0bBEi5RJu5YzW4o0
         Nesg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAX1PYj5ymf068V8rVo/Si1zBlQiU7I7AlUJ9CN5xbMOECoOrjZF
	MEdRTS9mAuBXEgz3eluyJms4HWLiQVm/5cKAWQ1I8GNJzvF79/M+hEKWv1UYjJdKWQesatAcO+6
	HuhP2MSPQJLd0Rqox2mgr69k1rTnTer0AgC5ML73cAei1bODNLH3vKmNfubHuU8MyGQ==
X-Received: by 2002:a62:69c2:: with SMTP id e185mr38577572pfc.119.1556180569643;
        Thu, 25 Apr 2019 01:22:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPcUt7ngzamfgPzofELbEF3jlPcIWPliyeeOs2MPb3QpVz8YMCnxOi60MBiu5622QmJAJR
X-Received: by 2002:a62:69c2:: with SMTP id e185mr38577518pfc.119.1556180568855;
        Thu, 25 Apr 2019 01:22:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556180568; cv=none;
        d=google.com; s=arc-20160816;
        b=vn6z2oXNkvFPyjBa2dm5BZPzhzb4Q0TMxJUU5dzaIBC6lzWym2Oc7AIjdQ0UlEj9mO
         jQpzuNIoOm/k9RoT0dkWOmB5dhqEGKvnGjxnJPgOfVNAtuYaHHn/G0I96MzldPXisNDl
         S1quRhhTDP1Q7oVyf60+K+El/qfnAJR/qdOGeSBVs3rJwdK5xaFprMzPebDRP1+RNhzb
         5OnCNDSlYq8tHFbINQT2zO9370SXCnaZtF3V3SZjCBOVkM/++95O+5wWX2XGGBHOEsDM
         Oi48kTvy5G1lARmQltYMkB24vABRS9gexm/qhZpMs1rGyIAYQI5efvklGNu7EOVzY3nu
         rUMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=86ej6AFPgp0K+2jwAZQqD9mO+s20zKvhtCMT24j/Jog=;
        b=ZVNeq08XlB/1FUoBTLkesf21Pvz09/J7csVVlpwWw7ec3h61mCReGTjfz8cS8enU7H
         quVIw4n0VwA0YwN9DJ/0DGIeCFRsmaBO6BZ/iyQltbMr50GSzxTEvpRQ94HXg2PZtASK
         tfR8GEqCB+Gp+mgKHsYakxz+NqnpQ0r+KAOelRiy/Y9ZRlGQSQs/O2Abh+6voErcmqFM
         9qhG0hvmejYs+LmEtqWjLq+DS1voMMtyr0hWQz8oy01olyUWEFEbqK16qTxFf6qBhWkr
         BNQv6FfyoOMBykTqt1oTJ+YVe0NHbkhbERETEpl8b/hKIX4tDrIB+T9Cl9A6+q11Avkv
         EmSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z11si19870123pgu.285.2019.04.25.01.22.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 01:22:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3P84oCx107383
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:22:48 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s382137dg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:22:48 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 25 Apr 2019 09:22:45 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Apr 2019 09:22:43 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3P8Mgcd46530680
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 08:22:42 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B0DCF11C052;
	Thu, 25 Apr 2019 08:22:42 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F2F1B11C058;
	Thu, 25 Apr 2019 08:22:41 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.63])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 25 Apr 2019 08:22:41 +0000 (GMT)
Date: Thu, 25 Apr 2019 11:22:40 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] docs/vm: add documentation of memory models
References: <1556101715-31966-1-git-send-email-rppt@linux.ibm.com>
 <a4def881-1df0-6835-4b9a-dc957c979683@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a4def881-1df0-6835-4b9a-dc957c979683@infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19042508-0008-0000-0000-000002DF50E6
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042508-0009-0000-0000-0000224BA941
Message-Id: <20190425082239.GC10625@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-25_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=939 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904250056
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Randy,

On Wed, Apr 24, 2019 at 06:08:46PM -0700, Randy Dunlap wrote:
> On 4/24/19 3:28 AM, Mike Rapoport wrote:
> > Describe what {FLAT,DISCONTIG,SPARSE}MEM are and how they manage to
> > maintain pfn <-> struct page correspondence.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > ---
> >  Documentation/vm/index.rst        |   1 +
> >  Documentation/vm/memory-model.rst | 171 ++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 172 insertions(+)
> >  create mode 100644 Documentation/vm/memory-model.rst
> > 
> 
> Hi Mike,
> I have a few minor edits below...

I kinda expected those ;-)

> > diff --git a/Documentation/vm/memory-model.rst b/Documentation/vm/memory-model.rst
> > new file mode 100644
> > index 0000000..914c52a
> > --- /dev/null
> > +++ b/Documentation/vm/memory-model.rst

...

> > +
> > +With FLATMEM, the conversion between a PFN and the `struct page` is
> > +straightforward: `PFN - ARCH_PFN_OFFSET` is an index to the
> > +`mem_map` array.
> > +
> > +The `ARCH_PFN_OFFSET` defines the first page frame number for
> > +systems that their physical memory does not start at 0.
> 
> s/that/when/ ?  Seems awkward as is.

Yeah, it is awkward. How about

The `ARCH_PFN_OFFSET` defines the first page frame number for
systems with physical memory starting at address different from 0.

> > +
> > +DISCONTIGMEM
> > +============
> > +
> 
> thanks.
> -- 
> ~Randy
> 

-- 
Sincerely yours,
Mike.

