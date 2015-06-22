Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 196A06B0071
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 12:07:04 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so20630645wgq.1
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 09:07:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6si20484195wic.107.2015.06.22.09.07.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Jun 2015 09:07:02 -0700 (PDT)
Message-ID: <558832A4.6060609@suse.cz>
Date: Mon, 22 Jun 2015 18:07:00 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv6 36/36] thp: update documentation
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com> <1433351167-125878-37-git-send-email-kirill.shutemov@linux.intel.com> <55797F57.8040001@suse.cz> <20150622131827.GF7934@node.dhcp.inet.fi>
In-Reply-To: <20150622131827.GF7934@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/22/2015 03:18 PM, Kirill A. Shutemov wrote:
> On Thu, Jun 11, 2015 at 02:30:15PM +0200, Vlastimil Babka wrote:
>> On 06/03/2015 07:06 PM, Kirill A. Shutemov wrote:
>>> The patch updates Documentation/vm/transhuge.txt to reflect changes in
>>> THP design.
>>
>> One thing I'm missing is info about the deferred splitting.
>
> Okay, I'll add this.

Thanks.

>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>> ---
>>>   Documentation/vm/transhuge.txt | 124 +++++++++++++++++++++++------------------
>>>   1 file changed, 69 insertions(+), 55 deletions(-)
>>>
>>> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
>>> index 6b31cfbe2a9a..2352b12cae93 100644
>>> --- a/Documentation/vm/transhuge.txt
>>> +++ b/Documentation/vm/transhuge.txt
>>> @@ -35,10 +35,10 @@ miss is going to run faster.
>>>
>>>   == Design ==
>>>
>>> -- "graceful fallback": mm components which don't have transparent
>>> -  hugepage knowledge fall back to breaking a transparent hugepage and
>>> -  working on the regular pages and their respective regular pmd/pte
>>> -  mappings
>>> +- "graceful fallback": mm components which don't have transparent hugepage
>>> +  knowledge fall back to breaking huge pmd mapping into table of ptes and,
>>> +  if nesessary, split a transparent hugepage. Therefore these components
>>
>>          necessary
>>> +
>>> +split_huge_page uses migration entries to stabilize page->_count and
>>> +page->_mapcount.
>>
>> Hm, what if there's some physical memory scanner taking page->_count pins? I
>> think compaction shouldn't be an issue, but maybe some others?
>
> The only legitimate way scanner can get reference to a page is
> get_page_unless_zero(), right?

I think so.

> All tail pages has zero ->_count until atomic_add() in
> __split_huge_page_tail() -- get_page_unless_zero() will fail.
> After the atomic_add() we don't care about ->_count value.
> We already known how many references with should uncharge from
> head page.
>
> For head page get_page_unless_zero() will succeed and we don't
> mind. It's clear where reference should go after split: it will
> stay on head page.

I guess that works, but it's rather non-obvious thus worth documenting 
somewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
