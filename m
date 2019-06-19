Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 260E8C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:30:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC7A22173E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:30:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC7A22173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64AF58E0008; Wed, 19 Jun 2019 12:30:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FAD48E0001; Wed, 19 Jun 2019 12:30:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EBFE8E0008; Wed, 19 Jun 2019 12:30:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCDB8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:30:28 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b188so35001ywb.10
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:30:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=qw40hPqfWiyBgxT3MUNSYP1O/HT3LUBF/+fYdBrltaE=;
        b=aZvjRUgUltLloUGPgtRFZnNwhOmOSfs8rc4UOFieY/U7SeZb0gKMXatXypt2MzFh6k
         o2dFcDMkK7n+8AuhUnREx6tg6lmdBTQ5lSZUBrQM7YzZBA0UdUdp4jUZKZ9OzSvrG67z
         isPTdjLxhB9EcWrtg13JpykmE7tR5HsnNwMWuKhOkWJE/XA/KI8jqfBy+ILJdzbCp4Md
         yj2ZT84uU7PpdYpr6Y2chyLdNTccS874bvXDPUoN6CxWAEpJNUVOhvyYjoXSwlzuZOVe
         nkn7tJQ2fdFsYDYlp4t8xXgjHsOdd13IKcgYjlJ1Hi57s8m4NMBwZMKu4XsktNH/A1ir
         TRqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXhkUV3NIY2kXP01gdixZ6VaRQXkqNDOmNlksjBdAkA1+QWdLr2
	XFXpFYNGYQV2IXuAgkRzKAH8IELsd+ikDAMBR8DYYMY2mbiY5RTo0bb4e8CP2dyT5IQNDthfKY2
	PClXvFKwIDIjx+7Y6Kwdahd7auigyOn+bPWbdUN4ob/nPW143U8awUqfDgaQnNrEyzQ==
X-Received: by 2002:a81:47c1:: with SMTP id u184mr71044976ywa.313.1560961827900;
        Wed, 19 Jun 2019 09:30:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVyPviv/N9WFId756naDrf3vKUr6nQe/YQcaemwBWI2LxRiK8l/dov7epjsGTKCiTApoPT
X-Received: by 2002:a81:47c1:: with SMTP id u184mr71044928ywa.313.1560961827139;
        Wed, 19 Jun 2019 09:30:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560961827; cv=none;
        d=google.com; s=arc-20160816;
        b=f1dr+oD2fwDEcko4gnKoZS9qNsLwFyzwWRgKzsB2a5FO+WvSHadydeB/g5GcT27BxR
         eUQTk2IbI6fWagJpJuJ1L7UHVvC8ta2exS86wLn5OksJSQe91x4TDOgU98iGyaAdzTr1
         HyxCK8HcF+XA5/vIolXrDtW8BkLdWvTRs22/rmVORWWTkoPVSwESn6ra+n2Dh+mQiw6t
         oZVbDsbXlWOgljQmJWZCAE0G0iOZ1RdT5+CvFm/5BUlkMzBxbbUy88TuM5Xs4ZWtEc27
         TevRlgtLHHZejXAMF7KBRQPM57UplRuB/kfOYL864viDlkcGw+vZN+bM7p567MUFlFA6
         7JHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=qw40hPqfWiyBgxT3MUNSYP1O/HT3LUBF/+fYdBrltaE=;
        b=iNdOrnSKnqzs8KoIMqsWY+J+uIVL/0dm56PnHHr+bSY1MV4Fla+SWPcbwdiUGKmjp/
         hjxbVaKo4mJoG7dIUb0VIDpxYdYUbyg+NO3cXhCUukd5wasH06NWYIHIp13sf/IZUEUd
         M1gFLL72kqG+kSoQ96xw7co0N0BCy0aH//7uI+7ZOeVHUvgvM2ZKyj8ke7SLSGljNvjj
         oN2CWWgo3hh1vvddWyWEexks6ujc7ziyrqw4Dvq0gJTqG3tAD3yJiY3LxR9vdnqNiU+Q
         vacSwlhYHV1knZ9qJwlDX+VFyTInwcEJv5q5CiYQ4W25h9puLMVsUoosh/UGRrt54LYb
         TdQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n129si6901065ywn.233.2019.06.19.09.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 09:30:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5JGSQlA029971
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:30:26 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t7r9b94kf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:30:26 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 19 Jun 2019 17:30:24 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 19 Jun 2019 17:30:22 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5JGULFb59965666
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 16:30:21 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 14CA6A4067;
	Wed, 19 Jun 2019 16:30:21 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 97E78A405C;
	Wed, 19 Jun 2019 16:30:19 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.91.144])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 19 Jun 2019 16:30:19 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org,
        linux-nvdimm@lists.01.org
Subject: Re: [PATCH v10 12/13] libnvdimm/pfn: Fix fsdax-mode namespace info-block zero-fields
In-Reply-To: <156092356065.979959.6681003754765958296.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com> <156092356065.979959.6681003754765958296.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Wed, 19 Jun 2019 22:00:18 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19061916-0008-0000-0000-000002F53C2B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061916-0009-0000-0000-0000226258B9
Message-Id: <877e9hk06d.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-19_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> At namespace creation time there is the potential for the "expected to
> be zero" fields of a 'pfn' info-block to be filled with indeterminate
> data. While the kernel buffer is zeroed on allocation it is immediately
> overwritten by nd_pfn_validate() filling it with the current contents of
> the on-media info-block location. For fields like, 'flags' and the
> 'padding' it potentially means that future implementations can not rely
> on those fields being zero.
>
> In preparation to stop using the 'start_pad' and 'end_trunc' fields for
> section alignment, arrange for fields that are not explicitly
> initialized to be guaranteed zero. Bump the minor version to indicate it
> is safe to assume the 'padding' and 'flags' are zero. Otherwise, this
> corruption is expected to benign since all other critical fields are
> explicitly initialized.
>
> Note The cc: stable is about spreading this new policy to as many
> kernels as possible not fixing an issue in those kernels. It is not
> until the change titled "libnvdimm/pfn: Stop padding pmem namespaces to
> section alignment" where this improper initialization becomes a problem.
> So if someone decides to backport "libnvdimm/pfn: Stop padding pmem
> namespaces to section alignment" (which is not tagged for stable), make
> sure this pre-requisite is flagged.

Don't we need a change like below in this patch?

modified   drivers/nvdimm/pfn_devs.c
@@ -452,10 +452,11 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 	if (memcmp(pfn_sb->parent_uuid, parent_uuid, 16) != 0)
 		return -ENODEV;
 
-	if (__le16_to_cpu(pfn_sb->version_minor) < 1) {
-		pfn_sb->start_pad = 0;
-		pfn_sb->end_trunc = 0;
-	}
+	if ((__le16_to_cpu(pfn_sb->version_minor) < 1) ||
+	    (__le16_to_cpu(pfn_sb->version_minor) >= 3)) {
+			pfn_sb->start_pad = 0;
+			pfn_sb->end_trunc = 0;
+		}


IIUC we want to force the start_pad and end_truc to zero if the pfn_sb
minor version number >= 3. So once we have this patch backported and
older kernel finds a pfn_sb with minor version 3, it will ignore the
start_pad read from the nvdimm and overwrite that with zero here.
This patch doesn't enforce that right? After the next patch we can have
values other than 0 in pfn_sb->start_pad?


>
> Fixes: 32ab0a3f5170 ("libnvdimm, pmem: 'struct page' for pmem")
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  drivers/nvdimm/dax_devs.c |    2 +-
>  drivers/nvdimm/pfn.h      |    1 +
>  drivers/nvdimm/pfn_devs.c |   18 +++++++++++++++---
>  3 files changed, 17 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/nvdimm/dax_devs.c b/drivers/nvdimm/dax_devs.c
> index 49fc18ee0565..6d22b0f83b3b 100644
> --- a/drivers/nvdimm/dax_devs.c
> +++ b/drivers/nvdimm/dax_devs.c
> @@ -118,7 +118,7 @@ int nd_dax_probe(struct device *dev, struct nd_namespace_common *ndns)
>  	nvdimm_bus_unlock(&ndns->dev);
>  	if (!dax_dev)
>  		return -ENOMEM;
> -	pfn_sb = devm_kzalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
> +	pfn_sb = devm_kmalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
>  	nd_pfn->pfn_sb = pfn_sb;
>  	rc = nd_pfn_validate(nd_pfn, DAX_SIG);
>  	dev_dbg(dev, "dax: %s\n", rc == 0 ? dev_name(dax_dev) : "<none>");
> diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
> index f58b849e455b..dfb2bcda8f5a 100644
> --- a/drivers/nvdimm/pfn.h
> +++ b/drivers/nvdimm/pfn.h
> @@ -28,6 +28,7 @@ struct nd_pfn_sb {
>  	__le32 end_trunc;
>  	/* minor-version-2 record the base alignment of the mapping */
>  	__le32 align;
> +	/* minor-version-3 guarantee the padding and flags are zero */
>  	u8 padding[4000];
>  	__le64 checksum;
>  };
> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> index 0f81fc56bbfd..4977424693b0 100644
> --- a/drivers/nvdimm/pfn_devs.c
> +++ b/drivers/nvdimm/pfn_devs.c
> @@ -412,6 +412,15 @@ static int nd_pfn_clear_memmap_errors(struct nd_pfn *nd_pfn)
>  	return 0;
>  }
>  
> +/**
> + * nd_pfn_validate - read and validate info-block
> + * @nd_pfn: fsdax namespace runtime state / properties
> + * @sig: 'devdax' or 'fsdax' signature
> + *
> + * Upon return the info-block buffer contents (->pfn_sb) are
> + * indeterminate when validation fails, and a coherent info-block
> + * otherwise.
> + */
>  int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
>  {
>  	u64 checksum, offset;
> @@ -557,7 +566,7 @@ int nd_pfn_probe(struct device *dev, struct nd_namespace_common *ndns)
>  	nvdimm_bus_unlock(&ndns->dev);
>  	if (!pfn_dev)
>  		return -ENOMEM;
> -	pfn_sb = devm_kzalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
> +	pfn_sb = devm_kmalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
>  	nd_pfn = to_nd_pfn(pfn_dev);
>  	nd_pfn->pfn_sb = pfn_sb;
>  	rc = nd_pfn_validate(nd_pfn, PFN_SIG);
> @@ -694,7 +703,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>  	u64 checksum;
>  	int rc;
>  
> -	pfn_sb = devm_kzalloc(&nd_pfn->dev, sizeof(*pfn_sb), GFP_KERNEL);
> +	pfn_sb = devm_kmalloc(&nd_pfn->dev, sizeof(*pfn_sb), GFP_KERNEL);
>  	if (!pfn_sb)
>  		return -ENOMEM;
>  
> @@ -703,11 +712,14 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>  		sig = DAX_SIG;
>  	else
>  		sig = PFN_SIG;
> +
>  	rc = nd_pfn_validate(nd_pfn, sig);
>  	if (rc != -ENODEV)
>  		return rc;
>  
>  	/* no info block, do init */;
> +	memset(pfn_sb, 0, sizeof(*pfn_sb));
> +
>  	nd_region = to_nd_region(nd_pfn->dev.parent);
>  	if (nd_region->ro) {
>  		dev_info(&nd_pfn->dev,
> @@ -760,7 +772,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>  	memcpy(pfn_sb->uuid, nd_pfn->uuid, 16);
>  	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
>  	pfn_sb->version_major = cpu_to_le16(1);
> -	pfn_sb->version_minor = cpu_to_le16(2);
> +	pfn_sb->version_minor = cpu_to_le16(3);
>  	pfn_sb->start_pad = cpu_to_le32(start_pad);
>  	pfn_sb->end_trunc = cpu_to_le32(end_trunc);
>  	pfn_sb->align = cpu_to_le32(nd_pfn->align);
>
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

