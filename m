Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id D58AA6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 13:46:34 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so1401453pbb.11
        for <linux-mm@kvack.org>; Thu, 15 May 2014 10:46:34 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ap2si3048502pbc.46.2014.05.15.10.46.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 15 May 2014 10:46:34 -0700 (PDT)
Message-ID: <5374FCC0.8010809@oracle.com>
Date: Thu, 15 May 2014 13:43:28 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in do_huge_pmd_wp_page
References: <51559150.3040407@oracle.com> <515D882E.6040001@oracle.com> <533F09F0.1050206@oracle.com> <20140407144835.GA17774@node.dhcp.inet.fi> <5342FF3E.6030306@oracle.com> <20140407201106.GA21633@node.dhcp.inet.fi> <5374FA04.5@oracle.com> <alpine.LSU.2.11.1405151034160.4721@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1405151034160.4721@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Josh Boyer <jwboyer@fedoraproject.org>

On 05/15/2014 01:37 PM, Hugh Dickins wrote:
> On Thu, 15 May 2014, Sasha Levin wrote:
>> On 04/07/2014 04:11 PM, Kirill A. Shutemov wrote:
>>> On Mon, Apr 07, 2014 at 03:40:46PM -0400, Sasha Levin wrote:
>>>>> It also breaks fairly quickly under testing because:
>>>>>
>>>>> On 04/07/2014 10:48 AM, Kirill A. Shutemov wrote:
>>>>>>> +	if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC)) {
>>>>>>> +		spin_lock(ptl);
>>>>>
>>>>> ^ We go into atomic
>>>>>
>>>>>>> +		if (unlikely(!pmd_same(*pmd, orig_pmd)))
>>>>>>> +			goto out_race;
>>>>>>> +	}
>>>>>>> +
>>>>>>>  	if (!page)
>>>>>>>  		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
>>>>>>>  	else
>>>>>>>  		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
>>>>>
>>>>> copy_user_huge_page() doesn't like running in atomic state,
>>>>> and asserts might_sleep().
>>> Okay, I'll try something else.
>>
>> I've Cc'ed Josh Boyer to this since it just occurred to me that Fedora
>> is running with CONFIG_DEBUG_VM set, where this bug is rather easy to
>> trigger.
>>
>> This issue was neglected because it triggers only on CONFIG_DEBUG_VM builds,
>> but with Fedora running that, maybe it shouldn't be?
> 
> But it triggers only on CONFIG_DEBUG_PAGEALLOC builds, doesn't it?
> I hope Fedora doesn't go out with that enabled.

Ow, it needs DEBUG_PAGEALLOC too? I forgot about that one.

No problem for Fedora then, sorry for the noise :(


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
