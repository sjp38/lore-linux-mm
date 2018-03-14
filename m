Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06D946B0007
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 20:59:49 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id h7-v6so858143oti.23
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:59:49 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id a15si379246oiy.90.2018.03.13.17.59.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 17:59:47 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w2E0vEcc064770
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 00:59:47 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2gprh4r5q3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 00:59:47 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w2E0xkET031914
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 00:59:46 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w2E0xjOS020145
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 00:59:46 GMT
Received: by mail-ot0-f169.google.com with SMTP id r30-v6so1622338otr.2
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:59:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180313142412.d373318b81164c4cb4b864b3@linux-foundation.org>
References: <20180309220807.24961-1-pasha.tatashin@oracle.com>
 <20180309220807.24961-2-pasha.tatashin@oracle.com> <20180312130410.e2fce8e5e38bc2086c7fd924@linux-foundation.org>
 <20180313160430.hbjnyiazadt3jwa6@xakep.localdomain> <20180313115549.7badec1c6b85eb5a1cf21eb6@linux-foundation.org>
 <20180313194546.k62tni4g4gnds2nx@xakep.localdomain> <20180313131156.f156abe1822a79ec01c4800a@linux-foundation.org>
 <ff16234e-eb45-ca99-bfec-6d33967e9c8f@oracle.com> <20180313142412.d373318b81164c4cb4b864b3@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 13 Mar 2018 20:59:04 -0400
Message-ID: <CAGM2reZb4ZCxhENGCwuxpUYe6TfiDFbMxsrS8eCfiU_=thOJKg@mail.gmail.com>
Subject: Re: [v5 1/2] mm: disable interrupts while initializing deferred pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Wei Yang <richard.weiyang@gmail.com>, Paul Burton <paul.burton@mips.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> hm, maybe.  But I'm not sure that touch_nmi_watchdog() will hold off a
> soft lockup warning.  Maybe it will.

It should:

124static inline void touch_nmi_watchdog(void)
125{
126 arch_touch_nmi_watchdog();
127 touch_softlockup_watchdog();
128}

>
> And please let's get the above thoughts into the changlog.

OK

>
>> >
>> > I'm not sure what to suggest, really.  Your changelog isn't the best:
>> > "Vlastimil Babka reported about a window issue during which when
>> > deferred pages are initialized, and the current version of on-demand
>> > initialization is finished, allocations may fail".  Well...  where is
>> > ths mysterious window?  Without such detail it's hard for others to
>> > suggest alternative approaches.
>>
>> Here is hopefully a better description of the problem:
>>
>> Currently, during boot we preinitialize some number of struct pages to s=
atisfy all boot allocations. Even if these allocations happen when we initi=
alize the reset of deferred pages in page_alloc_init_late(). The problem is=
 that we do not know how much kernel will need, and it also depends on vari=
ous options.
>>
>> So, with this work, we are changing this behavior to initialize struct p=
ages on-demand, only when allocations happen.
>>
>> During boot, when we try to allocate memory, the on-demand struct page i=
nitialization code takes care of it. But, once the deferred pages are initi=
alizing in:
>>
>> page_alloc_init_late()
>>    for_each_node_state(nid, N_MEMORY)
>>       kthread_run(deferred_init_memmap())
>>
>> We cannot use on-demand initialization, as these threads resize pgdat.
>>
>> This whole thing is to take care of this time.
>>
>> My first version of on-demand deferred page initialization would simply =
fail to allocate memory during this period of time. But, this new version w=
aits for threads to finish initializing deferred memory, and successfully p=
erform the allocation.
>>
>> Because interrupt handler would wait for pgdat resize lock.
>
> OK, thanks.  Please also add to changelog.

OK, I will send an updated patch, with changelog changes.
