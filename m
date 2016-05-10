Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B50CF6B0253
	for <linux-mm@kvack.org>; Tue, 10 May 2016 08:30:21 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so13032325wme.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 05:30:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k79si31660045wmc.55.2016.05.10.05.30.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 05:30:20 -0700 (PDT)
Subject: Re: [RFC 02/13] mm, page_alloc: set alloc_flags only once in slowpath
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-3-git-send-email-vbabka@suse.cz>
 <201605102028.AAC26596.SMHOQOtLOFFFVJ@I-love.SAKURA.ne.jp>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5731D453.8050104@suse.cz>
Date: Tue, 10 May 2016 14:30:11 +0200
MIME-Version: 1.0
In-Reply-To: <201605102028.AAC26596.SMHOQOtLOFFFVJ@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, rientjes@google.com, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On 05/10/2016 01:28 PM, Tetsuo Handa wrote:
> Vlastimil Babka wrote:
>> In __alloc_pages_slowpath(), alloc_flags doesn't change after it's initialized,
>> so move the initialization above the retry: label. Also make the comment above
>> the initialization more descriptive.
> 
> Not true. gfp_to_alloc_flags() will include ALLOC_NO_WATERMARKS if current
> thread got TIF_MEMDIE after gfp_to_alloc_flags() was called for the first

Oh, right. Stupid global state.

> time. Do you want to make TIF_MEMDIE threads fail their allocations without
> using memory reserves?

No, thanks for catching this. How about the following version? I think
that's even nicer cleanup, if correct. Note it causes a conflict in
patch 03/13 but it's simple to resolve.

Thanks

----8<----
