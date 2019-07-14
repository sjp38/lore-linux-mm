Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7F31C73C66
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 18:17:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91E0120644
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 18:17:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="WSMIOs2r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91E0120644
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26FB86B0006; Sun, 14 Jul 2019 14:17:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 221786B0007; Sun, 14 Jul 2019 14:17:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C2896B0008; Sun, 14 Jul 2019 14:17:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E10656B0006
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 14:17:42 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t124so11852913qkh.3
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 11:17:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:precedence;
        bh=yU8Er0dM4xN+kO/PufN1rVisDCrwrEjJU9iRQpgHWz0=;
        b=rXL7lpcf6IWcUACQU8/77ZCgjZf3k5p/ROt7SDXbW2/9GVEOobRw2cDmSlHIYh9ELk
         5pcK8QZ9Ftosb4O/ELU2syOLR6Akman/zKP1EEzYQFXX+CDjp5sqEORMBZgF/RetahYK
         rTAsgccWjeOGOUYPaP6qelxzj3EdnLvOflpw9hMLW/4uJE3dSVTV4EG42sUL+6VOC1si
         X15pGFl3wH0r+RghfH8On6XRDwZSMCichOMifpiJD3nTX1UE5XSJCl9nAjYaU1ypCZQ2
         8Vsq6OzmuOSzcmd3a4lXKKZudE2oaWWb40hu4jQd0PoFQ0hHrHzg/OeFWTICz3LFF8C5
         ZASA==
X-Gm-Message-State: APjAAAUYlMwDAdFfthOig0W30qE067YyS+BLaY1pJjzuUpYDGGurerJc
	1RTflbrad92aq51VbDozF4pJsh1DXXXtajF+TxVlj0AMigXJ+5mdCVJHmMB7rYQqFzhz3yxHefS
	1L1/4m1f5X5f82XDwgqcFZKZyV/7ZxOeeYrnPmm1WXQkPCmnl3egg4mFAJ1+S9aoRAw==
X-Received: by 2002:ac8:1106:: with SMTP id c6mr13731659qtj.332.1563128262601;
        Sun, 14 Jul 2019 11:17:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzKBSbmrdJBchcRyqo8TF1k5W/nexSZRJW8zwtfAuFcmOYxr1UFT1FSj3MwZ4r04ULxrop
X-Received: by 2002:ac8:1106:: with SMTP id c6mr13731621qtj.332.1563128261929;
        Sun, 14 Jul 2019 11:17:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563128261; cv=none;
        d=google.com; s=arc-20160816;
        b=cKc0C8QDIzBB46GfeKkAVE2rWN8BtRFimsFAKKhHAJ9J1NG+2M1Frh/c30WstLEr9P
         zXnc4k/dOUkvr6ytjWzScMtWDjyz9wd50EvUSpNYLemVpv7hTAx9mBilgXa4sqNw20LB
         8hnxQsotRp+z6qUhTJ+Sr1TKD4zNcrk2bqjTkNzgWzrMR6i2LefoI6LBNkeijAyGNLH6
         vpTUB4VXsuJtHNJWsxZp3ZOZcomOUWfcklSfR2K/fTSD8RWbQGNBKcFh2iJUxkJbE8o7
         tMVef9Rtu4gEEP235KRG+4mwSnfygWVZHDT65OMz4S+dpXpB0OoUOCCzHkOsvd311FuQ
         PEnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=precedence:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to
         :subject:dkim-signature;
        bh=yU8Er0dM4xN+kO/PufN1rVisDCrwrEjJU9iRQpgHWz0=;
        b=tI0nkSPSmdg72uo5MXJijDqzDAAiqHMVt/orn/5MK6NBrFjE/Hko2ZG3OXqEGU1pPh
         FU7byGujRQnOyqdsgzGqKwdudLvS4yJSZNkQW9/HxJSAZCIYtShtk5IoaF5Rpd/+SVTs
         5XtEzlxapOLjsjIn0/6oSKgt05EJSfyRRw7oHSzXHwQW8RPL7NoGtJYqj1MCUO82xQMo
         RTAj2kxBTN/a82TGV9KEKJgvHFV8FFMqF2RjtPWXGJynSw0Cmq+3KGJc/rFPTbFgLD2N
         /55G4bwtVoQQDfd5sV7QUp3e046g4ppS2u0mfrE2eGM707kWpiDg5577KQ2EWzF9dCdm
         WhxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.com header.s=amazon201209 header.b=WSMIOs2r;
       spf=pass (google.com: domain of prvs=09157809a=graf@amazon.com designates 52.95.49.90 as permitted sender) smtp.mailfrom="prvs=09157809a=graf@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.com
Received: from smtp-fw-6002.amazon.com (smtp-fw-6002.amazon.com. [52.95.49.90])
        by mx.google.com with ESMTPS id w24si10423667qtk.394.2019.07.14.11.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 11:17:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=09157809a=graf@amazon.com designates 52.95.49.90 as permitted sender) client-ip=52.95.49.90;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.com header.s=amazon201209 header.b=WSMIOs2r;
       spf=pass (google.com: domain of prvs=09157809a=graf@amazon.com designates 52.95.49.90 as permitted sender) smtp.mailfrom="prvs=09157809a=graf@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1563128261; x=1594664261;
  h=subject:to:cc:references:from:message-id:date:
   mime-version:in-reply-to:content-transfer-encoding;
  bh=yU8Er0dM4xN+kO/PufN1rVisDCrwrEjJU9iRQpgHWz0=;
  b=WSMIOs2rvTU4hHyWlfV3AOhx/1em3Ciux8Y4UyGeLvVqJd13vXZ8B82S
   6akzHA5HykuIeiTfZxJBxO5m1nJ+ikGCSY5FLoQ8ncLHekMWF1WM6cmP0
   n5Lrr8vUjQvSw0csNve+l4zyFPlF/RJfZ0URXseuSee9I4tTvr2aehAH0
   0=;
X-IronPort-AV: E=Sophos;i="5.62,491,1554768000"; 
   d="scan'208";a="410612451"
Received: from iad6-co-svc-p1-lb1-vlan3.amazon.com (HELO email-inbound-relay-2c-397e131e.us-west-2.amazon.com) ([10.124.125.6])
  by smtp-border-fw-out-6002.iad6.amazon.com with ESMTP; 14 Jul 2019 18:17:39 +0000
Received: from EX13MTAUWC001.ant.amazon.com (pdx4-ws-svc-p6-lb7-vlan3.pdx.amazon.com [10.170.41.166])
	by email-inbound-relay-2c-397e131e.us-west-2.amazon.com (Postfix) with ESMTPS id 08C93A243C;
	Sun, 14 Jul 2019 18:17:37 +0000 (UTC)
Received: from EX13D20UWC001.ant.amazon.com (10.43.162.244) by
 EX13MTAUWC001.ant.amazon.com (10.43.162.135) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Sun, 14 Jul 2019 18:17:37 +0000
Received: from 38f9d3867b82.ant.amazon.com (10.43.160.177) by
 EX13D20UWC001.ant.amazon.com (10.43.162.244) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Sun, 14 Jul 2019 18:17:32 +0000
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Andy Lutomirski <luto@kernel.org>, Alexandre Chartre
	<alexandre.chartre@oracle.com>
CC: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner
	<tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini
	<pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, Ingo Molnar
	<mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin"
	<hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, kvm list
	<kvm@vger.kernel.org>, X86 ML <x86@kernel.org>, Linux-MM
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Konrad Rzeszutek
 Wilk" <konrad.wilk@oracle.com>, <jan.setjeeilers@oracle.com>, Liran Alon
	<liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>, Mike Rapoport
	<rppt@linux.vnet.ibm.com>, Paul Turner <pjt@google.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net>
 <a03db3a5-b033-a469-cc6c-c8c86fb25710@oracle.com>
 <CALCETrVcM-SpEqLMJSOdyGuN0gjr+97+cpu2KYneuTv1fJDoog@mail.gmail.com>
From: Alexander Graf <graf@amazon.com>
Message-ID: <849b74ba-2ce4-04e9-557c-6d8c8ec29e16@amazon.com>
Date: Sun, 14 Jul 2019 20:17:30 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CALCETrVcM-SpEqLMJSOdyGuN0gjr+97+cpu2KYneuTv1fJDoog@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.43.160.177]
X-ClientProxiedBy: EX13D02UWC003.ant.amazon.com (10.43.162.199) To
 EX13D20UWC001.ant.amazon.com (10.43.162.244)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 12.07.19 16:36, Andy Lutomirski wrote:
> On Fri, Jul 12, 2019 at 6:45 AM Alexandre Chartre
> <alexandre.chartre@oracle.com> wrote:
>>
>>
>> On 7/12/19 2:50 PM, Peter Zijlstra wrote:
>>> On Fri, Jul 12, 2019 at 01:56:44PM +0200, Alexandre Chartre wrote:
>>>
>>>> I think that's precisely what makes ASI and PTI different and independent.
>>>> PTI is just about switching between userland and kernel page-tables, while
>>>> ASI is about switching page-table inside the kernel. You can have ASI without
>>>> having PTI. You can also use ASI for kernel threads so for code that won't
>>>> be triggered from userland and so which won't involve PTI.
>>>
>>> PTI is not mapping         kernel space to avoid             speculation crap (meltdown).
>>> ASI is not mapping part of kernel space to avoid (different) speculation crap (MDS).
>>>
>>> See how very similar they are?
>>>
>>>
>>> Furthermore, to recover SMT for userspace (under MDS) we not only need
>>> core-scheduling but core-scheduling per address space. And ASI was
>>> specifically designed to help mitigate the trainwreck just described.
>>>
>>> By explicitly exposing (hopefully harmless) part of the kernel to MDS,
>>> we reduce the part that needs core-scheduling and thus reduce the rate
>>> the SMT siblngs need to sync up/schedule.
>>>
>>> But looking at it that way, it makes no sense to retain 3 address
>>> spaces, namely:
>>>
>>>     user / kernel exposed / kernel private.
>>>
>>> Specifically, it makes no sense to expose part of the kernel through MDS
>>> but not through Meltdow. Therefore we can merge the user and kernel
>>> exposed address spaces.
>>
>> The goal of ASI is to provide a reduced address space which exclude sensitive
>> data. A user process (for example a database daemon, a web server, or a vmm
>> like qemu) will likely have sensitive data mapped in its user address space.
>> Such data shouldn't be mapped with ASI because it can potentially leak to the
>> sibling hyperthread. For example, if an hyperthread is running a VM then the
>> VM could potentially access user sensitive data if they are mapped on the
>> sibling hyperthread with ASI.
> 
> So I've proposed the following slightly hackish thing:
> 
> Add a mechanism (call it /dev/xpfo).  When you open /dev/xpfo and
> fallocate it to some size, you allocate that amount of memory and kick
> it out of the kernel direct map.  (And pay the IPI cost unless there
> were already cached non-direct-mapped pages ready.)  Then you map
> *that* into your VMs.  Now, for a dedicated VM host, you map *all* the
> VM private memory from /dev/xpfo.  Pretend it's SEV if you want to
> determine which pages can be set up like this.
> 
> Does this get enough of the benefit at a negligible fraction of the
> code complexity cost?  (This plus core scheduling, anyway.)

The problem with that approach is that you lose the ability to run 
legacy workloads that do not support an SEV like model of "guest owned" 
and "host visible" pages, but instead assume you can DMA anywhere.

Without that, your host will have visibility into guest pages via user 
space (QEMU) pages which again are mapped in the kernel direct map, so 
can be exposed via a spectre gadget into a malicious guest.

Also, please keep in mind that even register state of other VMs may be a 
secret that we do not want to leak into other guests.


Alex

