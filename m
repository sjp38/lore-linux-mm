Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 253C56B0007
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 08:41:09 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id v8so10678088iob.0
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 05:41:09 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id e81si5747975ioa.323.2018.02.26.05.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 05:41:08 -0800 (PST)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1QDf2k5138326
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:41:07 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2gcj9w09w4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:41:04 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w1QDdub1028949
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:39:56 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w1QDdtxL005775
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:39:55 GMT
Received: by mail-ot0-f173.google.com with SMTP id 95so13360664ote.5
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 05:39:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <dda0457a-c16a-3440-a547-15f49e52ec95@suse.com>
References: <20180223232538.4314-1-pasha.tatashin@oracle.com>
 <20180223232538.4314-2-pasha.tatashin@oracle.com> <dda0457a-c16a-3440-a547-15f49e52ec95@suse.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 26 Feb 2018 08:39:54 -0500
Message-ID: <CAOAebxt6CtQYQ5MxOrpyrLdVapPnw3XePTWUAz1SGuRoukaNGA@mail.gmail.com>
Subject: Re: [v1 1/1] xen, mm: Allow deferred page initialization for xen pv domains
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, akataria@vmware.com, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, boris.ostrovsky@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andy Lutomirski <luto@kernel.org>, labbott@redhat.com, kirill.shutemov@linux.intel.com, bp@suse.de, minipli@googlemail.com, jinb.park7@gmail.com, dan.j.williams@intel.com, bhe@redhat.com, zhang.jia@linux.alibaba.com, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, virtualization@lists.linux-foundation.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, xen-devel@lists.xenproject.org, Linux Memory Management List <linux-mm@kvack.org>

Hi Juergen,

Thank you for taking a look at this patch, I will address your
comments, and send out an updated patch.

>>  extern void default_banner(void);
>>
>> +static inline void paravirt_after_bootmem(void)
>> +{
>> +     pv_init_ops.after_bootmem();
>> +}
>> +
>
> Putting this in the paravirt framework is overkill IMO. There is no need
> to patch the callsites for optimal performance.
>
> I'd put it into struct x86_hyper_init and pre-init it with x86_init_noop

Sure, I will move it into x86_hyper_init.

>>
>> +/*
>> + * During early boot all pages are pinned, but we do not have struct pages,
>> + * so return true until struct pages are ready.
>> + */
>
> Uuh, this comment is just not true.
>
> The "pinned" state for Xen means it is a pv pagetable known to Xen. Such
> pages are read-only for the guest and can be modified via hypercalls
> only.
>
> So either the "pinned" state will be tested for page tables only, in
> which case the comment needs adjustment, or the code is wrong.

The comment should state: During early boot all _page table_ pages are pinned

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
