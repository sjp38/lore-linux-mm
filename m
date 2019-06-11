Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86BE7C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 09:30:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12C44208E3
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 09:30:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12C44208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6063C6B0007; Tue, 11 Jun 2019 05:30:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B8016B0008; Tue, 11 Jun 2019 05:30:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 457436B000A; Tue, 11 Jun 2019 05:30:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 225F06B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:30:41 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id t128so13186653ywd.15
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 02:30:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=HCsDmp1ybAnD0OJ4vxLNV80rDCEKEm1LLtZrsf/FUrU=;
        b=pHVQ6W3w66BVtHLoKG/tjQLTIU9lq9hSQk71h9LXy7FtJcrIexOBsqae+WY7Gd8rQM
         4+yClnv1K1vAh8OMZPvz233rbItAfSlWlfo6taCzwhjswk9o/PgqIYaJoDWYGVXmXv41
         NOnHl7N/lLkbCH2P/ojt9yNm2yDycwEWLOCR0/LiqRw2zSpTHGrNKTf3QjYWjBh78EVe
         Eq/67IItCAlcBBhLzNiBui2aHw7w705wo8HJaQI1cyO7taGA3Nx4Akeml7kHQOIPojMk
         mgKhrEUgrXkTfGhB7YvWntZOwEGp53AOJyUE6PJE/bQfGQ5fYm6UehNL5ol0yd4DaOGG
         yKFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXn2J6tsQ4swwxt70laEH5vOO/JLlguIbiJtFvdbEp1U3ZkZUFn
	AuU7E4YcRb9n0za9bBuLyPSMEPtUuVw4SFQfIky4N17sOQ+ef62sMlpEPz+Mod+JLP7TeDIsn0m
	R0ixrd7ZxjY3++fjZY8H5u9cU8YOUdzTkPQPu0LlE4PnYA9iBtXxVoRsAOck8sGrXYA==
X-Received: by 2002:a81:15d4:: with SMTP id 203mr36341773ywv.133.1560245440787;
        Tue, 11 Jun 2019 02:30:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZ9/iO5kUlnIyxAKKcToOT8MYRr+1ZRB68NxA04AZnMfMDyhOlASz2HFuBu5bLyGtHMqMf
X-Received: by 2002:a81:15d4:: with SMTP id 203mr36341731ywv.133.1560245439944;
        Tue, 11 Jun 2019 02:30:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560245439; cv=none;
        d=google.com; s=arc-20160816;
        b=vb3EESuheMWEFMmmBTz7iHtRxEvQL+uoQAYn+pKw8Smccj7kGB214Itu1B4n03wFek
         1HFuNL10HKNzWTgMSyDykMMnDixJrO5V8rNcf/UkmFOwsAXWllAeyUM5nbnGwhaZrIa7
         jXkiTsHZ3cXbRkQ9agBqEOc/Dhk5dqz8ySNTRmSkv8bcWmLBoL62P2JEFWlpApc6wyU7
         P7Cdrd+RoIYkMb1Dth00403dSlJGM77C9uDTiACbZwB8wcAeupai/LShAVr2FNad9C4i
         BJuzX/ZpYu1zdMY/njZUK5QgQ63kCon0vwXeLUbM46CGK2pGC6kY83ArsHtVXat3RbaM
         2erA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=HCsDmp1ybAnD0OJ4vxLNV80rDCEKEm1LLtZrsf/FUrU=;
        b=fjfxF+HHd13EBcyXj5uVd8gKh9SHk/5wv0dH8d7+GHn9tzQOwUK3KgK9YpQQ28kL0k
         g4HIlxxf1aPEUi+oqtOTz534O2hK7J/2qLv+Ab4SzzH71lnwbLdqKbj7ZKS0oBv8Iv0Y
         QuhgAoeuwH9eI2LyAtAaqAmYDoI6ruCnljY4jmZrKziA695ssMXJiDyyxKiYPeR+DsJ1
         z0uTKkPFsxamQFlbL+u/hKebHxVos2c41bY/zuFqV30+Ett58LcxoGQS7XAqR9/VdDaz
         0ZWEZN/NVS6u3q7Uje1k/SYB5U1vpRplOFB4Fmq8kZ4No3E2P0SNYJ4RIGVVZvg5Qg6/
         kZeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c185si4225264ywd.248.2019.06.11.02.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 02:30:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5B9URRQ089198
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:30:39 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t28xmt658-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:30:33 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 11 Jun 2019 10:29:09 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 11 Jun 2019 10:29:07 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5B9T6FD47317246
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 09:29:06 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 37FE211C050;
	Tue, 11 Jun 2019 09:29:06 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EA52F11C058;
	Tue, 11 Jun 2019 09:29:04 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.93.18])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 11 Jun 2019 09:29:04 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v3 1/6] nvdimm: Consider probe return -EOPNOTSUPP as success
In-Reply-To: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
References: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
Date: Tue, 11 Jun 2019 14:59:03 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19061109-0008-0000-0000-000002F235AC
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061109-0009-0000-0000-0000225F2F8C
Message-Id: <87pnnkcvxc.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-11_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906110065
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Dan,

Any feedback on this?

A change I would like to get done on top of this series is

+	if (__le16_to_cpu(pfn_sb->version_minor) < 3) {
+		/*
+		 * For a large part we use PAGE_SIZE. But we
+		 * do have some accounting code using SZ_4K.
+		 */
+		pfn_sb->page_struct_size = cpu_to_le16(64);
+		pfn_sb->page_size = cpu_to_le32(SZ_4K);
+	}
+

to

+	if (__le16_to_cpu(pfn_sb->version_minor) < 3) {
+		/*
+		 * For a large part we use PAGE_SIZE. But we
+		 * do have some accounting code using SZ_4K.
+		 */
+		pfn_sb->page_struct_size = cpu_to_le16(64);
+		pfn_sb->page_size = cpu_to_le32(PAGE_SIZE);
+	}
+


That would make sure we will able to access the namespace created on
powerpc with newer kernel.

Kindly let me know if you want to see further changes to this series. Do
you think this is ready for next merge window?

-aneesh

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> With following patches we add EOPNOTSUPP as return from probe callback to
> indicate we were not able to initialize a namespace due to pfn superblock
> feature/version mismatch. We want to consider this a probe success so that
> we can create new namesapce seed and there by avoid marking the failed
> namespace as the seed namespace.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  drivers/nvdimm/bus.c         |  4 ++--
>  drivers/nvdimm/nd-core.h     |  3 ++-
>  drivers/nvdimm/region_devs.c | 19 +++++++++++++++----
>  3 files changed, 19 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
> index 2eb6a6cfe9e4..792b3e90453b 100644
> --- a/drivers/nvdimm/bus.c
> +++ b/drivers/nvdimm/bus.c
> @@ -100,8 +100,8 @@ static int nvdimm_bus_probe(struct device *dev)
>  
>  	nvdimm_bus_probe_start(nvdimm_bus);
>  	rc = nd_drv->probe(dev);
> -	if (rc == 0)
> -		nd_region_probe_success(nvdimm_bus, dev);
> +	if (rc == 0 || rc == -EOPNOTSUPP)
> +		nd_region_probe_success(nvdimm_bus, dev, rc);
>  	else
>  		nd_region_disable(nvdimm_bus, dev);
>  	nvdimm_bus_probe_end(nvdimm_bus);
> diff --git a/drivers/nvdimm/nd-core.h b/drivers/nvdimm/nd-core.h
> index e5ffd5733540..9e67a79fb6d5 100644
> --- a/drivers/nvdimm/nd-core.h
> +++ b/drivers/nvdimm/nd-core.h
> @@ -134,7 +134,8 @@ int __init nvdimm_bus_init(void);
>  void nvdimm_bus_exit(void);
>  void nvdimm_devs_exit(void);
>  void nd_region_devs_exit(void);
> -void nd_region_probe_success(struct nvdimm_bus *nvdimm_bus, struct device *dev);
> +void nd_region_probe_success(struct nvdimm_bus *nvdimm_bus,
> +			     struct device *dev, int ret);
>  struct nd_region;
>  void nd_region_create_ns_seed(struct nd_region *nd_region);
>  void nd_region_create_btt_seed(struct nd_region *nd_region);
> diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
> index b4ef7d9ff22e..fcf3d8828540 100644
> --- a/drivers/nvdimm/region_devs.c
> +++ b/drivers/nvdimm/region_devs.c
> @@ -723,7 +723,7 @@ void nd_mapping_free_labels(struct nd_mapping *nd_mapping)
>   * disable the region.
>   */
>  static void nd_region_notify_driver_action(struct nvdimm_bus *nvdimm_bus,
> -		struct device *dev, bool probe)
> +					   struct device *dev, bool probe, int ret)
>  {
>  	struct nd_region *nd_region;
>  
> @@ -753,6 +753,16 @@ static void nd_region_notify_driver_action(struct nvdimm_bus *nvdimm_bus,
>  			nd_region_create_ns_seed(nd_region);
>  		nvdimm_bus_unlock(dev);
>  	}
> +
> +	if (dev->parent && is_nd_region(dev->parent) &&
> +	    !probe && (ret == -EOPNOTSUPP)) {
> +		nd_region = to_nd_region(dev->parent);
> +		nvdimm_bus_lock(dev);
> +		if (nd_region->ns_seed == dev)
> +			nd_region_create_ns_seed(nd_region);
> +		nvdimm_bus_unlock(dev);
> +	}
> +
>  	if (is_nd_btt(dev) && probe) {
>  		struct nd_btt *nd_btt = to_nd_btt(dev);
>  
> @@ -788,14 +798,15 @@ static void nd_region_notify_driver_action(struct nvdimm_bus *nvdimm_bus,
>  	}
>  }
>  
> -void nd_region_probe_success(struct nvdimm_bus *nvdimm_bus, struct device *dev)
> +void nd_region_probe_success(struct nvdimm_bus *nvdimm_bus,
> +			     struct device *dev, int ret)
>  {
> -	nd_region_notify_driver_action(nvdimm_bus, dev, true);
> +	nd_region_notify_driver_action(nvdimm_bus, dev, true, ret);
>  }
>  
>  void nd_region_disable(struct nvdimm_bus *nvdimm_bus, struct device *dev)
>  {
> -	nd_region_notify_driver_action(nvdimm_bus, dev, false);
> +	nd_region_notify_driver_action(nvdimm_bus, dev, false, 0);
>  }
>  
>  static ssize_t mappingN(struct device *dev, char *buf, int n)
> -- 
> 2.21.0

