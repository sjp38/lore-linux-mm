Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2CF6B000C
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 08:11:04 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id r68-v6so8012795oie.12
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 05:11:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 187-v6si496406oig.55.2018.10.12.05.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 05:11:03 -0700 (PDT)
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
References: <000000000000dc48d40577d4a587@google.com>
 <20181010151135.25766-1-mhocko@kernel.org>
 <20181012112008.GA27955@cmpxchg.org> <20181012120858.GX5873@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <9174f087-3f6f-f0ed-6009-509d4436a47a@i-love.sakura.ne.jp>
Date: Fri, 12 Oct 2018 21:10:40 +0900
MIME-Version: 1.0
In-Reply-To: <20181012120858.GX5873@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>

On 2018/10/12 21:08, Michal Hocko wrote:
>> So not more than 10 dumps in each 5s interval. That looks reasonable
>> to me. By the time it starts dropping data you have more than enough
>> information to go on already.
> 
> Yeah. Unless we have a storm coming from many different cgroups in
> parallel. But even then we have the allocation context for each OOM so
> we are not losing everything. Should we ever tune this, it can be done
> later with some explicit examples.
> 
>> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Thanks! I will post the patch to Andrew early next week.
> 

How do you handle environments where one dump takes e.g. 3 seconds?
Counting delay between first message in previous dump and first message
in next dump is not safe. Unless we count delay between last message
in previous dump and first message in next dump, we cannot guarantee
that the system won't lockup due to printk() flooding.
