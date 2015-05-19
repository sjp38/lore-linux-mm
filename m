Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 22E306B00A0
	for <linux-mm@kvack.org>; Tue, 19 May 2015 05:01:43 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so13566180wic.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 02:01:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bn2si17213484wib.0.2015.05.19.02.01.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 02:01:41 -0700 (PDT)
Message-ID: <555AFBF3.1010601@suse.cz>
Date: Tue, 19 May 2015 11:01:39 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 19/28] mm: store mapcount for compound page separately
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-20-git-send-email-kirill.shutemov@linux.intel.com> <5559F7F6.7060801@suse.cz> <20150519035515.GA5795@node.dhcp.inet.fi>
In-Reply-To: <20150519035515.GA5795@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/19/2015 05:55 AM, Kirill A. Shutemov wrote:
>>
>>> +	if (compound_mapcount(page))
>>> +	       ret += compound_mapcount(page) - 1;
>>
>> This looks like it could uselessly duplicate-inline the code for
>> compound_mapcount(). It has atomics and smp_rmb() so I'm not sure if the
>> compiler can just "squash it".
>
> Good point. I'll rework this.

Hm BTW I think same duplication of compound_head() happens in 
lock_page(), where it's done by trylock_page() and then __lock_page(), 
which is also in different compilation unit to make things worse.

I can imagine it's solvable by introducing variants of __lock_page* that 
expect to be already given a head page... if it's worth the trouble.

>>
>> On the other hand, a simple atomic read that was page_mapcount() has turned
>> into multiple atomic reads and flag checks. What about the stability of the
>> whole result? Are all callers ok? (maybe a later page deals with it).
>
> Urghh.. I'll look into this.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
