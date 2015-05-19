Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1DDB56B00BF
	for <linux-mm@kvack.org>; Tue, 19 May 2015 10:37:30 -0400 (EDT)
Received: by wibt6 with SMTP id t6so25277683wib.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 07:37:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eq3si4847688wjd.142.2015.05.19.07.37.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 07:37:28 -0700 (PDT)
Message-ID: <555B4AA5.7000504@suse.cz>
Date: Tue, 19 May 2015 16:37:25 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 07/28] thp, mlock: do not allow huge pages in mlocked
 area
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-8-git-send-email-kirill.shutemov@linux.intel.com> <5555ED0A.5010702@suse.cz> <20150515134103.GC6625@node.dhcp.inet.fi>
In-Reply-To: <20150515134103.GC6625@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/15/2015 03:41 PM, Kirill A. Shutemov wrote:
> On Fri, May 15, 2015 at 02:56:42PM +0200, Vlastimil Babka wrote:
>> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
>>> With new refcounting THP can belong to several VMAs. This makes tricky
>>> to track THP pages, when they partially mlocked. It can lead to leaking
>>> mlocked pages to non-VM_LOCKED vmas and other problems.
>>> With this patch we will split all pages on mlock and avoid
>>> fault-in/collapse new THP in VM_LOCKED vmas.
>>>
>>> I've tried alternative approach: do not mark THP pages mlocked and keep
>>> them on normal LRUs. This way vmscan could try to split huge pages on
>>> memory pressure and free up subpages which doesn't belong to VM_LOCKED
>>> vmas.  But this is user-visible change: we screw up Mlocked accouting
>>> reported in meminfo, so I had to leave this approach aside.
>>>
>>> We can bring something better later, but this should be good enough for
>>> now.
>>
>> I can imagine people won't be happy about losing benefits of THP's when they
>> mlock().
>> How difficult would it be to support mlocked THP pages without splitting
>> until something actually tries to do a partial (un)mapping, and only then do
>> the split? That will support the most common case, no?
>
> Yes, it will.
>
> But what will we do if we fail to split huge page on munmap()? Fail
> munmap() with -EBUSY?

We could just unmlock the whole THP page and if we could make the 
deferred split done ASAP, and not waiting for memory pressure, the 
window with NR_MLOCK being undercounted would be minimized. Since the 
RLIMIT_MEMLOCK is tracked independently from NR_MLOCK, there should be 
no danger wrt breaching the limit due to undercounting here?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
