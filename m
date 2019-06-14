Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 212E3C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:40:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD27F217D6
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:40:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD27F217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92C7C6B000D; Fri, 14 Jun 2019 13:40:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DD356B000E; Fri, 14 Jun 2019 13:40:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A5156B0266; Fri, 14 Jun 2019 13:40:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFDF6B000D
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:40:46 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id x24so3564953ioh.16
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:40:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jybkxf8O5qfL62/ny2FSdzWU5P15Ku2vs9D3Fl1U564=;
        b=bqSbJXNAFeID9BqQas1VmePfWdUlI/ZbyCz/KttNWsZ3LmBwEgN2gDFyy2PA0jggfS
         d3IQNTZ7+CW/NQYs1ePt4aZOiTwP9iS8I4F2W6d+FK4svjyp7vY2xIEmrBYKoFgdcOX8
         g28G4AVjEyGWLFaY2U54ilpYLPhYXJyhJixcejvWb6ocsHbCzQ7vwGOU7RPCO/mTlk9/
         Lc9TirHrmGYyl+FxOG93gDlfI83448Vm8ez6B2H5VTEkqNwU/w4tHF5KGlgV4GVlMn88
         NyByYCiwzoERLt/oRLZPqBbpYH88zs7hBxxIxU1AJh5sLPgsS9lek1srtmJTyiIRYUQE
         cVWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWv2/gFrcZsZmbJkunkmmmJ8cFhC7GOfMduAufZgAbeexbsyFek
	9rtBEU7jBocRU9C5gjwIYO8y3P2WW2x/iMpazVufaCkgiUa6g06Doc8lCVwy6hO8kXayYtVHdBl
	G9Td/MLXOi8Qrvzh+hfomiV6J7oGEXgxi7uN22Z9CPjxqGaEt314ygkZXjSGh8DDvpw==
X-Received: by 2002:a6b:6a01:: with SMTP id x1mr9299917iog.77.1560534046095;
        Fri, 14 Jun 2019 10:40:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7Qe4vKEZaKeg/tfXhKZTS8SMiYZc6Ug3oLGhRVBzNA6ejNOH8emMcvG4YE9GCXKs5AfKd
X-Received: by 2002:a6b:6a01:: with SMTP id x1mr9299854iog.77.1560534045207;
        Fri, 14 Jun 2019 10:40:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560534045; cv=none;
        d=google.com; s=arc-20160816;
        b=XgjAh7rYWc8fVXQmYt3OlsoT0vU78eTmzbNNepLUfa8mHyvhLciyK5/7c2noRBEjOa
         kfRFQcCEnZxicS6t7coUayTWui4pUya0xWUDcp0sfIE7G7pi12vejcwuhZTe1m5TvGRK
         OzI3ps99tgJC4WGI5Vpz/yLAGJ/ssRk7VIMhFxuyS+anb7DN69DhqAFzLwV8vlo/7meZ
         Q66m19aiymy4Lf3mKc6cePVuatN72+BF+u/xagCusvE7mhfNV5HPmrfm8d6OeZReS0x7
         hzc+IZVSeia+liXNA0BU8gi++ZevscVQmRFKr9H/mX0C0BlkZhwDjipfnB1jLxH4eZQi
         MItQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jybkxf8O5qfL62/ny2FSdzWU5P15Ku2vs9D3Fl1U564=;
        b=mJHiTgYyghMCWALVruU0QnYiGQ69HItV/w+xFHS46TthrDr91gOXJ6FrevMH874PIx
         bjvf/QWgO4JH0w1WReMRJu2u71ZM60cQsa8XnbQ/sdumVLVdQj0B1Ii/yFcGawrSbvoE
         MjI9l7F3MawcNDHmIXVpaU2zPOP213z8WGeyYWJg7IAgTrNG/B8sv5DTY3nnvsrD7KFF
         caGU2/xM4m7pqrQgPtGS0nuB4Y01FVi+dffxpdRYdsuhD4c7i9Pscngp32VexDeU/jGV
         3WyrFsDnTcEDT6e1l12K12cQSfaPo2TZNaOnOzw64ooBcpKLBmLdt8qocOoqnPiNwXD7
         lrVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h144si4014596iof.146.2019.06.14.10.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 10:40:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5EHaflD045564;
	Fri, 14 Jun 2019 13:40:42 -0400
Received: from ppma01wdc.us.ibm.com (fd.55.37a9.ip4.static.sl-reverse.com [169.55.85.253])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t4ehrmetu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 14 Jun 2019 13:40:42 -0400
Received: from pps.filterd (ppma01wdc.us.ibm.com [127.0.0.1])
	by ppma01wdc.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x5EHdUO1029699;
	Fri, 14 Jun 2019 17:40:43 GMT
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by ppma01wdc.us.ibm.com with ESMTP id 2t1qcty05s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 14 Jun 2019 17:40:43 +0000
Received: from b03ledav001.gho.boulder.ibm.com (b03ledav001.gho.boulder.ibm.com [9.17.130.232])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5EHeeTL17236386
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 14 Jun 2019 17:40:40 GMT
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7C4B16E04C;
	Fri, 14 Jun 2019 17:40:40 +0000 (GMT)
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D6FEA6E050;
	Fri, 14 Jun 2019 17:40:37 +0000 (GMT)
Received: from [9.199.60.77] (unknown [9.199.60.77])
	by b03ledav001.gho.boulder.ibm.com (Postfix) with ESMTP;
	Fri, 14 Jun 2019 17:40:37 +0000 (GMT)
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
        Oscar Salvador <osalvador@suse.de>, Qian Cai <cai@lca.pw>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nvdimm <linux-nvdimm@lists.01.org>
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
 <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
 <20190614153535.GA9900@linux>
 <c3f2c05d-e42f-c942-1385-664f646ddd33@linux.ibm.com>
 <CAPcyv4j_QQB8SrhTqL2mnEEHGYCg4H7kYanChiww35k0fwNv8Q@mail.gmail.com>
 <24fcb721-5d50-2c34-f44b-69281c8dd760@linux.ibm.com>
 <CAPcyv4ixq6aRQLdiMAUzQ-eDoA-hGbJQ6+_-K-nZzhXX70m1+g@mail.gmail.com>
 <16108dac-a4ca-aa87-e3b0-a79aebdcfafd@linux.ibm.com>
 <x49ef3wytzz.fsf@segfault.boston.devel.redhat.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Message-ID: <4e912883-4a85-6579-0779-6c366ccee407@linux.ibm.com>
Date: Fri, 14 Jun 2019 23:10:36 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <x49ef3wytzz.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=27 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906140142
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/14/19 10:38 PM, Jeff Moyer wrote:
> "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
> 
>> On 6/14/19 10:06 PM, Dan Williams wrote:
>>> On Fri, Jun 14, 2019 at 9:26 AM Aneesh Kumar K.V
>>> <aneesh.kumar@linux.ibm.com> wrote:
>>
>>>> Why not let the arch
>>>> arch decide the SUBSECTION_SHIFT and default to one subsection per
>>>> section if arch is not enabled to work with subsection.
>>>
>>> Because that keeps the implementation from ever reaching a point where
>>> a namespace might be able to be moved from one arch to another. If we
>>> can squash these arch differences then we can have a common tool to
>>> initialize namespaces outside of the kernel. The one wrinkle is
>>> device-dax that wants to enforce the mapping size,
>>
>> The fsdax have a much bigger issue right? The file system block size
>> is the same as PAGE_SIZE and we can't make it portable across archs
>> that support different PAGE_SIZE?
> 
> File system blocks are not tied to page size.  They can't be *bigger*
> than the page size currently, but they can be smaller.
> 


ppc64 page size is 64K.

> Still, I don't see that as an arugment against trying to make the
> namespaces work across architectures.  Consider a user who only has
> sector mode namespaces.  We'd like that to work if at all possible.
> 

agreed. I was trying to list out the challenges here.

-aneesh

