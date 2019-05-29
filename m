Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B9BC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 23:31:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 133B524371
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 23:31:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="IAaKB5qa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 133B524371
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B67C86B0272; Wed, 29 May 2019 19:31:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B182C6B0273; Wed, 29 May 2019 19:31:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E1F96B0274; Wed, 29 May 2019 19:31:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC116B0272
	for <linux-mm@kvack.org>; Wed, 29 May 2019 19:31:33 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id d143so1623740vkf.10
        for <linux-mm@kvack.org>; Wed, 29 May 2019 16:31:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ZeIntJUzf6RoM7jUUPQSe8jXByDyh+4YkHIeg3GAXsQ=;
        b=l5LGbIeyKxUicEPxS+jrDYavWr6J3sqG/PnU8B+kB1RHJcnJXHJCTAr522QHOJf/1O
         FOXiFlJpRw9B6FyCP+Bo56XBBm79ewM3lximB5WzQIy1fDxOlNWKSweVQR0YNX0p7Q3v
         sKJxRH+o6vf2KCU9WVsrSHfPkmTpKv+72boNBRMTe/MONhzZh5neXQTnBTpSIc2GWOMr
         19PwwcvD9nvyVdF6fgONwZrf98BB5HkqJCPjVAwZanPIYUYGtM1IKlzrR/+v+17/1lxm
         JUWPFD4Rmb3D73Ylgx04y37j0xq8dDS2rWgXSu2jdGa+KAVDtlh4W+x0kCAk8qIJYEiO
         gzcQ==
X-Gm-Message-State: APjAAAX07LgHdMkwBEnAMcVL4ircefV+tOsw8MY5RyDpzsn0dF2m9mtw
	vh2mAwsA+pfJYmNljQonS5a6L1CKmN1zanhsqXkPPJhbDkH9kfVoPduhDBcTz9G+d9EgeymQZuN
	GrhrKvDzW8bKcf0Blh6dY6+U8AL7f8/vpVGFtc5qDrvK46X5AuhAmnEjZJE7AydiU6g==
X-Received: by 2002:a67:db06:: with SMTP id z6mr257836vsj.69.1559172693098;
        Wed, 29 May 2019 16:31:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAa2aJBxGY/hUkAPflxZd7VW2HbmM1dvG0Ddw0uGeOgCgW8QVY3fTkkly/QCHT2k8+Zqvh
X-Received: by 2002:a67:db06:: with SMTP id z6mr257800vsj.69.1559172692251;
        Wed, 29 May 2019 16:31:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559172692; cv=none;
        d=google.com; s=arc-20160816;
        b=UTTqCazJmL8GlxaoURIPG/eNzQgMsMSfpMcmwfAb0I3xMZptXbB/5pz/tBrO6LOgox
         N+rlspCXsS8uH/TjmsNmjB86sRBAhyffHgi8wd7G/ahB4LlVkceeHr1FyWl+VoMnWNkn
         fxbO3JJjAJgK436kRP82Jl0vHUHCy7JSHxjS9kqUVAYFHBE3exs8GoVGe/UHIeSZmC5p
         nAk+Dw9Zs3A099g9ktiUo2viQGPman23YThFwL0KbuVkUNy06+04qXgbu/Jf/uoXWqqq
         tmDKfCgbcnTuJpE0Qs36I3JDQAx/iCiaRA4Wd3kOnepowu5jHEAhsJTZTVq4x1ZTd1sx
         8YgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=ZeIntJUzf6RoM7jUUPQSe8jXByDyh+4YkHIeg3GAXsQ=;
        b=Zu2jU6N20I7YBaIBws32/mTJDGrYV1BbW3KMzzAJXZuRu0z5dkWKG8jVMl0WZZESqf
         DtOQ1S5rQdCinoc8UqKu/gLuxl+szssN2Q+OLmZSzeYFkipJRKQ9kfjIZyEqQZ6Lz0+u
         O9cX9s9+kft0U//tQWaNdHg/aF5uIHXI/pXw5LgRGIRXywTaCIVXfAJ7aXfAuPwlbyL9
         oktC82NmgpvEtmmGLUKNtJLgCFXCQkMJNvYYFN3zRtwAp5/MTOODvN8ik0lNM1PCqUel
         FHmx5fDXBUmlqK15lCNklnRJikGejqWqTnyixYUnbMpQT/c64+KGt4Dfl6hvWOICFl1Y
         wNIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IAaKB5qa;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u21si378743uan.235.2019.05.29.16.31.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 16:31:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IAaKB5qa;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4TNSRIp080130;
	Wed, 29 May 2019 23:31:18 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=ZeIntJUzf6RoM7jUUPQSe8jXByDyh+4YkHIeg3GAXsQ=;
 b=IAaKB5qaUOqWsmMianN1GrQXpj9HG3cU0oz4ab6U1xB/tXO6+QR4XtP3ZMrOtiUMkOoV
 4E5Psrzd26xnaBWY4KxDwMtLYLrwtpzQmCqBocQFFxj26Y0zHm7WphZ5Vy7kvikFllbw
 K8oaFQODFc4ZYWzCBXppsBGoVQwYQdQg2GW8EUlLymnnHNwmkbT5lBnfY5IXgtKbeuvb
 fRuY8+2I/DomXosaX6EOYlvf6BUj2JvvkWAYxRpc9VIrwm5f0jD27GRQgV/1zhr4IIot
 MQ7LFuYSpR3RENpPYFVJ87Ior67/wGNxK49Fdt541GiLuVThQPe3y929dj9OI1biQ4aK dA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2spw4tn09w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 23:31:18 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4TNTqPs081158;
	Wed, 29 May 2019 23:31:17 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2srbdxp6qf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 23:31:17 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4TNV3Z4032602;
	Wed, 29 May 2019 23:31:04 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 29 May 2019 16:31:03 -0700
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB
 hugepage
To: Wanpeng Li <kernellwp@gmail.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>,
        Andrew Morton <akpm@linux-foundation.org>,
        Punit Agrawal <punit.agrawal@arm.com>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Michal Hocko <mhocko@kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Anshuman Khandual <khandual@linux.vnet.ibm.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        kvm <kvm@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>,
        Xiao Guangrong <xiaoguangrong@tencent.com>, lidongchen@tencent.com,
        yongkaiwu@tencent.com
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
 <1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87inbbjx2w.fsf@e105922-lin.cambridge.arm.com>
 <20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp>
 <87fu6bfytm.fsf@e105922-lin.cambridge.arm.com>
 <20180208121749.0ac09af2b5a143106f339f55@linux-foundation.org>
 <87wozhvc49.fsf@concordia.ellerman.id.au>
 <e673f38a-9e5f-21f6-421b-b3cb4ff02e91@oracle.com>
 <CANRm+CxAgWVv5aVzQ0wdP_A7QQgqfy7nN_SxyaactG7Mnqfr2A@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <f79d828c-b0b4-8a20-c316-a13430cfb13c@oracle.com>
Date: Wed, 29 May 2019 16:31:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CANRm+CxAgWVv5aVzQ0wdP_A7QQgqfy7nN_SxyaactG7Mnqfr2A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905290145
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905290146
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/28/19 2:49 AM, Wanpeng Li wrote:
> Cc Paolo,
> Hi all,
> On Wed, 14 Feb 2018 at 06:34, Mike Kravetz <mike.kravetz@oracle.com> wrote:
>>
>> On 02/12/2018 06:48 PM, Michael Ellerman wrote:
>>> Andrew Morton <akpm@linux-foundation.org> writes:
>>>
>>>> On Thu, 08 Feb 2018 12:30:45 +0000 Punit Agrawal <punit.agrawal@arm.com> wrote:
>>>>
>>>>>>
>>>>>> So I don't think that the above test result means that errors are properly
>>>>>> handled, and the proposed patch should help for arm64.
>>>>>
>>>>> Although, the deviation of pud_huge() avoids a kernel crash the code
>>>>> would be easier to maintain and reason about if arm64 helpers are
>>>>> consistent with expectations by core code.
>>>>>
>>>>> I'll look to update the arm64 helpers once this patch gets merged. But
>>>>> it would be helpful if there was a clear expression of semantics for
>>>>> pud_huge() for various cases. Is there any version that can be used as
>>>>> reference?
>>>>
>>>> Is that an ack or tested-by?
>>>>
>>>> Mike keeps plaintively asking the powerpc developers to take a look,
>>>> but they remain steadfastly in hiding.
>>>
>>> Cc'ing linuxppc-dev is always a good idea :)
>>>
>>
>> Thanks Michael,
>>
>> I was mostly concerned about use cases for soft/hard offline of huge pages
>> larger than PMD_SIZE on powerpc.  I know that powerpc supports PGD_SIZE
>> huge pages, and soft/hard offline support was specifically added for this.
>> See, 94310cbcaa3c "mm/madvise: enable (soft|hard) offline of HugeTLB pages
>> at PGD level"
>>
>> This patch will disable that functionality.  So, at a minimum this is a
>> 'heads up'.  If there are actual use cases that depend on this, then more
>> work/discussions will need to happen.  From the e-mail thread on PGD_SIZE
>> support, I can not tell if there is a real use case or this is just a
>> 'nice to have'.
> 
> 1GB hugetlbfs pages are used by DPDK and VMs in cloud deployment, we
> encounter gup_pud_range() panic several times in product environment.
> Is there any plan to reenable and fix arch codes?

I too am aware of slightly more interest in 1G huge pages.  Suspect that as
Intel MMU capacity increases to handle more TLB entries there will be more
and more interest.

Personally, I am not looking at this issue.  Perhaps Naoya will comment as
he know most about this code.

> In addition, https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kvm/mmu.c#n3213
> The memory in guest can be 1GB/2MB/4K, though the host-backed memory
> are 1GB hugetlbfs pages, after above PUD panic is fixed,
> try_to_unmap() which is called in MCA recovery path will mark the PUD
> hwpoison entry. The guest will vmexit and retry endlessly when
> accessing any memory in the guest which is backed by this 1GB poisoned
> hugetlbfs page. We have a plan to split this 1GB hugetblfs page by 2MB
> hugetlbfs pages/4KB pages, maybe file remap to a virtual address range
> which is 2MB/4KB page granularity, also split the KVM MMU 1GB SPTE
> into 2MB/4KB and mark the offensive SPTE w/ a hwpoison flag, a sigbus
> will be delivered to VM at page fault next time for the offensive
> SPTE. Is this proposal acceptable?

I am not sure of the error handling design, but this does sound reasonable.
That block of code which potentially dissolves a huge page on memory error
is hard to understand and I'm not sure if that is even the 'normal'
functionality.  Certainly, we would hate to waste/poison an entire 1G page
for an error on a small subsection.

-- 
Mike Kravetz

