Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 617358E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 06:59:23 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c53so220426edc.9
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 03:59:23 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cg5-v6si13440792ejb.288.2019.01.07.03.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 03:59:21 -0800 (PST)
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
References: <20190107043227.GA3325@nautica>
 <151b4ac8-5cfc-ed30-db30-e4d67a324c4b@suse.cz>
 <20190107110827.GA15249@nautica>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <43f734de-2b1c-aa9f-d373-b95663e913dd@suse.cz>
Date: Mon, 7 Jan 2019 12:59:19 +0100
MIME-Version: 1.0
In-Reply-To: <20190107110827.GA15249@nautica>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, daniel@gruss.cc

On 1/7/19 12:08 PM, Dominique Martinet wrote:
>
> With the current mincore change, it will think everything was "in core"
> and not flush anything unless my option to just fadvise dontneed
> everything is passed though ; so even if we can make it work it is a
> change of behaviour that is breaking an existing application, and it has
> no way of telling it didn't work.

IIUC the current change is commit 574823bfab82 ("Change mincore() to count
"mapped" pages rather than "cached" pages") which will not pretend
everything
is "in core", but only pages that the calling process has populated page
table mapping for (which implies in core, but the opposite doesn't
hold). "nocache" most certainly doesn't populate the mappings before
calling mincore(), as that would bring pages to page cache and defeat
the purpose of determining if they were already there prior the nocache
execution. Instead it will think that nothing was "in core", and thus
later call fadvise dontneed or everything, but as I've said earlier that
shouldn't matter much.

> Honestly though, as I said, mincore() is much more useful for debugging
> for me ; the application can be changed if required. I just pointed it
> out as it'll need changing, and it has no obvious way of testing at
> runtime if the syscall works (except dumb kernel version check, but that
> won't work with stable backports); so it's not that obvious.

Agree.

>>> FWIW I personally don't care much about "only for owner" or depending on
>>> mmap options; I don't understand much of the security implications
>>> honestly so I'm not sure how these limitations actually help.
>>> On the other hand, a simple CAP_SYS_ADMIN check making the call take
>>> either behaviour should be safe and would cover what I described above.
>>
>> So without CAP_SYS_ADMIN, mincore() would return mapping status, and
>> with CAP_SYS_ADMIN, it would return cache residency status? Very clumsy
>> :( Maybe if we introduced mincore2() with flags similar to BSD mentioned
>> earlier in the thread, and the cache residency flag would require
>> CAP_SYS_ADMIN or something similar.
> 
> I agree, that's rather clumsy... Or rather might lead to some unexpected
> behaviours. I'm open to other ideas.
> I'm not sure how the BSD flags help though?

Definitely it would be a long-term solution, introducing new API,
waiting for userspace to use it... and meanwhile we would have to keep
the status quo or some kind of the clumsy/subtle approach.

>>> (by the way, while we are discussing permissions, a regular user can use
>>> fadvise dontneed on files it doesn't own as well as long as it can open
>>> them for reading; I'm not sure if that would need restricting as well in
>>> the context of the security issue.
>>
>> Probably not, as I've mentioned it won't evict what's mapped by somebody
>> else. And eviction is also possible via controlling LRU, which is what
>> the paper [1] does anyway (and also mentions that DONTNEED doesn't
>> work). Being able to evict somebody's page is AFAIU not sufficient for
>> attack, the side channel is about knowing that somebody brought that
>> page back to RAM by touching it.
> 
> Thanks for the link to the paper, I hadn't taken the time to extract it
> from the news article but it's much more interesting indeed.

It went public only this morning, the article was older :)
