Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 735E92808E3
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 17:37:56 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id n84so106269554oih.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 14:37:56 -0800 (PST)
Received: from mail-ot0-x230.google.com (mail-ot0-x230.google.com. [2607:f8b0:4003:c0f::230])
        by mx.google.com with ESMTPS id m54si432679otb.226.2017.03.09.14.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 14:37:55 -0800 (PST)
Received: by mail-ot0-x230.google.com with SMTP id i1so66229544ota.3
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 14:37:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <19605238.M7OFe3HAv5@aspire.rjw.lan>
References: <20170309130616.51286-1-heiko.carstens@de.ibm.com>
 <CAPcyv4jXmxjVaR=sGfqjy2QP_Yq4ALfTQb9_QMZ3tk0ntxfTFA@mail.gmail.com>
 <3207330.x0D3JT6f2l@aspire.rjw.lan> <19605238.M7OFe3HAv5@aspire.rjw.lan>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 9 Mar 2017 14:37:55 -0800
Message-ID: <CAPcyv4gX-7BAZOEvi7UShZD0bo6JV1D7tiU5wQweauG0tx=Luw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: add private lock to serialize memory hotplug operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Thu, Mar 9, 2017 at 2:22 PM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> On Thursday, March 09, 2017 11:15:47 PM Rafael J. Wysocki wrote:
>> On Thursday, March 09, 2017 10:10:31 AM Dan Williams wrote:
>> > On Thu, Mar 9, 2017 at 5:39 AM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
[..]
>> > I *think* we're ok in this case because unplugging the CPU package
>> > that contains a persistent memory device will trigger
>> > devm_memremap_pages() to call arch_remove_memory(). Removing a pmem
>> > device can't fail. It may be held off while pages are pinned for DMA
>> > memory, but it will eventually complete.
>>
>> What about the offlining, though?  Is it guaranteed that no memory from those
>> ranges will go back online after the acpi_scan_try_to_offline() call in
>> acpi_scan_hot_remove()?
>
> My point is that after the acpi_evaluate_ej0() in acpi_scan_hot_remove() the
> hardware is physically gone, so if anything is still doing DMA to that memory at
> that point, then the user is going to be unhappy.

Hmm, ACPI 6.1 does not have any text about what _EJ0 means for ACPI0012.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
