Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A8A0C742B3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:02:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0D652083B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:02:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5ejc6Na9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0D652083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AC028E013E; Fri, 12 Jul 2019 08:02:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 281AE8E00DB; Fri, 12 Jul 2019 08:02:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FC3E8E013E; Fri, 12 Jul 2019 08:02:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBE908E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:02:18 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id h26so4449111otr.21
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:02:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=UvA9Jh+08UHDvAGbwH3rBrV64pox2kQExiFizxg0YeE=;
        b=lfzIosMcGyDKuR6hAkj6K99u2j4MauA0UguElEvl58tjnoMNMsFqlVlCTJquILMMOP
         3RAqheV01+Wg2gdf8su5EbeISmwIKn46blIwmyL1Zr0q3O8rruzWbWaLj2ORR7KcVyOP
         Q/kZQJqZaapskVYq6ccxdq1Tmat13W+k87RJq8iETwg+niUv5WeWWNNp/ERbQR1QGc9k
         RTb5c4/vGSxBQA/KqE77ATafevoaL0L09n6JYqmnGYqwKFJEBcKbcZATkXBBzvAePGOH
         f0W3Q9Oe5oPSOzlHhiYyCmLsYz3FWDVc2++zqjkCPeH4sHL5tQMzesZece9DG4BHwfEa
         GPNA==
X-Gm-Message-State: APjAAAUbJgZLynUf6jYH0uMueLR8SyQBneqtw3X8EdE1hvMSbai4iR9V
	GMDCC1s1Vw/MnA+ySuOgbVU9DPLhtHNtOJV2yvaXtLS1u1mFYJLycV3quUcU4AdvcxJicCZcUfc
	ll/VztNW2c1YQEt+7JGLGYRDfl5szCduG2bplkdQth0fyVZr334xJp+HW2wjvpsr0fg==
X-Received: by 2002:a9d:3f42:: with SMTP id m60mr7997415otc.142.1562932938112;
        Fri, 12 Jul 2019 05:02:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKmf8rHDnZX5X8qxCqg/3lekGQ9e0BLplugOmwLAf42emy8YRYgPE3bDP2MVe8VcCt5jL8
X-Received: by 2002:a9d:3f42:: with SMTP id m60mr7997227otc.142.1562932935972;
        Fri, 12 Jul 2019 05:02:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562932935; cv=none;
        d=google.com; s=arc-20160816;
        b=ZOXo8XgQECQOYmlp/ha40XFbo2T+C6V/7CG7qY1L+8k4wa9Qru4X8M6TBppzsfQmD5
         xAwTB+to4vjhOizLj1mx/ylTJfDJ7dNU8nRaA3SQgQuPRPc7coDDZZ0mKhW9cMRCdpcJ
         YUfk92x6AdFaJ2BfZ1m5Sv0nMh8/vpMKLGej7OPgm/apC0Cc0uP3LzcIAamZn9bu9Ngl
         ZRqBh5t1impystyErPypIYSLLrGUHRvYKfn3l1UsegK7z9A+8LXI/eXBzryOvrSLGg4U
         7GhQlueIksZNgJXPqJMgDeaNoQzDz9EensL1nSLrShJMaS832yZSPz1jCNQgJLH3gJZi
         B/nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=UvA9Jh+08UHDvAGbwH3rBrV64pox2kQExiFizxg0YeE=;
        b=O6C1SaCKUmkAZvc9LdQv5ojqEK1Gp2HeiXs19eStyB0frmE7Z37qerK/raQziEoAh2
         7uS7/H5E+nzsbyuHH+bnEaW1W7WfaDheZRueaPg+ZdXw0cil1Xvp+7wWTUi9VhQmlJcA
         inWwNVcaShEQCSTojtjdxdz0nQmKMCUVrrXrWCYHxdiYaHpDvt2oZu9R0gm4HUFGtIUP
         erhPF0HS53wFVqJnBL3XPbgK2mcSoxtCuDGDJrEOjJMbT3EokuwCFYfuBe9S5A1vq2vq
         1SJDJYLpg2rNliUC8g2szLRYlEOPDXAl2CHa2wOmLBXwlA5OO78yCgdgoqNzKaNa8u3v
         Ld+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5ejc6Na9;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id y188si5549823oiy.192.2019.07.12.05.02.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 05:02:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5ejc6Na9;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CBwsI5088850;
	Fri, 12 Jul 2019 12:01:55 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=UvA9Jh+08UHDvAGbwH3rBrV64pox2kQExiFizxg0YeE=;
 b=5ejc6Na9HF23eUHz+BoYzKJNXXd5vAuVzCPuho38k/IyFL2csYS3SnWEb0UPapmo3HIU
 FOyNU6a1xSXya3VSdARvmmJgK1gVPPhnhBeYTTY1XqSVE5wPiZz7Vxi3BILLWQfRD/uk
 pLnasU/FZ9+nUE9wrA2dDC9QvY/wHPA0f16WZM4KL+KUBsfjC8k4Tj0708t/dquhPxOj
 okn7O5zqJaxn2XSMGdjKjtmnVvSosskbXQlfvyI1JTpXGnfmZrmDSca/+jGntCvFNtOg
 D/fz27Rhl3WQqSev+OZcy4Ux7WTKtZkORZlyxZRANEuwnmxRdbZEpYG7GlnbyHSFAURi Hg== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2tjkkq56p0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 12:01:54 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CBvj2w033926;
	Fri, 12 Jul 2019 12:01:54 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2tn1j23x9m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 12:01:53 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6CC1mo3030245;
	Fri, 12 Jul 2019 12:01:48 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 04:56:48 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de,
        hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
        peterz@infradead.org, kvm@vger.kernel.org, x86@kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
        liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
        rppt@linux.vnet.ibm.com
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
Date: Fri, 12 Jul 2019 13:56:44 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120131
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120131
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/12/19 12:44 PM, Thomas Gleixner wrote:
> On Thu, 11 Jul 2019, Dave Hansen wrote:
> 
>> On 7/11/19 7:25 AM, Alexandre Chartre wrote:
>>> - Kernel code mapped to the ASI page-table has been reduced to:
>>>    . the entire kernel (I still need to test with only the kernel text)
>>>    . the cpu entry area (because we need the GDT to be mapped)
>>>    . the cpu ASI session (for managing ASI)
>>>    . the current stack
>>>
>>> - Optionally, an ASI can request the following kernel mapping to be added:
>>>    . the stack canary
>>>    . the cpu offsets (this_cpu_off)
>>>    . the current task
>>>    . RCU data (rcu_data)
>>>    . CPU HW events (cpu_hw_events).
>>
>> I don't see the per-cpu areas in here.  But, the ASI macros in
>> entry_64.S (and asi_start_abort()) use per-cpu data.
>>
>> Also, this stuff seems to do naughty stuff (calling C code, touching
>> per-cpu data) before the PTI CR3 writes have been done.  But, I don't
>> see anything excluding PTI and this code from coexisting.
> 
> That ASI thing is just PTI on steroids.
> 
> So why do we need two versions of the same thing? That's absolutely bonkers
> and will just introduce subtle bugs and conflicting decisions all over the
> place.
> 
> The need for ASI is very tightly coupled to the need for PTI and there is
> absolutely no point in keeping them separate.
>
> The only difference vs. interrupts and exceptions is that the PTI logic
> cares whether they enter from user or from kernel space while ASI only
> cares about the kernel entry.

I think that's precisely what makes ASI and PTI different and independent.
PTI is just about switching between userland and kernel page-tables, while
ASI is about switching page-table inside the kernel. You can have ASI without
having PTI. You can also use ASI for kernel threads so for code that won't
be triggered from userland and so which won't involve PTI.

> But most exceptions/interrupts transitions do not require to be handled at
> the entry code level because on VMEXIT the exit reason clearly tells
> whether a switch to the kernel CR3 is necessary or not. So this has to be
> handled at the VMM level already in a very clean and simple way.
> 
> I'm not a virt wizard, but according to code inspection and instrumentation
> even the NMI on the host is actually reinjected manually into the host via
> 'int $2' after the VMEXIT and for MCE it looks like manual handling as
> well. So why do we need to sprinkle that muck all over the entry code?
> 
>  From a semantical perspective VMENTER/VMEXIT are very similar to the return
> to user / enter to user mechanics. Just that the transition happens in the
> VMM code and not at the regular user/kernel transition points.

VMExit returns to the kernel, and ASI is used to run the VMExit handler with
a limited kernel address space instead of using the full kernel address space.
Change in entry code is required to handle any interrupt/exception which
can happen while running code with ASI (like KVM VMExit handler).

Note that KVM is an example of an ASI consumer, but ASI is generic and can be
used to run (mostly) any kernel code if you want to run code with a reduced
kernel address space.

> So why do you want ot treat that differently? There is absolutely zero
> reason to do so. And there is no reason to create a pointlessly different
> version of PTI which introduces yet another variant of a restricted page
> table instead of just reusing and extending what's there already.
> 

As I've tried to explain, to me PTI and ASI are different and independent.
PTI manages switching between userland and kernel page-table, and ASI manages
switching between kernel and a reduced-kernel page-table.


Thanks,

alex.

