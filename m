Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA5918E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 05:08:54 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c34so4101618edb.8
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 02:08:54 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3-v6si2359215ejx.136.2019.01.10.02.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 02:08:53 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Jan 2019 11:08:52 +0100
From: Roman Penyaev <rpenyaev@suse.de>
Subject: Re: [RFC PATCH 03/15] mm/vmalloc: introduce new vrealloc() call and
 its subsidiary reach analog
In-Reply-To: <20190109165009.GM6310@bombadil.infradead.org>
References: <20190109164025.24554-1-rpenyaev@suse.de>
 <20190109164025.24554-4-rpenyaev@suse.de>
 <20190109165009.GM6310@bombadil.infradead.org>
Message-ID: <f9ee08f81b3c114b015643e1fca5b7a9@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2019-01-09 17:50, Matthew Wilcox wrote:
> On Wed, Jan 09, 2019 at 05:40:13PM +0100, Roman Penyaev wrote:
>> Basically vrealloc() repeats glibc realloc() with only one big 
>> difference:
>> old area is not freed, i.e. caller is responsible for calling vfree() 
>> in
>> case of successfull reallocation.
> 
> Ouch.  Don't call it the same thing when you're providing such 
> different
> semantics.  I agree with you that the new semantics are useful ones,
> I just want it called something else.  Maybe vcopy()?  vclone()?

vclone(). I like vclone().  But Linus does not like this reallocation
under the hood for epoll (where this vrealloc() should have been used),
so seems that won't be needed at all.

> 
>> + *	Do not forget to call vfree() passing old address.  But careful,
>> + *	calling vfree() from interrupt will cause vfree_deferred() call,
>> + *	which in its turn uses freed address as a temporal pointer for a
> 
> "temporary", not temporal.

Ha! Now I got the difference.  Thanks, Mathew :)

> 
>> + *	llist element, i.e. memory will be corrupted.

--
Roman
