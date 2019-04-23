Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6953BC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:48:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25A9D218D2
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:48:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25A9D218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC1FC6B0007; Tue, 23 Apr 2019 11:48:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B70E16B0008; Tue, 23 Apr 2019 11:48:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A607B6B000A; Tue, 23 Apr 2019 11:48:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 57C556B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:48:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h22so8250754edh.1
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:48:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=eBYgKhBQ6DJLSSHs292E3JGssLX7imKmd7rLs1+3i0U=;
        b=cBOhMy9Eu1GP89cnOHulJ4TYyerYynAw0TsOCmFQz3m0vqYLqQ6huuUPwsHhTBFQiQ
         TlgJP1ZJclu0pH9/Gx+fpFrcasn6cOODPNxQG1lG2mdKVS+we38KHi7jpEFxs4WkFY0T
         2+R+0Nf6EC3MoSnmqkrOKGGDYHRgVnlXf0Upt7OdHoUKSGrDAbjyAIR7oH/2D1n/MVw9
         /8caSxvNMKjNPjxdamfwFh2Lmd4/W2UEGQ444xOsBMGEO1EmlsRF+wwhmGIvDEKoEoa0
         IoawhFcnIHSVtb4tCeSudLR6Sc88MBl8hk1/2aYVl36WCvrQvCV/bVCDGDzAIN31h4Lv
         J9BA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAViK704Jo7X/+F/4WgreOa5DGwDXM9D6TbNnp0TWddrGxkbzHcV
	KOQG6zR3xmI5joeEfsGQ0tCW85qD89L9H6S+iAE5QpzZF4vv3dKoS0cz46Kf8oxI83YzMIvxGSQ
	H7qGIF9yzw8WMKJq7yZAsPekF1Kifsu5KjtZMPfEXSSK6ffM2IBRKAaICgQfnzBimZQ==
X-Received: by 2002:a17:906:2785:: with SMTP id j5mr2219480ejc.94.1556034491912;
        Tue, 23 Apr 2019 08:48:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhVTOxGsGghhj03rhN9zH0/iGeBuSQOqSulvR6z1mCAsNKqjmfeVCdGMBbxnnLAXuAZuYG
X-Received: by 2002:a17:906:2785:: with SMTP id j5mr2219434ejc.94.1556034491188;
        Tue, 23 Apr 2019 08:48:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556034491; cv=none;
        d=google.com; s=arc-20160816;
        b=ipfCNo+bjtdboRqqU77BOE2qmt3eGvM2hbXaMeKOwvQPukJKe/eXkjSPC5GNfM3xo9
         O+DxDppxKuK1yqjfodSQJfvE+ugAENxL5crwhvfK4MTQ197hsxaOScXLiD8RIIxjCima
         i/aV9m8AuoHA/VOkV8aH0DItUwT6zJ03SAiLCYCiTGrIyWlHtLlyCzvoU5R9rLqaeQDq
         mlE2LyPRsh7BmK5p/I4q/a2A/O+1p67ozA+HE/90pSyIU7GJAKywDfteBOxGGXQN3gat
         baoHJ/qw5LA+n/cUZSZTbgDHF3jg3v3yZNCEUsHbp8n1a474plszIeMlnFTW/gkjzJ5f
         0gcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=eBYgKhBQ6DJLSSHs292E3JGssLX7imKmd7rLs1+3i0U=;
        b=OGH189TizIPz0KZE4IMUQcQ7U/K/QsnAC+IwKRyAa4HugjlFcb8XXSbL3FeQh1OE4U
         8nUvb9WD65iIAUM4jc41zqND4Zv//ZI/M1mLf7tL3YwrTyf9yEx1TToO82N3n17Ii1PQ
         hMkqYe6NgUeCEnAlH+0dWJU5/aGtE/vhwTsRpBfWTX3hMDKWFY2yZZkY+kkqbg9o6QSe
         /XIxIfS9dVCIun29tavO2dZR4lNsfmAUFWaLKxKGI14lwgUDAsqAwHlBby+xhoTRUVSc
         p56ddBfpbyNjas7fJgttmJbKbCzZSjF9B5dTzGHPhdV/DiBayF0ih36UXBXiefK98qs4
         vqkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f43si7772700eda.230.2019.04.23.08.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 08:48:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3NFf5XV077494
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:48:09 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s24s4u2g4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:48:09 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 23 Apr 2019 16:48:07 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 23 Apr 2019 16:47:57 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3NFluKA53149906
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Apr 2019 15:47:56 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1312442042;
	Tue, 23 Apr 2019 15:47:56 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A8A414203F;
	Tue, 23 Apr 2019 15:47:53 +0000 (GMT)
Received: from [9.145.7.116] (unknown [9.145.7.116])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 23 Apr 2019 15:47:53 +0000 (GMT)
Subject: Re: [PATCH v12 07/31] mm: make pte_unmap_same compatible with SPF
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
        kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
        jack@suse.cz, aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
        mpe@ellerman.id.au, paulus@samba.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        David Rientjes <rientjes@google.com>,
        Jerome Glisse <jglisse@redhat.com>,
        Ganesh Mahendran <opensource.ganesh@gmail.com>,
        Minchan Kim <minchan@kernel.org>,
        Punit Agrawal <punitagrawal@gmail.com>,
        vinayak menon <vinayakm.list@gmail.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        zhong jiang <zhongjiang@huawei.com>,
        Haiyan Song <haiyanx.song@intel.com>,
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Michel Lespinasse <walken@google.com>,
        Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
        paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
        linuxppc-dev@lists.ozlabs.org, x86@kernel.org
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-8-ldufour@linux.ibm.com>
 <20190423154351.GB19031@bombadil.infradead.org>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Tue, 23 Apr 2019 17:47:53 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423154351.GB19031@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042315-0008-0000-0000-000002DCE11E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042315-0009-0000-0000-0000224932B9
Message-Id: <760693af-d180-8c9a-249d-bcf939d7f621@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-23_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=745 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904230106
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 23/04/2019 à 17:43, Matthew Wilcox a écrit :
> On Tue, Apr 16, 2019 at 03:44:58PM +0200, Laurent Dufour wrote:
>> +static inline vm_fault_t pte_unmap_same(struct vm_fault *vmf)
>>   {
>> -	int same = 1;
>> +	int ret = 0;
> 
> Surely 'ret' should be of type vm_fault_t?

Nice catch !

> 
>> +			ret = VM_FAULT_RETRY;
> 
> ... this should have thrown a sparse warning?

It should have, but I can't remember having see it, weird...

