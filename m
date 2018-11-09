Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44F476B06D4
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 05:25:02 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 18-v6so923292pgn.4
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 02:25:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k15si5719283pgi.99.2018.11.09.02.25.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 02:25:01 -0800 (PST)
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
 <b51aae15-eb5d-47f0-1222-bfc1ef21e06c@I-love.SAKURA.ne.jp>
 <20181109095604.GC5321@dhcp22.suse.cz>
 <d8757554-45f4-1240-dc8a-0f918ae0e5f3@suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <9e17d033-b2ab-3edb-ae0b-90d4f713e55b@i-love.sakura.ne.jp>
Date: Fri, 9 Nov 2018 19:24:48 +0900
MIME-Version: 1.0
In-Reply-To: <d8757554-45f4-1240-dc8a-0f918ae0e5f3@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: Kyungtae Kim <kt0755@gmail.com>, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On 2018/11/09 19:10, Vlastimil Babka wrote:>>>> +	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
>>>> +	 * be using allocators in order of preference for an area that is
>>>> +	 * too large.
>>>> +	 */
>>>> +	if (order >= MAX_ORDER) {
>>>
>>> Also, why not to add BUG_ON(gfp_mask & __GFP_NOFAIL); here?
>>
>> Because we do not want to blow up the kernel just because of a stupid
>> usage of the allocator. Can you think of an example where it would
>> actually make any sense?
>>
>> I would argue that such a theoretical abuse would blow up on an
>> unchecked NULL ptr access. Isn't that enough?
> 
> Agreed.
> 

If someone has written a module with __GFP_NOFAIL for an architecture
where PAGE_SIZE == 2048KB, and someone else tried to use that module on
another architecture where PAGE_SIZE == 4KB. You are saying that
triggering NULL pointer dereference is a fault of that user's ignorance
about MM. You are saying that everyone knows internal of MM. Sad...
