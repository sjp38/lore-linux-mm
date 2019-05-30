Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7070C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 15:12:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 799BD25C63
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 15:12:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 799BD25C63
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17B486B026F; Thu, 30 May 2019 11:12:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1521C6B0270; Thu, 30 May 2019 11:12:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01B506B0271; Thu, 30 May 2019 11:12:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD7CD6B026F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 11:12:41 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j26so2531505pgj.6
        for <linux-mm@kvack.org>; Thu, 30 May 2019 08:12:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=Dl0GS4kLiTu2ILYHI+1T3a2uEm+hg0wNj0g3w2Dbmc4=;
        b=Q6NG5MhzpKrctK8fZ2xulfr3XLA6bYOvAlG1LMPtRB7ylySTSGFa5OEZSiCJjjmKpD
         iyGqadNmqcvVVd6ZGD+WgkLHml8/w30yxYGsFbz0GY/o02mZJAjCLUBjPHsjjz59RDBQ
         MVzaCR4rZc1A9ctgGiENlUJci0o4sge+dJFvTlrbmOaaQFS5oANjfbi9NVCx1ZxkhRmE
         ljzm9MLKL4FK9Flfappizm+hzlb9sghuLYIB/yfT2o6rxrqkKTmxPZDuclJD96du/uSi
         tTd8rhqfMYv6T7sjECUfiRGe0qJptbTNMCqq27fNMMV4asGKFl/0ndMlmNmq4D8t9D2E
         oNOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWjm4gjZ/Q5txneKwUT0F3feh6w3ITkh/PngFWyMQIM42/+UOYE
	Zgjne/v8bG/pQUnPrId4yL5CvUx7VbliTZ5tjVUwhg5xV9zSLs2JIKuqvGqYZyeFrAjYWf51adw
	ebRsoGp86oXdZChKPThb4vga/JKXmI1fSKqx0FdOM3aEkvBAF8N++XEnqDIKPjpGMAw==
X-Received: by 2002:a62:4ed8:: with SMTP id c207mr4070833pfb.241.1559229161422;
        Thu, 30 May 2019 08:12:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUFtor4rxMBW12YrMDmprx2uy9KNLgdVF92F0oqRcCJc6qMYyPKgK0RXRnyDTc2D8dOFp+
X-Received: by 2002:a62:4ed8:: with SMTP id c207mr4070778pfb.241.1559229160572;
        Thu, 30 May 2019 08:12:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559229160; cv=none;
        d=google.com; s=arc-20160816;
        b=hgUtfQnWJegLpxVY3JoE2NfmIEujDvpr8uDSBm88uSNfpqRgR5AvUraPP7xo/FwIeS
         fKmnuosIuo+syYpMzpyRWXnNceeMNLvoCZN3hdfjirz/kM8Hsr5inu3xw8rD3HU38f4+
         sBCWASJ7WcUlLkuIcLeaI7O9Ab7BXA4PZWANsgy+NHiL+yUAvXFKMV26ftldg3G6dxx5
         ezj3bove9eh54UjPdRD7NITP7O4pyPGjz0QTROizuxNLcWHxS5I+jX/3ZOG9uB6hGZT1
         kdFD9zsTxW+Fz9+c+Ep8lz8zxa4uz++Y9342Tl1DTUj7DIls/BxXY+SRKTy7yClI3wwA
         CeMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=Dl0GS4kLiTu2ILYHI+1T3a2uEm+hg0wNj0g3w2Dbmc4=;
        b=xNixlzA3Tjea2MkJNVHaGR09bt/z4on5o2v9VUCij5uVsimXzTXsK+tolKiNXyJVPD
         PHBo1tcVZMPMHV5snoDSA9yFsifrUyVy1inmPsHBTNh+4QSkFuQ0K/rL1mGWRbZg0EJc
         xoYjrcVXEvPad8MlQSQeC8fohS5mJn9D04VWsERZR0jAhfi3mbiG26OrO74gW0gePqG7
         tFJl6oXlZyg/PeNOTbV9nLRJbOiFm2+7m8uFyPATEXR53CN1UOv7fH+yvo8MFdfB8/QU
         KeMYK/bTyitbaL8hgUTG5W/9h0L3pvXIz6olvzopmajy1CKMVy0I5csc6xY+rJMuI5H0
         t3Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d8si3183279pls.208.2019.05.30.08.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 08:12:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4UF33MO016133
	for <linux-mm@kvack.org>; Thu, 30 May 2019 11:12:40 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2stfb3q7km-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 30 May 2019 11:12:39 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 30 May 2019 16:12:37 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 30 May 2019 16:12:35 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4UFCY4h20381756
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 30 May 2019 15:12:34 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A0A5EA405B;
	Thu, 30 May 2019 15:12:34 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 836A3A4062;
	Thu, 30 May 2019 15:12:33 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.37.131])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 30 May 2019 15:12:33 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org
Subject: Re: [RFC PATCH V2 1/3] mm/nvdimm: Add PFN_MIN_VERSION support
In-Reply-To: <20190522082701.6817-1-aneesh.kumar@linux.ibm.com>
References: <20190522082701.6817-1-aneesh.kumar@linux.ibm.com>
Date: Thu, 30 May 2019 20:42:32 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19053015-0020-0000-0000-000003420062
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19053015-0021-0000-0000-00002195061A
Message-Id: <874l5c563j.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-30_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905300107
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Dan,

Are you ok with this patch series? If yes I can send a non-RFC version for
this series. Since we are now marking all previously created pfn_sb on
ppc64 as not supported, (pfn_sb->page_size = SZ_4K) I would like to get
this merged early.

-aneesh

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> This allows us to make changes in a backward incompatible way. I have
> kept the PFN_MIN_VERSION in this patch '0' because we are not introducing
> any incompatible changes in this patch. We also may want to backport this
> to older kernels.
>
> The error looks like
>
>   dax0.1: init failed, superblock min version 1, kernel support version 0
>
> and the namespace is marked disabled
>
> $ndctl list -Ni
> [
>   {
>     "dev":"namespace0.0",
>     "mode":"fsdax",
>     "map":"mem",
>     "size":10737418240,
>     "uuid":"9605de6d-cefa-4a87-99cd-dec28b02cffe",
>     "state":"disabled"
>   }
> ]
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  drivers/nvdimm/pfn.h      |  9 ++++++++-
>  drivers/nvdimm/pfn_devs.c |  8 ++++++++
>  drivers/nvdimm/pmem.c     | 26 ++++++++++++++++++++++----
>  3 files changed, 38 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
> index dde9853453d3..5fd29242745a 100644
> --- a/drivers/nvdimm/pfn.h
> +++ b/drivers/nvdimm/pfn.h
> @@ -20,6 +20,12 @@
>  #define PFN_SIG_LEN 16
>  #define PFN_SIG "NVDIMM_PFN_INFO\0"
>  #define DAX_SIG "NVDIMM_DAX_INFO\0"
> +/*
> + * increment this when we are making changes such that older
> + * kernel should fail to initialize that namespace.
> + */
> +
> +#define PFN_MIN_VERSION 0
>  
>  struct nd_pfn_sb {
>  	u8 signature[PFN_SIG_LEN];
> @@ -36,7 +42,8 @@ struct nd_pfn_sb {
>  	__le32 end_trunc;
>  	/* minor-version-2 record the base alignment of the mapping */
>  	__le32 align;
> -	u8 padding[4000];
> +	__le16 min_version;
> +	u8 padding[3998];
>  	__le64 checksum;
>  };
>  
> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> index 01f40672507f..a2268cf262f5 100644
> --- a/drivers/nvdimm/pfn_devs.c
> +++ b/drivers/nvdimm/pfn_devs.c
> @@ -439,6 +439,13 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
>  	if (nvdimm_read_bytes(ndns, SZ_4K, pfn_sb, sizeof(*pfn_sb), 0))
>  		return -ENXIO;
>  
> +	if (le16_to_cpu(pfn_sb->min_version) > PFN_MIN_VERSION) {
> +		dev_err(&nd_pfn->dev,
> +			"init failed, superblock min version %ld kernel support version %ld\n",
> +			le16_to_cpu(pfn_sb->min_version), PFN_MIN_VERSION);
> +		return -EOPNOTSUPP;
> +	}
> +
>  	if (memcmp(pfn_sb->signature, sig, PFN_SIG_LEN) != 0)
>  		return -ENODEV;
>  
> @@ -769,6 +776,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>  	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
>  	pfn_sb->version_major = cpu_to_le16(1);
>  	pfn_sb->version_minor = cpu_to_le16(2);
> +	pfn_sb->min_version = cpu_to_le16(PFN_MIN_VERSION);
>  	pfn_sb->start_pad = cpu_to_le32(start_pad);
>  	pfn_sb->end_trunc = cpu_to_le32(end_trunc);
>  	pfn_sb->align = cpu_to_le32(nd_pfn->align);
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index 845c5b430cdd..406427c064d9 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -490,6 +490,7 @@ static int pmem_attach_disk(struct device *dev,
>  
>  static int nd_pmem_probe(struct device *dev)
>  {
> +	int ret;
>  	struct nd_namespace_common *ndns;
>  
>  	ndns = nvdimm_namespace_common_probe(dev);
> @@ -505,12 +506,29 @@ static int nd_pmem_probe(struct device *dev)
>  	if (is_nd_pfn(dev))
>  		return pmem_attach_disk(dev, ndns);
>  
> -	/* if we find a valid info-block we'll come back as that personality */
> -	if (nd_btt_probe(dev, ndns) == 0 || nd_pfn_probe(dev, ndns) == 0
> -			|| nd_dax_probe(dev, ndns) == 0)
> +	ret = nd_btt_probe(dev, ndns);
> +	if (ret == 0)
>  		return -ENXIO;
> +	else if (ret == -EOPNOTSUPP)
> +		return ret;
>  
> -	/* ...otherwise we're just a raw pmem device */
> +	ret = nd_pfn_probe(dev, ndns);
> +	if (ret == 0)
> +		return -ENXIO;
> +	else if (ret == -EOPNOTSUPP)
> +		return ret;
> +
> +	ret = nd_dax_probe(dev, ndns);
> +	if (ret == 0)
> +		return -ENXIO;
> +	else if (ret == -EOPNOTSUPP)
> +		return ret;
> +	/*
> +	 * We have two failure conditions here, there is no
> +	 * info reserver block or we found a valid info reserve block
> +	 * but failed to initialize the pfn superblock.
> +	 * Don't create a raw pmem disk for the second case.
> +	 */
>  	return pmem_attach_disk(dev, ndns);
>  }
>  
> -- 
> 2.21.0

