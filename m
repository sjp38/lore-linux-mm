Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 913906B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 19:29:32 -0400 (EDT)
Received: by oixx19 with SMTP id x19so13574718oix.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 16:29:32 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n4si20762786oek.87.2015.07.29.16.29.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 16:29:31 -0700 (PDT)
Subject: Re: hugetlb pages not accounted for in rss
References: <55B6BE37.3010804@oracle.com>
 <20150728183248.GB1406@Sligo.logfs.org> <55B7F0F8.8080909@oracle.com>
 <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com>
 <20150728222654.GA28456@Sligo.logfs.org>
 <alpine.DEB.2.10.1507281622470.10368@chino.kir.corp.google.com>
 <20150729005332.GB17938@Sligo.logfs.org>
 <alpine.DEB.2.10.1507291205590.24373@chino.kir.corp.google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <55B95FDB.1000801@oracle.com>
Date: Wed, 29 Jul 2015 16:20:59 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1507291205590.24373@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, =?UTF-8?Q?J=c3=b6rn_Engel?= <joern@purestorage.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 07/29/2015 12:08 PM, David Rientjes wrote:
> On Tue, 28 Jul 2015, Jorn Engel wrote:
>
>> Well, we definitely need something.  Having a 100GB process show 3GB of
>> rss is not very useful.  How would we notice a memory leak if it only
>> affects hugepages, for example?
>>
>
> Since the hugetlb pool is a global resource, it would also be helpful to
> determine if a process is mapping more than expected.  You can't do that
> just by adding a huge rss metric, however: if you have 2MB and 1GB
> hugepages configured you wouldn't know if a process was mapping 512 2MB
> hugepages or 1 1GB hugepage.
>
> That's the purpose of hugetlb_cgroup, after all, and it supports usage
> counters for all hstates.  The test could be converted to use that to
> measure usage if configured in the kernel.
>
> Beyond that, I'm not sure how a per-hstate rss metric would be exported to
> userspace in a clean way and other ways of obtaining the same data are
> possible with hugetlb_cgroup.  I'm not sure how successful you'd be in
> arguing that we need separate rss counters for it.

If I want to track hugetlb usage on a per-task basis, do I then need to
create one cgroup per task?

For example, suppose I have many tasks using hugetlb and the global pool
is getting low on free pages.  It might be useful to know which tasks are
using hugetlb pages, and how many they are using.

I don't actually have this need (I think), but it appears to be what
Jorn is asking for.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
