Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF274C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 16:44:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9E9F206BF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 16:44:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9E9F206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9429D6B0003; Thu, 25 Apr 2019 12:44:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C97B6B0005; Thu, 25 Apr 2019 12:44:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76A316B0006; Thu, 25 Apr 2019 12:44:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 370016B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:44:16 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i35so114209plb.7
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 09:44:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=iDHaIDNyQH7Hyi60UrKxWI+lbyHTcuHsGYWpKgBd8Xg=;
        b=BVNZF8Eg0U4QA1lupddXMUYk++oSLDm0kw+w4fcsW8CtouozGVqLVHGjSYYgjSoPRz
         7xZPA9tQLwgjEIYGsNaiZmhsNyek5UusWrtIg6cfrvR53tjJyNFXrtIvIlobbzsNTApA
         jr2fs2FW0sOAjmFbM5fVBya17+tb6Pl9+aOSAsub+m4ZrCrv+W/KHSw1rrgnqQKCBBFx
         yYvC0d2pam5SKzDQT7W6F1YUhc494r6TtuZkQvwifXemEa0LEyFDJf3c8SD2arm4Z46c
         0va0yg5lIyt1r4RgsysvhBKc0Co8zTGhysz5VfrsNf5Urk5lYjn028gT2lRbl2mG2s+U
         LNtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUEiaGUTMZ4seJ1BU7VAShCtL+G6EFT+zPbnQieT6kpuZWo9sXC
	rWInK0mBRUZ/X65QOPgUQggEcFePR5x4q55zSZNHOejLARV4w2QfdLJUs+RRgFuH9QCCE9vAZw8
	XAV/IxIf14ewk4MDmpje8+hxIpNoViQlz9kbxF4h6kvZ+Uh859hDYOp8yeMfbFzKTpQ==
X-Received: by 2002:a62:e215:: with SMTP id a21mr41837627pfi.30.1556210655782;
        Thu, 25 Apr 2019 09:44:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkJylOLdyza32kkNAWpOnEZixfPElJjze0y7kyNyrIKdvOrsfBQKjnoIxQi05z6Zg4wkhk
X-Received: by 2002:a62:e215:: with SMTP id a21mr41837558pfi.30.1556210654983;
        Thu, 25 Apr 2019 09:44:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556210654; cv=none;
        d=google.com; s=arc-20160816;
        b=VZB4vXw4907FFAqn2tf55c3LrzrWg2CUKvo9FQle2REZ+wuSOi7ihL3+gF7+YKZiw/
         GHSBmvq8PAlGAEexgJEZeRWi+il/OKbFn9PuJUEDSnciP/fzyiKFI7uoREcH8DqUTqnw
         3Eh9xlZygwfTKt4gxMB3rvRk0SPtjbiKULDqjRK4ze2nlnTwBOMlqohNqWN00Uui2+kz
         Ja0rMbRJ+WFZxXYUmtIr/tfSK0Ixuf8CL9UMRIKpfn8fAm1Wzu9AO1r4YHv6NHR1HWyK
         UdL3P8MYhUdT5I7W4n0tVBI94D7n/fGdkeFBeDQeNCpAOBEfdANNFwH1mBnYCnxEZ/qS
         JHlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iDHaIDNyQH7Hyi60UrKxWI+lbyHTcuHsGYWpKgBd8Xg=;
        b=0chWyhUmW17R/eNAKYB2EhecaiQA5P+7WJw15VR/qcJtvUesS9ht6vvWgVg6NsZorI
         CWp4T+BDt6xU0cJcQnyIM3ZmXth4R+VxOUaI8JN/Dginv0DTHn6tSkNHXRxVoPLXC2le
         4WRsNxQo+QURTraSQe21N+9M4wRusCzP7atRENiIMpE0AFmFirKjUmQ6qMNNkHT4W2Mg
         y1vLpyP5K8m3m2QynMY4gXn+c/SmIgcfoD4VjoQt2An2f4sX4AeBvOMOEov/X5k7joDx
         oxWjySzLvjEIbSaRj9EON6ZhZ2U7aR6DNG6m3wUVkcl/SI/tpQlv1JZ7kT2T+hngpxLZ
         QPLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id w10si4476481pgr.296.2019.04.25.09.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 09:44:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R471e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQE6Yfd_1556210649;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TQE6Yfd_1556210649)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 26 Apr 2019 00:44:12 +0800
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@suse.com, rientjes@google.com,
 kirill@shutemov.name, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org__handle_mm_fault
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <a0fa99eb-0efa-25ac-9228-167e89179549@suse.cz>
 <cca0cab8-c1a5-2ea5-0433-964b8166f54a@linux.alibaba.com>
 <e9feaee4-4276-e672-c852-b64fd8965838@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <cdd6dc2a-f469-d2f1-7465-d507a188213f@linux.alibaba.com>
Date: Thu, 25 Apr 2019 09:44:06 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <e9feaee4-4276-e672-c852-b64fd8965838@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/24/19 9:17 AM, Vlastimil Babka wrote:
> On 4/24/19 5:47 PM, Yang Shi wrote:
>>
>> On 4/24/19 6:10 AM, Vlastimil Babka wrote:
>>> On 4/23/19 6:43 PM, Yang Shi wrote:
>>>> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
>>>> vma") introduced THPeligible bit for processes' smaps. But, when checking
>>>> the eligibility for shmem vma, __transparent_hugepage_enabled() is
>>>> called to override the result from shmem_huge_enabled().  It may result
>>>> in the anonymous vma's THP flag override shmem's.  For example, running a
>>>> simple test which create THP for shmem, but with anonymous THP disabled,
>>>> when reading the process's smaps, it may show:
>>>>
>>>> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
>>>> Size:               4096 kB
>>>> ...
>>>> [snip]
>>>> ...
>>>> ShmemPmdMapped:     4096 kB
>>> But how does this happen in the first place?
>>> In __handle_mm_fault() we do:
>>>
>>>           if (pmd_none(*vmf.pmd) && __transparent_hugepage_enabled(vma)) {
>>>                   ret = create_huge_pmd(&vmf);
>>>                   if (!(ret & VM_FAULT_FALLBACK))
>>>                           return ret;
>>>
>>> And __transparent_hugepage_enabled() checks the global THP settings.
>>> If THP is not enabled / is only for madvise and the vma is not madvised,
>>> then this should fail, and also khugepaged shouldn't either run at all,
>>> or don't do its job for such non-madvised vma.
>> If __transparent_hugepage_enabled() returns false, the code will not
>> reach create_huge_pmd() at all. If it returns true, create_huge_pmd()
>> actually will return VM_FAULT_FALLBACK for shmem since shmem doesn't
>> have huge_fault (or pmd_fault in earlier versions) method.
>>
>> Then it will get into handle_pte_fault(), finally shmem_fault() is
>> called, which allocates THP by checking some global flag (i.e.
>> VM_NOHUGEPAGE and MMF_DISABLE_THP) and  shmem THP knobs.
> Aha, thanks! What a mess...

Yes, it does look convoluted. I'm wondering we may consider refactor the 
shmem THP fault handling.

>
>> 4.8 (the first version has shmem THP merged) behaves exactly in the same
>> way. So, I suspect this may be intended behavior.
> Still looks like an oversight to me. And it's inconsistent... it might
> fault huge shmem pages when THPs are globally disabled, but khugepaged
> is still not running. I think it should just check the global THP flags
> as well...

It does looks inconsistent, particularly for the khugepaged part.


