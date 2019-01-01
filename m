Return-Path: <SRS0=ID2a=PJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28BB6C43387
	for <linux-mm@archiver.kernel.org>; Tue,  1 Jan 2019 09:15:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB0AF2075D
	for <linux-mm@archiver.kernel.org>; Tue,  1 Jan 2019 09:15:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB0AF2075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 250C18E0009; Tue,  1 Jan 2019 04:15:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D82F8E0002; Tue,  1 Jan 2019 04:15:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A0668E0009; Tue,  1 Jan 2019 04:15:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF7A08E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 04:14:59 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w15so36510788qtk.19
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 01:14:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=cvz2o8NSBf7XxfRmfb02P2erO/CmkFs6XkB3BJv/j+Y=;
        b=d8UcNK4KmIl/ejMFaDI9efWN3uGP/rPu9oKLXbR/OY25fjHRQ394kTrgn7M1Va2ogk
         Wp1SDwapcQJd0MNezD4U4KK6BqvPmu9O0In8eFj/0LDd1pX5h5RY38cCQqGd+110UWaF
         ytJ2jv6k5on8LpdhrIDvfkPb1915C6H+HtSey7iGj/Zmj+W+3WVc2nJk04R+fir8xzGk
         LMsaTQfvxyO15Lu2yzYO5jcFmBObnCLOJKxhkKdVAzUVgG5N3P4F1tdKwU2I0A6Kn+NC
         EeHjMqwLcidj0IX+drd0SXSNQNrvlla5x5v3guaHkDHIqmIafBIU/CozA9u1et/i0mQk
         if+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukfmzuVBoITMArNfQgbo1V9K4xf/tHfSljupesLvJWCHDMikvRT4
	5xVmfW9KHy8mMGjXPB9hweKFAV3pLJbroovjCsTZ6kLNxz8HxSyexd0YqSUylphlNxKsRiMEQo/
	G2Hk72d+ak4/BewcaFpQCI39TRjPNxtkxoADKj2QcpHRohIQR41bKCunY/f+fFzoIMA==
X-Received: by 2002:a37:8846:: with SMTP id k67mr37079400qkd.214.1546334099555;
        Tue, 01 Jan 2019 01:14:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN54NlAbOnsizJpIQvvnhnNE5K8Uh+hbXRfn3VwR215Ahb9Geqnpmk2/PcTOeagbiX5awPPw
X-Received: by 2002:a37:8846:: with SMTP id k67mr37079378qkd.214.1546334098896;
        Tue, 01 Jan 2019 01:14:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546334098; cv=none;
        d=google.com; s=arc-20160816;
        b=byAzVUGOLZHM5fSf6fn1P9Lxq1bETDCuzAJAj7kZP8zhkBqxHO/hHnNqPV6Md7Q4oP
         30Vl3KshD1oqVUhMFTpxjcIvAeZ832lri/eVl8n/9UhdNqrpunt9DPgORDEPNNlpHuSe
         leNY/ysqCEiJmwXwn2jJAlc1pJ/v91mLmzTXfd2SlO1ZdgF1WuPPFNV10EjpxXu6eEUR
         um0jEGM2/lbX2dGiMlSA2Q5lO5tvhBZCWSodUEnB9T+FrQcJZ/pwbimhcbPK0uz6SUNn
         uOlW4bZ3BnjYTKVnbupf1pHwuGXNnZcJ7U8Ka6NuyzXJkg4XtbjX8WIX3Q3yoRaSJVNt
         lzxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=cvz2o8NSBf7XxfRmfb02P2erO/CmkFs6XkB3BJv/j+Y=;
        b=PkAKr7j7tCnBfJHHXqcow/ZXdB+gI0LcsXVbWeOJo/nMNrqpwb0orxwkUw/B2GUZWi
         El0cKaxzqq9qayY9oAzHHhXN/s/qwNeRppdTGn8X1e6rLeM7Js+lP/tSSBDTOsUYBlc5
         LnNOvxPOof1zvR94SxO21LKGbGhq1Uru30kVynFwvQO1wCgJvfNv8BxCaIu4m9pNMEd3
         U++jSKelDmwsZydEenPAdz3baQRDF9XtY9CiwwI0k9Kl1BKFeOrZcocvrLmC9vDrJVfJ
         FJd9bZOaT6aAGwRPRhwCh8cg5oPN+Q8UpIBn1NTbh2E4XV7hgkQseS7Yt4mTwXr6vF4P
         AIJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q11si900217qvb.83.2019.01.01.01.14.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jan 2019 01:14:58 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x019EAue034711
	for <linux-mm@kvack.org>; Tue, 1 Jan 2019 04:14:58 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pr417ttfh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 01 Jan 2019 04:14:58 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 1 Jan 2019 09:14:56 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 1 Jan 2019 09:14:51 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x019EoB356426542
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 1 Jan 2019 09:14:50 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3F84EA4051;
	Tue,  1 Jan 2019 09:14:50 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 583BAA4040;
	Tue,  1 Jan 2019 09:14:46 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.88.250])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue,  1 Jan 2019 09:14:46 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Fengguang Wu <fengguang.wu@intel.com>,
        Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>,
        Fan Du <fan.du@intel.com>, Fengguang Wu <fengguang.wu@intel.com>,
        kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>,
        Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>,
        Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>,
        Zhang Yi <yi.z.zhang@linux.intel.com>,
        Dan Williams <dan.j.williams@intel.com>
Subject: Re: [RFC][PATCH v2 10/21] mm: build separate zonelist for PMEM and DRAM node
In-Reply-To: <20181226133351.644607371@intel.com>
References: <20181226131446.330864849@intel.com> <20181226133351.644607371@intel.com>
Date: Tue, 01 Jan 2019 14:44:41 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-TM-AS-GCONF: 00
x-cbid: 19010109-0016-0000-0000-0000023E2131
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19010109-0017-0000-0000-0000329721CA
Message-Id: <87sgyc7n9a.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-01_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=571 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901010085
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190101091441.OTiGWCpgzIy64qpvhVXhGF1JxDSyAJEsqXoIJZ73x60@z>

Fengguang Wu <fengguang.wu@intel.com> writes:

> From: Fan Du <fan.du@intel.com>
>
> When allocate page, DRAM and PMEM node should better not fall back to
> each other. This allows migration code to explicitly control which type
> of node to allocate pages from.
>
> With this patch, PMEM NUMA node can only be used in 2 ways:
> - migrate in and out
> - numactl

Can we achieve this using nodemask? That way we don't tag nodes with
different properties such as DRAM/PMEM. We can then give the
flexibilility to the device init code to add the new memory nodes to
the right nodemask

-aneesh

