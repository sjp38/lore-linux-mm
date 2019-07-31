Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4740C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:46:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A0CE2067D
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:46:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dw+SeYbk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A0CE2067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A775B8E0003; Wed, 31 Jul 2019 13:46:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4DD38E0001; Wed, 31 Jul 2019 13:46:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EFA28E0003; Wed, 31 Jul 2019 13:46:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 44AF68E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:46:21 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id l16so16226886wmg.2
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:46:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=pEAfotcFLsFotBYT9u4zeRqv3NeeQAlDety7JPTf8Pk=;
        b=IzwYXMYeIn5PycDSr+avq8HE/9dnR0SS3/AaL6KTLRYlqS+Lwg6Z/6rwcRk0lltPI2
         6jkdq2WWhYFWyYXTP01cy6RDVeYNfiuVhve5zLR60NQhIAkTxHzN6wWU6ARI9rB+pz8Y
         kUwOqLo4h/xO1JljPJmntTxpIYGQggQEG5IgVfwd0ltRqUae0XS01thPPAYY/fngrqtR
         58Exa+U7vWD/5CQjQRWdgw5jbxO97Kuh6tTqtGR1L1xAd5fUjl4n/FubBy1UlK9dp6sc
         Ww0yHfX1dcN5RPYJapq+91HeSdmGSx9qihP6FtLf7XhrMoSsgoEVbB/jYRhrJzISYExI
         RAGg==
X-Gm-Message-State: APjAAAXO73hx93BJmiGRgBFO+CsxgsM8nmWjAfK4810+noEw/+aeSRIJ
	OCqiupbj6sfWJkGZlSs3Nn+DTuOwTKOdHOgT+RhotN9tlsdCk5rMpLtRSCehkns69PmiueG16+8
	iUPxVocDxHXSjJ36S7Vz2X3PN+Ltf0WyfQaJkL8L5x6Q9a1ghgc2ff/3XdJBZIjFcTw==
X-Received: by 2002:adf:afe2:: with SMTP id y34mr132299057wrd.250.1564595180828;
        Wed, 31 Jul 2019 10:46:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBjMcmGt0bnc1gkcVtHn/SEN6T8JUz0rsovJYkEfdld0qV3Eh5eNWIPm61M6Lk1XcZCTIh
X-Received: by 2002:adf:afe2:: with SMTP id y34mr132299017wrd.250.1564595180065;
        Wed, 31 Jul 2019 10:46:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564595180; cv=none;
        d=google.com; s=arc-20160816;
        b=rj0rxb9+p87CfGafx0mzAnZsoGRH/yj3CjVnT+QSjKHqgByfkGzwfbSmIBS0fV4+hh
         qw6vFLmOjqIvgu7jR/e0EN9gJjV2L8G4i9wAkUJQBJDriNACAZ9yfQSES3Auqy/WabRb
         6B5781okZP26gfR+ginMUiSE1eLDnKIopAumuvdpNaVlArYxic06s5retrALR22cQtXl
         npXxPlFaAo8fltD0m071I1slLdLwKixi/EWDBogBOTBwQp2GpJhiJJIAS9Ow5Ew0cn1j
         NMIe/n8AWpeOViCllJG/gBBGiz5Bk3fuzorWOO5eP59OwOscz71/E8kbppXMW95duFNx
         5siA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=pEAfotcFLsFotBYT9u4zeRqv3NeeQAlDety7JPTf8Pk=;
        b=kpUpkwVaqnKmNQIadn4xFCuJ6BneIm1NQmvCE4FmfzrWep4ZfAXo8DSyI5UKaZSRXL
         tq6pilm3+iVaqXWIYFhCN+etY2+FRDxI/Ed2eYO2JLJZ/JC2vwqcnuzF/M3j84Myr+ij
         hDscEoolum4dDa6UstRrYtZhltpEIu6dEHD++4ehuux9KKG6FBtK+9zkMQEJB/YqOS97
         byyNOIWDIbxGJ5GlalkGtQ5Cd9872mGYdyBeBIE1a2ohun3ref0HC5rKvN7YaGBDUlkj
         AJ+L8l22RkEfZKTaU2nA4asMUlyRPCXg68GqC+Guh6kyP81t0Qyai8cf2R7u3MyVOtPj
         FyHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=dw+SeYbk;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id g3si71815987wrb.272.2019.07.31.10.46.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 10:46:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=dw+SeYbk;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=pEAfotcFLsFotBYT9u4zeRqv3NeeQAlDety7JPTf8Pk=; b=dw+SeYbkgl15ByYdw4RBRwGpI5
	OQRbhMYNZQy3bzAx5TIQcL6nZ4sauiIJzRse8yongu5JqPY6aoJalrxRvlk01U/pCwDOw/2pmFJaD
	P1gRHYsrEp+s+iq8YUjI4MGLu//erIQdXrho9cOTBXZKeLz8JFQpS+d+T6SVCRqsaBTceMtiBPAL9
	K6qZqrz0yuqnuZ3oMdNwOb05wHSS4MloOj9+DKViGd5eR1DPhulBDXdM72Qf3YxGHWdhjFCH5PT3m
	ioWvgp3GDSoi8julWf1KoQx7EnwTzV5jyNDyqyWBQzDDbz0lPbNq/vbmvDf5oWMOc7VHyKca5WKls
	QitLDIVA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=[192.168.1.17])
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hssfH-000639-C3; Wed, 31 Jul 2019 17:45:28 +0000
Subject: Re: microblaze HAVE_MEMBLOCK_NODE_MAP dependency (was Re: [PATCH v2
 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA)
To: Mike Rapoport <rppt@linux.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: Hoan Tran OS <hoan@os.amperecomputing.com>, Will Deacon
 <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
 Paul Mackerras <paulus@samba.org>, "H . Peter Anvin" <hpa@zytor.com>,
 "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
 Michael Ellerman <mpe@ellerman.id.au>, "x86@kernel.org" <x86@kernel.org>,
 Christian Borntraeger <borntraeger@de.ibm.com>,
 Ingo Molnar <mingo@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Open Source Submission <patches@amperecomputing.com>,
 Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will.deacon@arm.com>,
 Borislav Petkov <bp@alien8.de>, Thomas Gleixner <tglx@linutronix.de>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, Oscar Salvador <osalvador@suse.de>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
 "David S . Miller" <davem@davemloft.net>,
 "willy@infradead.org" <willy@infradead.org>, Michal Simek <monstr@monstr.eu>
References: <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
 <20190730081415.GN9330@dhcp22.suse.cz> <20190731062420.GC21422@rapoport-lnx>
 <20190731080309.GZ9330@dhcp22.suse.cz> <20190731111422.GA14538@rapoport-lnx>
 <20190731114016.GI9330@dhcp22.suse.cz> <20190731122631.GB14538@rapoport-lnx>
 <20190731130037.GN9330@dhcp22.suse.cz> <20190731142129.GA24998@rapoport-lnx>
 <20190731144114.GY9330@dhcp22.suse.cz> <20190731171510.GB24998@rapoport-lnx>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <57b08afb-d07e-a24f-4cfe-5a633227ed6b@infradead.org>
Date: Wed, 31 Jul 2019 10:45:24 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190731171510.GB24998@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/31/19 10:15 AM, Mike Rapoport wrote:
> On Wed, Jul 31, 2019 at 04:41:14PM +0200, Michal Hocko wrote:
>> On Wed 31-07-19 17:21:29, Mike Rapoport wrote:
>>> On Wed, Jul 31, 2019 at 03:00:37PM +0200, Michal Hocko wrote:
>>>>
>>>> I am sorry, but I still do not follow. Who is consuming that node id
>>>> information when NUMA=n. In other words why cannot we simply do
>>>  
>>> We can, I think nobody cared to change it.
>>
>> It would be great if somebody with the actual HW could try it out.
>> I can throw a patch but I do not even have a cross compiler in my
>> toolbox.
> 
> Well, it compiles :)

Adding Michal Simek <monstr@monstr.eu>.

It's not clear that the MICROBLAZE maintainer is still supporting MICROBLAZE.

>>>> diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
>>>> index a015a951c8b7..3a47e8db8d1c 100644
>>>> --- a/arch/microblaze/mm/init.c
>>>> +++ b/arch/microblaze/mm/init.c
>>>> @@ -175,14 +175,9 @@ void __init setup_memory(void)
>>>>  
>>>>  		start_pfn = memblock_region_memory_base_pfn(reg);
>>>>  		end_pfn = memblock_region_memory_end_pfn(reg);
>>>> -		memblock_set_node(start_pfn << PAGE_SHIFT,
>>>> -				  (end_pfn - start_pfn) << PAGE_SHIFT,
>>>> -				  &memblock.memory, 0);
>>>> +		memory_present(0, start_pfn << PAGE_SHIFT, end_pfn << PAGE_SHIFT);
>>>
>>> memory_present() expects pfns, the shift is not needed.
>>
>> Right.
>>
>> -- 
>> Michal Hocko
>> SUSE Labs


-- 
~Randy

