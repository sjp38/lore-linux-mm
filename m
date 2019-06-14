Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1EC6C46477
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:55:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 663A42183F
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:55:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 663A42183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 027916B000E; Fri, 14 Jun 2019 12:55:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F18D16B0266; Fri, 14 Jun 2019 12:55:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E074D6B0269; Fri, 14 Jun 2019 12:55:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id BAA3B6B000E
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:55:28 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id y205so3047884ywy.19
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:55:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=/s4y42nBn8AgCUhw9YsRi/H1sPSM3a4uIf8i/l701S8=;
        b=CFVXPJDshml/jbpt0SBXAWkdL8Z3Gw12/PmPq1P5bdtKtRLcMwORGv3M773G5VMcIq
         S1zoHXZh3UwZRH9CqsVPfiMKOTIZbShQJuQaaJ0dFH4UYqoN3XlUBOFSVS2otxXou5PA
         8DWpst0It5gXFwWkOWHynYIgKrKLJtHa2ViFipYGrY6wbNBGOZ1SRKdl4o9AijMFD8eW
         OUE0pZ0/AXK+hvzJuXjearx+IWg3uFzG8aQgEr/GuhwTJJs512MZKDvpXCbkfO2NA/rO
         MlYjEaU7HkbBSXQpnta/Vs2eBVnapjjVR37KZP7n2y+Ft5ObFyUp1Y1kLJbA7hPiZ0nh
         R17w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW0PZVmO/YILypDfhyvom5eearDkKAe2GZG/Dr6wA+K501b95PI
	nDt/V9eE0+EIG+FnU9hXW6A5ywH+nGi49co3GJ0vylSQn3nITPKyBssc8ksyJbW8qQMONOe/ZUM
	6lacP2kvhxrS8D+8rHe/DQQuMHoZTTf6NjMrsvMq3NoJ+iih2jh6rPgpnRr7ZeTW6FA==
X-Received: by 2002:a81:8357:: with SMTP id t84mr31395113ywf.109.1560531328536;
        Fri, 14 Jun 2019 09:55:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzseCEPZMVUmKEuD2JJ1zIqJIV2u9Xvp5g5v4GkX9f8fP08iV9ara1fFMvugRdU/HATmm/g
X-Received: by 2002:a81:8357:: with SMTP id t84mr31395092ywf.109.1560531328103;
        Fri, 14 Jun 2019 09:55:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560531328; cv=none;
        d=google.com; s=arc-20160816;
        b=Ky1EsDk0kS818Vn+a6Rio5uhcVt2mka/cpDxGmxSJa8i5VSvQGi787iRYg1pxdCE0y
         FGqnvXsD03El9iMtZ/hd12ScoBX6/AlRRE+ieU97mnPletcJvfdhWvWgPDBuhqumuK37
         QEmhayDEKUbxeymj3Z2YEVievf51GFMyJ4bJnVDcw/cU5SHTYgIdGfipI21+LdwBP0rA
         9fTOTRPEGygh52f8xchQBV1o3tBwPzEjO74jE69X0DRV55HzSwYOIWzHmHWSHXC0d41v
         Y0LTrtsFVhh17bPrV4ekGcEIKckXb70f7k4SLsIZviY8whG4dJCBAHskZ+cIGBtFIiWI
         Yi3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=/s4y42nBn8AgCUhw9YsRi/H1sPSM3a4uIf8i/l701S8=;
        b=XEv6rF4q+8tXb2cwxxe9lnHrOJ1HIVw31oYF/h3nAFnEeGqW1XDts96xbC5JOxgnRz
         pqssuaRcihPrhxxln8OECMp5o8WiiPjuyoVcvA1iJSJmL1xgIwBQxKcIjaDfMY5MtHFZ
         eA+jUekMccFgqi3HlUYi2JY7l3lMRrXavyjqdsvZLWletdoru7/1RkP+FGg3Pltv5MZ1
         UPcQReqrAsLlrYQrqDyw3KrdAzjFAGBwIpG8rOKedKZmHQdYW/UlhtmOcKM1NbVci5C8
         SI7P3St1W5A2VNdYa2ssDRQMZGxXdlMzIf7Adky46GiVfm2AlbP0TSTeoqOymvn73kUL
         /CuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u40si1190415ybi.44.2019.06.14.09.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 09:55:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5EGrTLN124964
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:55:27 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t4c3vh8s0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:55:27 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Fri, 14 Jun 2019 17:55:26 +0100
Received: from b03cxnp07029.gho.boulder.ibm.com (9.17.130.16)
	by e33.co.us.ibm.com (192.168.1.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 14 Jun 2019 17:55:23 +0100
Received: from b03ledav001.gho.boulder.ibm.com (b03ledav001.gho.boulder.ibm.com [9.17.130.232])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5EGtM0g34144540
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 14 Jun 2019 16:55:22 GMT
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 622AB6E059;
	Fri, 14 Jun 2019 16:55:22 +0000 (GMT)
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BF1B66E054;
	Fri, 14 Jun 2019 16:55:19 +0000 (GMT)
Received: from [9.199.60.77] (unknown [9.199.60.77])
	by b03ledav001.gho.boulder.ibm.com (Postfix) with ESMTP;
	Fri, 14 Jun 2019 16:55:19 +0000 (GMT)
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: Dan Williams <dan.j.williams@intel.com>
Cc: Oscar Salvador <osalvador@suse.de>, Qian Cai <cai@lca.pw>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        jmoyer <jmoyer@redhat.com>, linux-nvdimm <linux-nvdimm@lists.01.org>
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
 <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
 <20190614153535.GA9900@linux>
 <c3f2c05d-e42f-c942-1385-664f646ddd33@linux.ibm.com>
 <CAPcyv4j_QQB8SrhTqL2mnEEHGYCg4H7kYanChiww35k0fwNv8Q@mail.gmail.com>
 <24fcb721-5d50-2c34-f44b-69281c8dd760@linux.ibm.com>
 <CAPcyv4ixq6aRQLdiMAUzQ-eDoA-hGbJQ6+_-K-nZzhXX70m1+g@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Fri, 14 Jun 2019 22:25:18 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4ixq6aRQLdiMAUzQ-eDoA-hGbJQ6+_-K-nZzhXX70m1+g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19061416-0036-0000-0000-00000ACBC6A1
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011261; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01217925; UDB=6.00640497; IPR=6.00999046;
 MB=3.00027312; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-14 16:55:25
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061416-0037-0000-0000-00004C39CFB8
Message-Id: <16108dac-a4ca-aa87-e3b0-a79aebdcfafd@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=27 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906140137
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/14/19 10:06 PM, Dan Williams wrote:
> On Fri, Jun 14, 2019 at 9:26 AM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:

>> Why not let the arch
>> arch decide the SUBSECTION_SHIFT and default to one subsection per
>> section if arch is not enabled to work with subsection.
> 
> Because that keeps the implementation from ever reaching a point where
> a namespace might be able to be moved from one arch to another. If we
> can squash these arch differences then we can have a common tool to
> initialize namespaces outside of the kernel. The one wrinkle is
> device-dax that wants to enforce the mapping size,

The fsdax have a much bigger issue right? The file system block size is 
the same as PAGE_SIZE and we can't make it portable across archs that 
support different PAGE_SIZE?

-aneesh

