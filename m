Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A43796B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:36:05 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m19so3958778pgv.5
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:36:05 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c7si9526074pgn.791.2018.02.15.05.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 05:36:04 -0800 (PST)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1FDYuLX160194
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:36:03 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2g5b7e004w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:36:03 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w1FDa2IU030472
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:36:02 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w1FDa2et022541
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:36:02 GMT
Received: by mail-ot0-f176.google.com with SMTP id q9so23401584oti.0
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:36:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180215113407.GB7275@dhcp22.suse.cz>
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
 <20180213193159.14606-2-pasha.tatashin@oracle.com> <20180215113407.GB7275@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 15 Feb 2018 08:36:00 -0500
Message-ID: <CAOAebxvF6mxDb4Ub02F0B9TEMRJUG0UGrKJ6ypaMGcje80cy6w@mail.gmail.com>
Subject: Re: [PATCH v3 1/4] mm/memory_hotplug: enforce block size aligned
 range check
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

Hi Michal,

Thank you very much for your reviews and for Acking this patch.

>
> The whole memblock != section_size sucks! It leads to corner cases like
> you see. There is no real reason why we shouldn't be able to to online
> 2G unaligned memory range. Failing for that purpose is just wrong. The
> whole thing is just not well thought through and works only for well
> configured cases.

Hotplug operates over memory blocks, and it seems that conceptually
memory blocks are OK: their sizes are defined by arch, and may
represent a pluggable dimm (on virtual machines it is a different
story though). If we forced memory blocks to be equal to section size,
that would force us to handle millions of memory devices in sysfs,
which would not scale well.

>
> Your patch doesn't address the underlying problem.

What is the underlying problem? The hotplug operation was allowed, but
we ended up with half populated memory block, which is broken. The
patch solves this problem by making sure that this is never the case
for any arch, no matter what block size is defined as unit of
hotplugging.

> On the other hand, it
> is incorrect to check memory section here conceptually because this is
> not a hotplug unit as you say so I am OK with the patch regardless. It
> deserves a big fat TODO to fix this properly at least. I am not sure why
> we insist on the alignment in the first place. All we should care about
> is the proper memory section based range. The code is crap and it
> assumes pageblock start aligned at some places but there shouldn't be
> anything fundamental to change that.

So, if I understand correctly, ideally you would like to redefine unit
of memory hotplug to be equal to section size?

>
>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>
> Acked-by: Michal Hocko <mhocko@suse.com>

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
