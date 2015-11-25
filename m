Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 142FB6B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:08:15 -0500 (EST)
Received: by wmww144 with SMTP id w144so183917737wmw.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 07:08:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k18si35265380wjw.112.2015.11.25.07.08.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 07:08:13 -0800 (PST)
Subject: Re: [PATCH v2 3/9] mm, page_owner: convert page_owner_inited to
 static key
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-4-git-send-email-vbabka@suse.cz>
 <20151125145202.GL27283@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5655CEDB.3040205@suse.cz>
Date: Wed, 25 Nov 2015 16:08:11 +0100
MIME-Version: 1.0
In-Reply-To: <20151125145202.GL27283@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>

[+CC PeterZ]

On 11/25/2015 03:52 PM, Michal Hocko wrote:
> On Tue 24-11-15 13:36:15, Vlastimil Babka wrote:
>> CONFIG_PAGE_OWNER attempts to impose negligible runtime overhead when enabled
>> during compilation, but not actually enabled during runtime by boot param
>> page_owner=on. This overhead can be further reduced using the static key
>> mechanism, which this patch does.
> 
> Is this really worth doing?

Well, I assume that jump labels exist for a reason, and allocation hot paths are
sufficiently sensitive to be worth it? It's not an extra maintenance burden for
us anyway. Just a bit different content of the if () line.

> If we do not have jump labels then the check
> will be atomic rather than a simple access, so it would be more costly,
> no? Or am I missing something?

Well, atomic read is a simple READ_ONCE on x86_64. That excludes some compiler
optimizations, but it's not expensive for the CPU. The optimization would be
caching the value of the flag to a register, which would only potentially affect
multiple checks from the same function (and its inlines). Which doesn't happen
AFAIK, as it's just once in the allocation and once in the free path?

Now I admit I have no idea if there are architectures that don't support jump
labels *and* have an expensive atomic read, and whether we care?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
