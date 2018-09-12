Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAE038E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:29:04 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b8-v6so2515365oib.4
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 07:29:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i5-v6si782588oii.19.2018.09.12.07.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 07:29:03 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8CEOeRQ082191
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:29:03 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mf3kgkc5x-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:29:02 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 12 Sep 2018 15:29:01 +0100
Date: Wed, 12 Sep 2018 16:28:56 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH] memory_hotplug: fix the panic when memory end is not on
 the section boundary
In-Reply-To: <abf84f61-82f3-e3d5-2e6e-82a11cb5dcf5@microsoft.com>
References: <20180910123527.71209-1-zaslonko@linux.ibm.com>
	<20180910131754.GG10951@dhcp22.suse.cz>
	<e8d75768-9122-332b-3b16-cad032aeb27f@microsoft.com>
	<20180910135959.GI10951@dhcp22.suse.cz>
	<CAGM2reZuGAPmfO8x0TnHnqHci_Hsga3-CfM9+udJs=gUQCw-1g@mail.gmail.com>
	<20180910141946.GJ10951@dhcp22.suse.cz>
	<CAGM2reZ5OD9SRW8j9iaQAk9jpr86pF2NqpBjv-dxH+1vJZs0=g@mail.gmail.com>
	<20180910144152.GL10951@dhcp22.suse.cz>
	<abf84f61-82f3-e3d5-2e6e-82a11cb5dcf5@microsoft.com>
MIME-Version: 1.0
Message-Id: <20180912162856.697038a8@thinkpad>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: Michal Hocko <mhocko@kernel.org>, "zaslonko@linux.ibm.com" <zaslonko@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "osalvador@suse.de" <osalvador@suse.de>

On Mon, 10 Sep 2018 15:26:55 +0000
Pasha Tatashin <Pavel.Tatashin@microsoft.com> wrote:

> 
> I agree memoryblock is a hack, it fails to do both things it was
> designed to do:
> 
> 1. On bare metal you cannot free a physical dimm of memory using
> memoryblock granularity because memory devices do not equal to physical
> dimms. Thus, if for some reason a particular dimm must be
> remove/replaced, memoryblock does not help us.
> 
> 2. On machines with hypervisors it fails to provide an adequate
> granularity to add/remove memory.
> 
> We should define a new user interface where memory can be added/removed
> at a finer granularity: sparse section size, but without a memory
> devices for each section. We should also provide an optional access to
> legacy interface where memory devices are exported but each is of
> section size.
> 
> So, when legacy interface is enabled, current way would work:
> 
> echo offline > /sys/devices/system/memory/memoryXXX/state
> 
> And new interface would allow us to do something like this:
> 
> echo offline 256M > /sys/devices/system/node/nodeXXX/memory
> 
> With optional start address for offline memory.
> echo offline [start_pa] size > /sys/devices/system/node/nodeXXX/memory
> start_pa and size must be section size aligned (128M).
> 
> It would probably be a good discussion for the next MM Summit how to
> solve the current memory hotplug interface limitations.

Please keep lsmem/chmem from util-linux in mind, when changing the
memory hotplug user interface.
