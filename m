Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7EAF46B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 13:25:00 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id wb13so9760014obb.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 10:25:00 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id vg10si9124798obb.89.2016.01.28.10.24.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 10:24:59 -0800 (PST)
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Huge Page Futures
References: <56A580F8.4060301@oracle.com>
 <20160125110137.GB11541@node.shutemov.name> <56A62837.7010105@oracle.com>
 <56A90345.3020903@oracle.com> <20160128092122.GH3104@suse.de>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56AA5CF7.1040108@oracle.com>
Date: Thu, 28 Jan 2016 10:24:55 -0800
MIME-Version: 1.0
In-Reply-To: <20160128092122.GH3104@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On 01/28/2016 01:21 AM, Mel Gorman wrote:
> On Wed, Jan 27, 2016 at 09:49:57AM -0800, Mike Kravetz wrote:
>> On 01/25/2016 05:50 AM, Mike Kravetz wrote:
>>>> Do you have any thoughts how it's going to be implemented? It would be
>>>> nice to have some design overview or better proof-of-concept patch before
>>>> the summit to be able analyze implications for the kernel.
>>>>
>>>
>>> Good to know the hugetlbfs implementation is considered a hack.  I just
>>> started looking at this, and was going to use hugetlbfs as a starting
>>> point.  I'll reconsider that decision.
>>
>> Kirill, can you (or others) explain your reasons for saying the hugetlbfs
>> implementation is an ugly hack?  I do not have enough history/experience
>> with this to say what is most offensive.  I would be happy to start by
>> cleaning up issues with the current implementation.
>>
> 
> Historically, it was considered a hack because it had special handling in
> a number of paths in the VM. Of course THP also has similar handling now
> so it's less of a concern but there are differences that cause base pages,
> transparent hugepages and hugetlbfs pages to all be special cases. That
> does not sit comfortably with everyone.
> 
> For a long time, it was considered ugly because a fault on private child
> mappings was so unreliable and a fork could cause a parent to unexpectedly
> fail a fault and die. These days it's different as only the child can die
> so while it's less of a concern, hugetlbfs pages allow a child to be killed
> if enough huge pages are not available.
> 
> It was also considered ugly because application-awareness was required in
> so many cases. Granted, libhugetlbfs can hide some of that ugliness but
> even that was considered hacky.
> 
> The fact that hugetlbfs pages cannot be swapped even without mlock is
> another fact that makes them different to the rest of the VM. It has its
> own reservation scheme that is different to everything else.
> 
> One that crippled it to some extent with the label was the fact that fixing
> swap on it was effectively impossible because of power. Once huge pages
> had been installed on that architecture for a lont time, it was impossible
> to remap them at a different size. The limitation has been relaxed to some
> extent but those around long enough remember it.
> 
> So it is a bit of a hack that behaves differently to other page types.
> It's fairly complex and while the semantics used to be a lot uglier than
> it is now, the "ugly hack" label has stuck.

Thanks Mel.  I understand most of the issues you mention above.  However,
some DB providers make extensive use of hugetlbfs for maximum performance.
My question had more to do with shared page tables (below) than hugetlbfs
in general.

> 
>> If we do shared page tables for DAX, it makes sense that it and hugetlbfs
>> should be similar (or common) if possible.
>>
> 
> It's been a long time since I looked at shared page tables so I can't
> remember why but it was a difficult area. A few years were spent on it so
> if shared page tables are being considered, I would make damn sure first
> that they actually help on modern hardware before jumping into that hole.

IIUC, the only sharing today is in hugetlbfs at the PMD level.  Sharing
at this level for 2M huge pages still provides significant memory savings
for some large DB implementations.  Think of systems with TBs of memory,
and using large shared mappings.  There can be 10,000 or more processes
sharing these mappings.  You can expect that pmem will provide more
opportunities for sharing of large mappings.  My intention was to explore
the possibility of providing this type of sharing (at a minimum) to huge
pages for DAX mappings.  I was only looking at this from the space saving
angle.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
