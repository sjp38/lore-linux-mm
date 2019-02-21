Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87397C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 20:13:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EE7B2080F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 20:13:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EE7B2080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE87F8E00B0; Thu, 21 Feb 2019 15:13:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C97268E009E; Thu, 21 Feb 2019 15:13:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BACB38E00B0; Thu, 21 Feb 2019 15:13:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9185B8E009E
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:13:13 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id f70so6115960qke.8
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 12:13:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=KXpufiUmOMnEcpsMHjHUv/urVPlGkVI0xttqjOtHiZI=;
        b=T4tNaXNfBcMbC0uEMeC8a7GHdp29//vStRRnYAiX+63HSd0uMDiIDvudTpe93nOmCS
         0QTNZxxXEoJMXFG/urB7conjCbB155GvSwXLDIH392Uq2av+tSK88UrOeSzKw2EzAE+8
         qOltboWSqJYx0Hd4xsyV0IxM1wQw6qcOYUSpd9mT21CFx67xGacB85WRwJI1BtnvCnCT
         XA38b9LfWIlhM9nL4BgGHrNEGxSYqoh3Ch1TsruX9BK9qkvf7ziHb+/qO449b945Au6i
         o2rc4JzpEsF0F+kLXFarj7Rm+sKz7XgjY6+hwYr/fnRmegYnqpzWUVgpWAG3kuRyfd9+
         dwrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZvRtmWaXtP8rVbo8kgBGYIpjInN9LhIvHDcwzcuUTsuFCfpSmd
	AvsYHGgZ262nqBRvbWOhxHpwnAoGb2+N2DrcoJUcNjWu7zZqGmDGWWjcjNdiLEXYOQIq+ljdm8b
	TVPP0sIWAZFtwVQoLEFjyST33WFzLBYDZYeaRA8ttA6k8juxdxV2+7oqDjpLMRvYGMg==
X-Received: by 2002:aed:21cc:: with SMTP id m12mr160492qtc.203.1550779993261;
        Thu, 21 Feb 2019 12:13:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYz0e3QvOGP6jYQ2/wRoCfvTfr7XcVQ+WyEmowPyUVdvQs9FRVZ23Qa4nEFUmtiGVWHXC4W
X-Received: by 2002:aed:21cc:: with SMTP id m12mr160450qtc.203.1550779992438;
        Thu, 21 Feb 2019 12:13:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550779992; cv=none;
        d=google.com; s=arc-20160816;
        b=sLj9h67WB9XLWDXSVS5f78kffDEw7wlvRGVU5FIapD1CNf71e5gF8yXrnNcA3mjB3J
         iW7kATv9wm7b7H62xDzhTcRWPjoAARYgwy+Mb+ferCkknGSC/7lKkB8yqF9AEmZaEDzJ
         Y0OE2pjFz6AyFdwoHPtiXAm6doyE5z1jj5cjCHyMqFx5hl22ENLu9r+VNVTffBok7VtW
         pa07Ui6OjZBt+kmN6L/jYbIhKOlzwrEh5NqJOJl2OfvA1vUQDS9XfB09V8CYdMurgTty
         +TW3AAJg9YON74XdEMqmzpge7ZpWsbUQO524e8+IDgoxXYNtpmE5wKhZwzUHf9kguead
         HK8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=KXpufiUmOMnEcpsMHjHUv/urVPlGkVI0xttqjOtHiZI=;
        b=w3pWgIX4a0oe6Jid8olQZWLT87W0Wi0UU/EMi7Rc8c/Mr6kJ2epJBaecGByR+p6mGn
         xnuLp6tzzn6XCeUsXXv1b3aOikBike+5caGP7gqaKBiX9ZnKwMvhRzwEyyC33e5w12BD
         TVtRgK4lhRSAr7WYwVW4xZxU1z2594PP2pahlSoS1zaoRolDZeergt2gnwGwQCnwSwLf
         dfqJ2/UAbDo3E+pSVXvvXt2NcvD68V9Al/Gj7Nz2O45p9TFXf6uiS9xymTg1xKAZSrMd
         ksycnWI0YNwQuvpLYwubD3xXjeG/mfjFxNkfa5GOxdEh6BI668qZtNXH1FEEl06OZsgz
         vqew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y14si1572468qvc.45.2019.02.21.12.13.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 12:13:12 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9A7FC7EBA7;
	Thu, 21 Feb 2019 20:13:11 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1783719C58;
	Thu, 21 Feb 2019 20:13:10 +0000 (UTC)
Date: Thu, 21 Feb 2019 15:13:09 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Christopher Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org,
	linux-mm@kvack.org
Subject: Re: Memory management facing a 400Gpbs network link
Message-ID: <20190221201309.GA5201@redhat.com>
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com>
 <20190219122609.GN4525@dhcp22.suse.cz>
 <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com>
 <20190219173622.GQ4525@dhcp22.suse.cz>
 <0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@email.amazonses.com>
 <20190219191325.GS4525@dhcp22.suse.cz>
 <0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@email.amazonses.com>
 <20190220083157.GV4525@dhcp22.suse.cz>
 <010001691144c94b-c935fd1d-9c90-40a5-9763-2c05ef0df7f4-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <010001691144c94b-c935fd1d-9c90-40a5-9763-2c05ef0df7f4-000000@email.amazonses.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 21 Feb 2019 20:13:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 06:15:14PM +0000, Christopher Lameter wrote:
> On Wed, 20 Feb 2019, Michal Hocko wrote:
> 
> > > I dont like the existing approaches but I can present them?
> >
> > Please give us at least some rough outline so that we can evaluate a
> > general interest and see how/whether to schedule such a topic.
> 
> Ok. I am fuzzy on this one too. Lets give this another shot:
> 
> In the HPC world we often have to bypass operating system mechanisms for
> full speed. Usually this has been through accellerators in the network
> card, in sharing memory between multiple systems (with NUMA being a
> special case of this) or with devices that provide some specialized memory
> access. There is a whole issue here with pinned memory access (I think
> that is handled in another session at the MM summit)
> 
> The intend was typically to bring the data into the system so that an
> application can act on it. However, with the increasing speeds of the
> interconnect that may even be faster than the internal busses on
> contemporary platforms that may have to change since the processor and the
> system as a whole is no longer able to handle the inbound data stream.
> This is partially due to the I/O bus speeds no longer increasing.
> 
> The solutions to this issue coming from some vendors are falling
> mostly into the following categories:
> 
> A) Provide preprocessing in the NIC.
> 
>    This can compress data, modify it and direct it to certain cores of
>    the system. Preprocessing may allow multiple hosts to use one NIC
>    (Makes sense since a single host may no longer be able to handle the
>    data).
> 
> B) Provide fast memory in the NIC
> 
>    Since the NIC is at capacity limits when it comes to pushing data
>    from the NIC into memory the obvious solution is to not go to main
>    memory but provide faster on NIC memory that can then be accessed
>    from the host as needed. Now the applications creates I/O bottlenecks
>    when accessing their data or they need to implement complicated
>    transfer mechanisms to retrieve and store data onto the NIC memory.
> 
> C) Direct passthrough to other devices
> 
>    The host I/O bus is used or another enhanced bus is provided to reach
>    other system components without the constraints imposed by the OS or
>    hardware. This means for example that a NIC can directly write to an
>    NVME storage device (f.e. NVMEoF). A NIC can directly exchange data with
>    another NIC. In an extreme case a hardware addressable global data fabric
>    exists that is shared between multiple systems and the devices can
>    share memory areas with one another. In the ultra extreme case there
>    is a bypass  even using the memory channels since non volatile memory
>    (a storage device essentially) is now  supported that way.
> 
> All of this leads to the development of numerous specialized accellerators
> and special mechamisms to access memory on such devices. We already see a
> proliferation of various remote memory schemes (HMM, PCI device memory
> etc)
> 
> So how does memory work in the systems of the future? It seems that we may
> need some new way of tracking memory that is remote on some device in
> additional to the classic NUMA nodes? Or can we change the existing NUMA
> schemes to cover these use cases?
> 
> We need some consistent and hopefully vendor neutral way to work with
> memory I think.

Note that i proposed a topic about that [1] NUMA is really hard to work
with for device memory and adding memory that might not be cache coherent
or not support atomic operation, is not a good idea to report as regular
NUMA as existing application might start using such memory unaware of all
its peculiarities.

Anyway it is definitly a topic i beliew we need to discuss and i intend
to present the problem from GPU/accelerator point of view (as today this
are the hardware with sizeable fast local memory).

Cheers,
Jérôme

[1] https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1904033.html


> 
> 
> 
> 
> 
> ----- Old proposal
> 
> 
> 00G Infiniband will become available this year. This means that the data
> ingest speeds can be higher than the bandwidth of the processor
> interacting with its own memory.
> 
> For example a single hardware thread is limited to 20Gbyte/sec whereas the
> network interface provides 50Gbytes/sec. These rates can only be obtained
> currently with pinned memory.
> 
> How can we evolve the memory management subsystem to operate at higher
> speeds with more the comforts of paging and system calls that we are used
> to?
> 
> It is likely that these speeds with increase further and since the lead
> processor vendor seems to be caught in a management induced corporate
> suicide attempt we will not likely see any process on the processors from
> there. The straightforward solution would be to use the high speed tech
> for fabrics for the internal busses (doh!). Alternate processors are
> likely to show up in 2019 and 2020 but those will take a long time to
> mature.
> 
> So what does the future hold and how do we scale up our HPC systems given
> these problems?
> 

