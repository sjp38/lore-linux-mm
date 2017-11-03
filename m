Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC8616B0069
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 10:18:00 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id z50so1995911qtj.9
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 07:18:00 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s77si1303252qks.432.2017.11.03.07.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 07:18:00 -0700 (PDT)
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id vA3EHxWT021250
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 3 Nov 2017 14:17:59 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id vA3EHwBF019418
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 3 Nov 2017 14:17:59 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id vA3EHw3K000726
	for <linux-mm@kvack.org>; Fri, 3 Nov 2017 14:17:58 GMT
Received: by mail-oi0-f52.google.com with SMTP id c77so2179023oig.0
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 07:17:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171103085958.pewhlyvkr5oa2fgf@dhcp22.suse.cz>
References: <20171031155002.21691-1-pasha.tatashin@oracle.com>
 <20171031155002.21691-2-pasha.tatashin@oracle.com> <20171102133235.2vfmmut6w4of2y3j@dhcp22.suse.cz>
 <a9b637b0-2ff0-80e8-76a7-801c5c0820a8@oracle.com> <20171102135423.voxnzk2qkvfgu5l3@dhcp22.suse.cz>
 <94ab73c0-cd18-f58f-eebe-d585fde319e4@oracle.com> <20171102140830.z5uqmrurb6ohfvlj@dhcp22.suse.cz>
 <813ed7e3-9347-a1f2-1629-464d920f877d@oracle.com> <20171102142742.gpkif3hgnd62nyol@dhcp22.suse.cz>
 <8b3bb799-818b-b6b6-7c6b-9eee709decb7@oracle.com> <20171103085958.pewhlyvkr5oa2fgf@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 3 Nov 2017 10:17:57 -0400
Message-ID: <CAOAebxuGEG=2tF+nQf2VveLuZ0Ss+64qggK2TsZDBFMtUbKEyg@mail.gmail.com>
Subject: Re: [PATCH v1 1/1] mm: buddy page accessed before initialized
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

> Why cannot we do something similar to the optimized struct page
> initialization and write 8B at the time and fill up the size unaligned
> chunk in 1B?

I do not think this is a good idea: memset() on SPARC is slow for
small sizes, this is why we ended up using stores, but thats not the
case on x86 where memset() is well optimized for small sizes. So, I
believe we will see regressions. But even without the regressions
there are several reasons why I think this is not a good idea:
1. struct page size vary depending on configs. So, in order to create
a pattern that looks like a valid struct page, we would need to figure
out what is our struct page size.
2. memblock allocator is totally independent from struct pages, it is
going to be strange to add this dependency. The allocatoted memory is
also used for page tables, and kasan, so we do not really know where
the pattern should start from the allocator point of view.
3. It is going to be too easy to break that pattern if something
changes or shifts: struct page changes, vmemmap allocations change or
anything else.

Overall, I think now we have a good coverage now: CONFIG_DEBUG_VM
option tests for totally invalid struct pages, and kexec tests for
struct pages that look like valid ones, but they are invalid because
from the previous instance of kernel.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
