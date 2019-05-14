Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36C75C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 16:25:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEE6F2085A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 16:25:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="soBldPES"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEE6F2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 680B76B0005; Tue, 14 May 2019 12:25:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 631696B0006; Tue, 14 May 2019 12:25:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FBA16B000A; Tue, 14 May 2019 12:25:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7AA6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 12:25:11 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id e126so12778273ioa.8
        for <linux-mm@kvack.org>; Tue, 14 May 2019 09:25:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=JCV/HzgrZlCHVmf/0Cx/bB8oSFM3Re9RwssBEXXRqZc=;
        b=TzsIdchkVnZ9T70qARXlQXx7UHAD31SO+lSKI0STgCYYTIlLhTYKgrbOgF0vuzk1Yj
         AoEuLkw5SENij2fqqTRS/fFqISqZa+TXkJIRJwR+tJJuF6OVmfUD1+MUS/ohBt2OGl4i
         foEERvcVhhovklQynlTOZkGT3nbdzFhOH3FvGYfN3Nq04+EDtiQb/rEW660DQHBSeMqv
         7JU2zgxZ2G7av40TefO8qH07F9OTLJ8UpevmE1Hq66ZiL2VLNFo74PZejhiYKVOeOIhC
         pT0GTD83GA751ls0ichZ/T5/shTGghfX+uKdaL131FIGpDn9mKB6Q6ehcufDreOMOzBn
         2/bQ==
X-Gm-Message-State: APjAAAVano0pSwsyLJxloWKuHCemdXLNVcwmFKK1rnwJcmC45DFm+BFf
	7nVyPWZsZFx9KHEtbaUTy7IKbs14CFaQGW9Ca3JyTuv2ze2bCC9xCwzXOwTMeZp+scTVi5V1apl
	v2kUrZysf/K5OJsvdCYSvR6lF/xDqL6MXBhoTqQlHiffsErrRrnZOUUTcpNzJ8q50JQ==
X-Received: by 2002:a24:5512:: with SMTP id e18mr4171181itb.112.1557851110827;
        Tue, 14 May 2019 09:25:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7bGX9ZRQ/mS/jOfHl68hz4NWcLXPuJbo/cVdmKdsK2MvAznWDHbPn8TcN1mN/hNYRcwQ3
X-Received: by 2002:a24:5512:: with SMTP id e18mr4171104itb.112.1557851109687;
        Tue, 14 May 2019 09:25:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557851109; cv=none;
        d=google.com; s=arc-20160816;
        b=faTQiPT9a3W7VADQAncuIHqa4W3uGEyWeH9C+FlJ+T7okqG6M2larVtBriL6Wu/Eji
         waB78ZpMoSMOal6M0GsIARlFKRYk9VqkGJXYpsYHmLHNUZkBeL8ooJ9N0GKbSBtQeijj
         H+ktXd7pdKcY1ehxWFvt9BRxKk347muNwkYobMEqYg7BfhDYpMv3+cxcLSSVKhan7hPf
         2a2dIdmQNhVGkE57h7s4voOX2RRmE/2zTgfLTnGs1gphRneK64gCkkzvSr2BOJPeXJoy
         lnLDTf8Q428rl1R3l/8MksRkjwhUVyLh3IqAmCoIHaqgLhFl96kS+/Nqo3XXkMw25Rfg
         hFlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=JCV/HzgrZlCHVmf/0Cx/bB8oSFM3Re9RwssBEXXRqZc=;
        b=qSNLFKVLAomWnpmaOA+wVUrgswnBBxbfY1WKp4KIrxkoMJiFEiE9IblnqoR07AqY1J
         I40EJvhFzShp4l4tOTQ1e6XRtCDYMqXiK6w8k+Ezv9SDAAZLC7Wr9gE+WSMXmfC4/Yr0
         85ovSesIG4HMxvxEtrgb3+2CSPlcd3iD9+SijWe39S0w2AIF9cRbpgFucUJvUoWKMEju
         dxZ3EvYkmuhHpTC6DYOzhO546hnt9FSTSaTFwjtOFtKppUbcQ1AlxU0Vdk40HavLozX3
         PlkVzYE049bYFjgSlYe7XRLSD1oe/hpuplBatbBfOM2vY6jFUrWRIH8rWI5H0TnXCbIK
         i8mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=soBldPES;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h7si9452050ioj.5.2019.05.14.09.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 09:25:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=soBldPES;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EGELEW097729;
	Tue, 14 May 2019 16:24:56 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=JCV/HzgrZlCHVmf/0Cx/bB8oSFM3Re9RwssBEXXRqZc=;
 b=soBldPESLpJww1uCH2gLsnSanFFjMUy/AlTjGJ9OkUBv6qJNOBHy1+fFhi9hJQ+737dg
 tJf1MiPoFlWIpy0YVR8DtCOFPhvOWKt9vq3A+pMsKfAp2/IrfcFJyalxALp0aBrMK8zw
 gK0Up3guxWE/N1DTXoY/dX4xyFMkqwJvXCLgZXEWJRyRtyyjWHFMWUJNb41TIEqsxH/0
 f4TnwL3Mz8fw8pQtfsmFPuZfY8FzdgkuyR/aIyrQagKrFxi/TddxfozWkPVdMnsH9b3W
 9/at8r4tPmHvEJJCoB+XTRDj7rUeAVaRHDwKsE2Zo7YSQPS6SLOJrGD1faWqvlfcZkQP YQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2sdkwdqhdg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 16:24:56 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EGNc90005562;
	Tue, 14 May 2019 16:24:55 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2sdnqjnh3e-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 16:24:55 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4EGOqDm006383;
	Tue, 14 May 2019 16:24:52 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 09:24:52 -0700
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table
 entries for percpu buffer
To: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>,
        Paolo Bonzini
 <pbonzini@redhat.com>,
        Radim Krcmar <rkrcmar@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
        Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        jan.setjeeilers@oracle.com, Liran Alon <liran.alon@oracle.com>,
        Jonathan Adams <jwadams@google.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
 <20190514070941.GE2589@hirez.programming.kicks-ass.net>
 <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com>
 <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net>
 <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com>
 <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <e5fedad9-4607-0aa4-297e-398c0e34ae2b@oracle.com>
Date: Tue, 14 May 2019 18:24:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140114
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140114
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/14/19 5:23 PM, Andy Lutomirski wrote:
> On Tue, May 14, 2019 at 2:42 AM Alexandre Chartre
> <alexandre.chartre@oracle.com> wrote:
>>
>>
>> On 5/14/19 10:34 AM, Andy Lutomirski wrote:
>>>
>>>
>>>> On May 14, 2019, at 1:25 AM, Alexandre Chartre <alexandre.chartre@oracle.com> wrote:
>>>>
>>>>
>>>>> On 5/14/19 9:09 AM, Peter Zijlstra wrote:
>>>>>> On Mon, May 13, 2019 at 11:18:41AM -0700, Andy Lutomirski wrote:
>>>>>> On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
>>>>>> <alexandre.chartre@oracle.com> wrote:
>>>>>>>
>>>>>>> pcpu_base_addr is already mapped to the KVM address space, but this
>>>>>>> represents the first percpu chunk. To access a per-cpu buffer not
>>>>>>> allocated in the first chunk, add a function which maps all cpu
>>>>>>> buffers corresponding to that per-cpu buffer.
>>>>>>>
>>>>>>> Also add function to clear page table entries for a percpu buffer.
>>>>>>>
>>>>>>
>>>>>> This needs some kind of clarification so that readers can tell whether
>>>>>> you're trying to map all percpu memory or just map a specific
>>>>>> variable.  In either case, you're making a dubious assumption that
>>>>>> percpu memory contains no secrets.
>>>>> I'm thinking the per-cpu random pool is a secrit. IOW, it demonstrably
>>>>> does contain secrits, invalidating that premise.
>>>>
>>>> The current code unconditionally maps the entire first percpu chunk
>>>> (pcpu_base_addr). So it assumes it doesn't contain any secret. That is
>>>> mainly a simplification for the POC because a lot of core information
>>>> that we need, for example just to switch mm, are stored there (like
>>>> cpu_tlbstate, current_task...).
>>>
>>> I don’t think you should need any of this.
>>>
>>
>> At the moment, the current code does need it. Otherwise it can't switch from
>> kvm mm to kernel mm: switch_mm_irqs_off() will fault accessing "cpu_tlbstate",
>> and then the page fault handler will fail accessing "current" before calling
>> the kvm page fault handler. So it will double fault or loop on page faults.
>> There are many different places where percpu variables are used, and I have
>> experienced many double fault/page fault loop because of that.
> 
> Now you're experiencing what working on the early PTI code was like :)
> 
> This is why I think you shouldn't touch current in any of this.
> 
>>
>>>>
>>>> If the entire first percpu chunk effectively has secret then we will
>>>> need to individually map only buffers we need. The kvm_copy_percpu_mapping()
>>>> function is added to copy mapping for a specified percpu buffer, so
>>>> this used to map percpu buffers which are not in the first percpu chunk.
>>>>
>>>> Also note that mapping is constrained by PTE (4K), so mapped buffers
>>>> (percpu or not) which do not fill a whole set of pages can leak adjacent
>>>> data store on the same pages.
>>>>
>>>>
>>>
>>> I would take a different approach: figure out what you need and put it in its
>>> own dedicated area, kind of like cpu_entry_area.
>>
>> That's certainly something we can do, like Julian proposed with "Process-local
>> memory allocations": https://lkml.org/lkml/2018/11/22/1240
>>
>> That's fine for buffers allocated from KVM, however, we will still need some
>> core kernel mappings so the thread can run and interrupts can be handled.
>>
>>> One nasty issue you’ll have is vmalloc: the kernel stack is in the
>>> vmap range, and, if you allow access to vmap memory at all, you’ll
>>> need some way to ensure that *unmap* gets propagated. I suspect the
>>> right choice is to see if you can avoid using the kernel stack at all
>>> in isolated mode.  Maybe you could run on the IRQ stack instead.
>>
>> I am currently just copying the task stack mapping into the KVM page table
>> (patch 23) when a vcpu is created:
>>
>>          err = kvm_copy_ptes(tsk->stack, THREAD_SIZE);
>>
>> And this seems to work. I am clearing the mapping when the VM vcpu is freed,
>> so I am making the assumption that the same task is used to create and free
>> a vcpu.
>>
> 
> vCPUs are bound to an mm but not a specific task, right?  So I think
> this is wrong in both directions.
> 

I know, that was yet another shortcut for the POC, I assume there's a 1:1
mapping between a vCPU and task, but I think that's fair with qemu.


> Suppose a vCPU is created, then the task exits, the stack mapping gets
> freed (the core code tries to avoid this, but it does happen), and a
> new stack gets allocated at the same VA with different physical pages.
> Now you're toast :)  On the flip side, wouldn't you crash if a vCPU is
> created and then run on a different thread?

Yes, that's why I have a safety net: before entering KVM isolation I always
check that the current task is mapped in the KVM address space, if not it
gets mapped.

> How important is the ability to enable IRQs while running with the KVM
> page tables?
> 

I can't say, I would need to check but we probably need IRQs at least for
some timers. Sounds like you would really prefer IRQs to be disabled.


alex.

