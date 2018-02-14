Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 829386B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 09:19:21 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id o10so12820788iob.17
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:19:21 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z124si6622258itb.153.2018.02.14.06.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 06:19:20 -0800 (PST)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1EEHCgq119833
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:19:19 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2g4pqc01d1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:19:19 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w1EEEIZk008505
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:14:18 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w1EEEI7b025287
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:14:18 GMT
Received: by mail-ot0-f171.google.com with SMTP id w10so6945308ote.13
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:14:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180214080930.n44x3arzqanja5zq@gmail.com>
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
 <20180213135359.705680d373a482b650f38b50@linux-foundation.org> <20180214080930.n44x3arzqanja5zq@gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 14 Feb 2018 09:14:17 -0500
Message-ID: <CAOAebxsAXC8CgoRdeD4=1ePwoB6TeqprZgnkenU-aCeKGv_p+w@mail.gmail.com>
Subject: Re: [PATCH v3 0/4] optimize memory hotplug
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

Hi Ingo,

Thank you very much for your review. I will address spelling issues,
and will also try to split the patch #4.  Regarding runtime concern
for patch #3: the extra checking is only performed when the both of
the following CONFIGs are enabled:

CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_PGFLAGS=y

I do not expect either of these to be ever enabled on a production systems.

Thank you,
Pavel

On Wed, Feb 14, 2018 at 3:09 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Tue, 13 Feb 2018 14:31:55 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
>>
>> > This patchset:
>> > - Improves hotplug performance by eliminating a number of
>> > struct page traverses during memory hotplug.
>> >
>> > - Fixes some issues with hotplugging, where boundaries
>> > were not properly checked. And on x86 block size was not properly aligned
>> > with end of memory
>> >
>> > - Also, potentially improves boot performance by eliminating condition from
>> >   __init_single_page().
>> >
>> > - Adds robustness by verifying that that struct pages are correctly
>> >   poisoned when flags are accessed.
>>
>> I'm now attempting to get a 100% review rate on MM patches, which is
>> why I started adding my Reviewed-by: when I do that thing.
>>
>> I'm not familiar enough with this code to add my own Reviewed-by:, and
>> we'll need to figure out what to do in such cases.  I shall be sending
>> out periodic review-status summaries.
>>
>> If you're able to identify a suitable reviewer for this work and to
>> offer them beer, that would help.  Let's see what happens as the weeks
>> unfold.
>
> The largest patch, fix patch #2, looks good to me and fixes a real bug.
> Patch #1 and #3 also look good to me (assuming the runtime overhead
> added by patch #3 is OK to you):
>
>   Reviewed-by: Ingo Molnar <mingo@kernel.org>
>
> (I suspect patch #1 and patch #2 should also get a Cc: stable.)
>
> Patch #4 is too large to review IMO: it should be split up into as many patches as
> practically possible. That will also help bisectability, should anything break.
>
> Before applying these patches please fix changelog and code comment spelling.
>
> But it's all good stuff AFAICS!
>
> Thanks,
>
>         Ingo
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
