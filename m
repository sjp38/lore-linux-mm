Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB803C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:07:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7333521850
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:07:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7333521850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14BFA6B000A; Tue, 23 Apr 2019 13:07:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FC126B000E; Tue, 23 Apr 2019 13:07:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F06A26B0010; Tue, 23 Apr 2019 13:07:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A3BE96B000A
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:07:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id q17so8315402eda.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:07:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=I4JYvwZB6x3/fJICgJ+EN0L57JxqwfTzPwCcnaOUrfw=;
        b=eCvPxpwr8nWEnIUq5CJdBuMhIaL6xSRcmT9tpi2ijc92ldMmtkVzY4TELcSUW9hh27
         X0/fpqlYjQtGRG6+rr89qyO/khvGOF0kYtJeAExCRt8eHw77fxu3/LkS4IMm3pKLNzL0
         FzOL5hP650UmGDjknQTQM/QWCSXOJ1fSA3qqo1zW/vaCEf/OtAzBYF0tXrqDctgvVOVE
         nAwzGm4mfvk+6Bs0HimOpdKtGN5pTm9H1Ccda3WxC+1h18TL8X6eYErXtaCURO9M6dFP
         2MEz5bBSr30YFmEWLVBbJdbBUqn6rsKP7Q3hZR/g09kYLMJPsWuPQ9QX28jZsJvmFe1Q
         2SOg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) smtp.mailfrom=ldufour@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW+yBhfYT6fMbaKQE+sy/yE9mU++C/4fxRR1aovVVCRYhWWnAz0
	N3eoAyOswL949hhl8KqJkWpsOF9Pn0uCJRfFSOA9+DiKqOBn416py+1+f6EGAfNTKhd/tGjvt1d
	eilOLeCmDWD/IDc1lx/9qyA1aJd9CJ1KyHXW6mDWMo1TWqyGYcQMHkYjpS09Xxc0=
X-Received: by 2002:a50:9eec:: with SMTP id a99mr16695391edf.186.1556039278215;
        Tue, 23 Apr 2019 10:07:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6tspHgazSZEiKkJpBN19f/9n5eBcQHHyujmvHUWUr1lLz0EX3J1YAQu7ORE0l7HNPvFvr
X-Received: by 2002:a50:9eec:: with SMTP id a99mr16695278edf.186.1556039276975;
        Tue, 23 Apr 2019 10:07:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556039276; cv=none;
        d=google.com; s=arc-20160816;
        b=M5ljU9Kh6QLNHvM7dDWk11QUsUp+R0GNU7RcRQ+INgEg9NaktGve+2FrdvvEi0dJTL
         n+rZczGlYNfX0c7px5I+4f00eYTZkrprLFH56zgMWBdV9k3zKk1aRMfRzPrZYSB1ybsI
         4GwfexvB65pC0YXoha8lqhYjkJmTreggFWpiNRE0R8PITN0n4fKM2gGgZOUJk3sCpLVL
         NzQVbLmXEFpUpQ63QsnOyJHgGJOo6YK+rzAXdTOw3TYSfki7jaTu66pEMICp1FXB7avu
         jahs2BqysLUs1J7rkzuu18ffQW5R1KXAWTzQNkOpNr2uYs+nmqNUiL/LSNKc+F6dpW/5
         rsCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=I4JYvwZB6x3/fJICgJ+EN0L57JxqwfTzPwCcnaOUrfw=;
        b=I32ZgjcqvFvTD9LPadEq+Fsbaa2VCNRPcfVPwttq5XkaGEoZjfod6T7Df0EYomYVAH
         jCNuRwdDpYRxgu3vgaYBmoSEX/FkNmMAh4zSM7jOPKWadQoMOhZ5FwrlUqlpAdeVpyA4
         J4xS8bzcujT2Q4Kx1o9quIHd11JpkjTOlygkae7SH0kLNhpOL6MGg9yel5pQ940MkKZ1
         W19zo7XG+CvpdlpI+fi4SQ/kW/ACpIIaCeacZU9HkagxkR1+aTzq/bjWeC2V1z7kpBSO
         OZ2VQf1M4b3zca/UmYmEWHYAZ/MObvHBnqi7/DLKwx2aMv3w0t/fdCBBJOKYRAkLyWmT
         gWpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) smtp.mailfrom=ldufour@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m18si10972edr.89.2019.04.23.10.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 10:07:56 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) smtp.mailfrom=ldufour@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3NH47a3092818
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:07:55 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s24j9xr5s-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:07:54 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 23 Apr 2019 18:07:52 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 23 Apr 2019 18:07:48 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3NH7lCd8126550
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Apr 2019 17:07:47 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 72F404204F;
	Tue, 23 Apr 2019 17:07:47 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A39DA42041;
	Tue, 23 Apr 2019 17:07:46 +0000 (GMT)
Received: from [9.145.7.116] (unknown [9.145.7.116])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 23 Apr 2019 17:07:46 +0000 (GMT)
Subject: Re: [PATCH] x86/mpx: fix recursive munmap() corruption
To: Dave Hansen <dave.hansen@intel.com>,
        Michael Ellerman
 <mpe@ellerman.id.au>,
        Thomas Gleixner <tglx@linutronix.de>,
        Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, rguenther@suse.de, mhocko@suse.com,
        vbabka@suse.cz, luto@amacapital.net, x86@kernel.org,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        stable@vger.kernel.org
References: <20190401141549.3F4721FE@viggo.jf.intel.com>
 <alpine.DEB.2.21.1904191248090.3174@nanos.tec.linutronix.de>
 <87d0lht1c0.fsf@concordia.ellerman.id.au>
 <6718ede2-1fcb-1a8f-a116-250eef6416c7@linux.vnet.ibm.com>
 <4f43d4d4-832d-37bc-be7f-da0da735bbec@intel.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 23 Apr 2019 19:07:45 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <4f43d4d4-832d-37bc-be7f-da0da735bbec@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042317-0008-0000-0000-000002DCF296
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042317-0009-0000-0000-000022494472
Message-Id: <4e1bbb14-e14f-8643-2072-17b4cdef5326@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-23_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904230117
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 23/04/2019 à 18:04, Dave Hansen a écrit :
> On 4/23/19 4:16 AM, Laurent Dufour wrote:
>> My only concern is the error path.
>> Calling arch_unmap() before handling any error case means that it will
>> have to be undo and there is no way to do so.
> 
> Is there a practical scenario where munmap() of the VDSO can split a
> VMA?  If the VDSO is guaranteed to be a single page, it would have to be
> a scenario where munmap() was called on a range that included the VDSO
> *and* other VMA that we failed to split.
> 
> But, the scenario would have to be that someone tried to munmap() the
> VDSO and something adjacent, the munmap() failed, and they kept on using
> the VDSO and expected the special signal and perf behavior to be maintained.

I've to admit that this should not be a common scenario, and unmapping 
the VDSO is not so common anyway.

> BTW, what keeps the VDSO from merging with an adjacent VMA?  Is it just
> the vm_ops->close that comes from special_mapping_vmops?

I'd think so.

>> I don't know what is the rational to move arch_unmap() to the beginning
>> of __do_munmap() but the error paths must be managed.
> 
> It's in the changelog:
> 
> 	https://patchwork.kernel.org/patch/10909727/
> 
> But, the tl;dr version is: x86 is recursively calling __do_unmap() (via
> arch_unmap()) in a spot where the internal rbtree data is inconsistent,
> which causes all kinds of fun.  If we move arch_unmap() to before
> __do_munmap() does any data structure manipulation, the recursive call
> doesn't get confused any more.

If only Powerpc is impacted I guess this would be fine but what about 
the other architectures?

>> There are 2 assumptions here:
>>   1. 'start' and 'end' are page aligned (this is guaranteed by __do_munmap().
>>   2. the VDSO is 1 page (this is guaranteed by the union vdso_data_store on powerpc)
> 
> Are you sure about #2?  The 'vdso64_pages' variable seems rather
> unnecessary if the VDSO is only 1 page. ;)

Hum, not so sure now ;)
I got confused, only the header is one page.
The test is working as a best effort, and don't cover the case where 
only few pages inside the VDSO are unmmapped (start > 
mm->context.vdso_base). This is not what CRIU is doing and so this was 
enough for CRIU support.

Michael, do you think there is a need to manage all the possibility 
here, since the only user is CRIU and unmapping the VDSO is not a so 
good idea for other processes ?

