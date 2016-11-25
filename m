Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 605846B0267
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 03:42:12 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so20407259wmd.6
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 00:42:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si12654183wmg.23.2016.11.25.00.42.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 00:42:11 -0800 (PST)
Subject: Re: mm: BUG in pgtable_pmd_page_dtor
References: <CACT4Y+Z0QqeO-fpc_tuStBGPWMwcK-gT-2q+tPmDpQDCkqYUiQ@mail.gmail.com>
 <f8963cc3-69a8-a1ca-9b56-205d919eac41@suse.cz>
 <CACT4Y+Z0f51iJjwTLxqwY2PZObLQpF+GujKQ34enBA3fBp8QiQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <296bdd6b-5c9e-0fbc-8aa1-4e95d0aff031@suse.cz>
Date: Fri, 25 Nov 2016 09:42:07 +0100
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Z0f51iJjwTLxqwY2PZObLQpF+GujKQ34enBA3fBp8QiQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

On 11/24/2016 03:23 PM, Dmitry Vyukov wrote:
> On Thu, Nov 24, 2016 at 2:49 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> On 11/18/2016 11:19 AM, Dmitry Vyukov wrote:
>>>
>>> Hello,
>>>
>>> I've got the following BUG while running syzkaller on
>>> a25f0944ba9b1d8a6813fd6f1a86f1bd59ac25a6 (4.9-rc5). Unfortunately it's
>>> not reproducible.
>>>
>>> kernel BUG at ./include/linux/mm.h:1743!
>>> invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
>>
>>
>> Shouldn't there be also dump_page() output? Since you've hit this:
>> VM_BUG_ON_PAGE(page->pmd_huge_pte, page);
> 
> Here it is:
> 
> [  250.326131] page:ffffea0000e196c0 count:1 mapcount:0 mapping:
>    (null) index:0x0
> [  250.343393] flags: 0x1fffc0000000000()
> [  250.345328] page dumped because: VM_BUG_ON_PAGE(page->pmd_huge_pte)
> [  250.346780] ------------[ cut here ]------------
> [  250.347742] kernel BUG at ./include/linux/mm.h:1743!

Yeah, as expected, not very useful for this particular BUG_ON :/

>> Anyway the output wouldn't contain the value of pmd_huge_pte or stuff that's
>> in union with it. I'd suggest adding a local patch that prints this in the
>> error case, in case the fuzzer hits it again.
>>
>> Heck, it might even make sense to print raw contents of struct page in
>> dump_page() as a catch-all solution? Should I send a patch?
> 
> Yes, please send.
> We are moving towards continuous build without local patches.

Something like this?
-------8<-------
