Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id B69E26B0008
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 08:58:45 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id n186-v6so8255219oig.13
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 05:58:45 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s83-v6si531707oie.222.2018.10.12.05.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 05:58:44 -0700 (PDT)
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
References: <000000000000dc48d40577d4a587@google.com>
 <20181010151135.25766-1-mhocko@kernel.org>
 <20181012112008.GA27955@cmpxchg.org> <20181012120858.GX5873@dhcp22.suse.cz>
 <9174f087-3f6f-f0ed-6009-509d4436a47a@i-love.sakura.ne.jp>
 <20181012124137.GA29330@cmpxchg.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0417c888-d74e-b6ae-a8f0-234cbde03d38@i-love.sakura.ne.jp>
Date: Fri, 12 Oct 2018 21:58:19 +0900
MIME-Version: 1.0
In-Reply-To: <20181012124137.GA29330@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

Calling printk() people. ;-)

On 2018/10/12 21:41, Johannes Weiner wrote:
> On Fri, Oct 12, 2018 at 09:10:40PM +0900, Tetsuo Handa wrote:
>> On 2018/10/12 21:08, Michal Hocko wrote:
>>>> So not more than 10 dumps in each 5s interval. That looks reasonable
>>>> to me. By the time it starts dropping data you have more than enough
>>>> information to go on already.
>>>
>>> Yeah. Unless we have a storm coming from many different cgroups in
>>> parallel. But even then we have the allocation context for each OOM so
>>> we are not losing everything. Should we ever tune this, it can be done
>>> later with some explicit examples.
>>>
>>>> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>>>
>>> Thanks! I will post the patch to Andrew early next week.
>>>
>>
>> How do you handle environments where one dump takes e.g. 3 seconds?
>> Counting delay between first message in previous dump and first message
>> in next dump is not safe. Unless we count delay between last message
>> in previous dump and first message in next dump, we cannot guarantee
>> that the system won't lockup due to printk() flooding.
> 
> How is that different from any other printk ratelimiting? If a dump
> takes 3 seconds you need to fix your console. It doesn't make sense to
> design KERN_INFO messages for the slowest serial consoles out there.

You can't fix the console. It is a hardware limitation.

> 
> That's what we did, btw. We used to patch out the OOM header because
> our serial console was so bad, but obviously that's not a generic
> upstream solution. We've since changed the loglevel on the serial and
> use netconsole[1] for the chattier loglevels.
> 
> [1] https://github.com/facebook/fbkutils/tree/master/netconsd
> 
