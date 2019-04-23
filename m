Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3290DC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 11:17:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E142D20811
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 11:17:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E142D20811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75AE76B0007; Tue, 23 Apr 2019 07:17:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70B146B0008; Tue, 23 Apr 2019 07:17:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FA256B000A; Tue, 23 Apr 2019 07:17:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 411DF6B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 07:17:54 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id f138so11992727yba.4
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:17:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=GuGnX6bKv+38iPTn3cEYS0XszQk0dJ3xVg1CPEHLnzk=;
        b=AUavZkMpgoHfiNSltmnvs2cgpm/LjVFQCbkyb+oMNmkldETT3a8+H8M7RfJDT0NrxN
         PqVP2CtwnVwxAVu+oBQJIHUSZNU3jq6S18TCrmTUKKmEJ+7bTz7kkAWXLHWQymksHT57
         gDwZzwZU0+V5k4zORnmPqUz08BgwrAhWA5lTFE1HspeVaX4RE8mCw3dZM/ywbIPr+SSN
         Li+CMiEg9F5OOW/4cYWlElQElHobc3p9x+uiJPxw7HKsYKgzGMhv0KtWPim6lN0GuIFG
         x6+3XcE2SsdKb4uUVM+1rhF2C3GA2PqtdEltq9OeJJaY0dObC0oyZLqwk7SNg/bcGFaq
         M+ig==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) smtp.mailfrom=ldufour@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUvG/iK6ft12tJRN/6tFk3m4xGmWcJXqL3TzmXyorELGrP3oLAZ
	uHUWzSZX1RWle+AQeGPaf4QK+MSQWqfSamR4lLUjkJ1RaMAu0SGNh3MHjoveyOdr4uiv4vdYy61
	jbbEtr9RpWNEYm4eoRl3FeOWTJoO5bmuhT90HvJIqLHsnTDDg3+djGcCxs2QP3go=
X-Received: by 2002:a5b:987:: with SMTP id c7mr20863083ybq.499.1556018273910;
        Tue, 23 Apr 2019 04:17:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2CLssPZWEGPJTAENOKmMb109m25SQzA17mcks3e8vt9Rh8RMcyiEiV4na4HsZLC7KByON
X-Received: by 2002:a5b:987:: with SMTP id c7mr20863009ybq.499.1556018272933;
        Tue, 23 Apr 2019 04:17:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556018272; cv=none;
        d=google.com; s=arc-20160816;
        b=p8x00ZSLf5LlLNjNWjsr3k3UhgEyCgogcR1NYTK8+u1NTPEtYpKjatPe0UHC+L6t0F
         w7JxP1VuAy8lv62Qmtpy6CfDEqGTwz3FpPJ9WljRb2S4gMcc0UvT2YRyHqMx7cmTIRE/
         AYOrWrh3US8ZWuVfSpLfy8lGRCulwsNZMcqHIQOLcihSy+PLtEWuarrWVqk5gbyCXbAB
         42L0u7jHrLTBjks4+0dgDXV4KzX96q8w/mVP4BTNFhDnVXu56oZrzLNM7nt/WzqSRoos
         VSq56RqNVw5YTY0RyIVEUp+hlCF6ZWbK2UG1/fCXwRRcREuau/nPgLwZcIO+sGYwMdig
         HseA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=GuGnX6bKv+38iPTn3cEYS0XszQk0dJ3xVg1CPEHLnzk=;
        b=0ai0OBKO/ObePVq+h2wD5B3Z28EL+0IbKzOhyUvTtXAtV37y6vIRxHrsgEgGnMCAio
         PxBXv3JeXc5RGzK9BCRVxJaeRZYf2PQ0SxRaaYgiOQmHtEvKIuPOtNsXkkJy8fAN3GGK
         0Um2mcOPGsjV0RlzFS5o2614zb++HBDnslzr36kUoshOzrAwFw3XiD32u2MaycpxME+L
         aEwJ/o0iTeUWF9z8eQWgZYcRnPpeDpNXUnaCwINklNWorQphCBvgTtaA1xcHuymjFVnH
         UeuwxkyR0hxQu3VmDm2lFHhYoavV0yJl4yjqksyTPI/tOSlpXwjINwtAurkjpxCNfY1i
         hBOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) smtp.mailfrom=ldufour@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x16si10437883ybj.343.2019.04.23.04.17.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 04:17:52 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of ldufour@linux.vnet.ibm.com) smtp.mailfrom=ldufour@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3NBHijt185380
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 07:17:52 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s1xc11trc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 07:17:48 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 23 Apr 2019 12:16:49 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 23 Apr 2019 12:16:44 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3NBGi4C51249342
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Apr 2019 11:16:44 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E72154203F;
	Tue, 23 Apr 2019 11:16:43 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1E16142041;
	Tue, 23 Apr 2019 11:16:43 +0000 (GMT)
Received: from [9.145.7.116] (unknown [9.145.7.116])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 23 Apr 2019 11:16:43 +0000 (GMT)
Subject: Re: [PATCH] x86/mpx: fix recursive munmap() corruption
To: Michael Ellerman <mpe@ellerman.id.au>,
        Thomas Gleixner <tglx@linutronix.de>,
        Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, rguenther@suse.de, mhocko@suse.com,
        vbabka@suse.cz, luto@amacapital.net, x86@kernel.org,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        stable@vger.kernel.org
References: <20190401141549.3F4721FE@viggo.jf.intel.com>
 <alpine.DEB.2.21.1904191248090.3174@nanos.tec.linutronix.de>
 <87d0lht1c0.fsf@concordia.ellerman.id.au>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 23 Apr 2019 13:16:42 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <87d0lht1c0.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042311-0016-0000-0000-00000271A450
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042311-0017-0000-0000-000032CE0F69
Message-Id: <6718ede2-1fcb-1a8f-a116-250eef6416c7@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-23_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904230080
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 20/04/2019 à 12:31, Michael Ellerman a écrit :
> Thomas Gleixner <tglx@linutronix.de> writes:
>> On Mon, 1 Apr 2019, Dave Hansen wrote:
>>> diff -puN mm/mmap.c~mpx-rss-pass-no-vma mm/mmap.c
>>> --- a/mm/mmap.c~mpx-rss-pass-no-vma	2019-04-01 06:56:53.409411123 -0700
>>> +++ b/mm/mmap.c	2019-04-01 06:56:53.423411123 -0700
>>> @@ -2731,9 +2731,17 @@ int __do_munmap(struct mm_struct *mm, un
>>>   		return -EINVAL;
>>>   
>>>   	len = PAGE_ALIGN(len);
>>> +	end = start + len;
>>>   	if (len == 0)
>>>   		return -EINVAL;
>>>   
>>> +	/*
>>> +	 * arch_unmap() might do unmaps itself.  It must be called
>>> +	 * and finish any rbtree manipulation before this code
>>> +	 * runs and also starts to manipulate the rbtree.
>>> +	 */
>>> +	arch_unmap(mm, start, end);
>>
>> ...
>>    
>>> -static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
>>> -			      unsigned long start, unsigned long end)
>>> +static inline void arch_unmap(struct mm_struct *mm, unsigned long start,
>>> +			      unsigned long end)
>>
>> While you fixed up the asm-generic thing, this breaks arch/um and
>> arch/unicorn32. For those the fixup is trivial by removing the vma
>> argument.
>>
>> But itt also breaks powerpc and there I'm not sure whether moving
>> arch_unmap() to the beginning of __do_munmap() is safe. Micheal???
> 
> I don't know for sure but I think it should be fine. That code is just
> there to handle CRIU unmapping/remapping the VDSO. So that either needs
> to happen while the process is stopped or it needs to handle races
> anyway, so I don't see how the placement within the unmap path should
> matter.

My only concern is the error path.
Calling arch_unmap() before handling any error case means that it will 
have to be undo and there is no way to do so.

I don't know what is the rational to move arch_unmap() to the beginning 
of __do_munmap() but the error paths must be managed.

>> Aside of that the powerpc variant looks suspicious:
>>
>> static inline void arch_unmap(struct mm_struct *mm,
>>                                unsigned long start, unsigned long end)
>> {
>>   	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
>>                  mm->context.vdso_base = 0;
>> }
>>
>> Shouldn't that be:
>>
>>   	if (start >= mm->context.vdso_base && mm->context.vdso_base < end)
>>
>> Hmm?
> 
> Yeah looks pretty suspicious. I'll follow-up with Laurent who wrote it.
> Thanks for spotting it!

I've to admit that I had to read that code carefully before answering.

There are 2 assumptions here:
  1. 'start' and 'end' are page aligned (this is guaranteed by 
__do_munmap().
  2. the VDSO is 1 page (this is guaranteed by the union vdso_data_store 
on powerpc).

The idea is to handle a munmap() call surrounding the VDSO area:
       | VDSO |
  ^start         ^end

This is covered by this test, as the munmap() matching the exact 
boundaries of the VDSO is handled too.

Am I missing something ?

Cheers,
Laurent.

