Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id D909C6B0007
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 08:47:42 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id e197-v6so21492507ita.9
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 05:47:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z21-v6si6400757ioh.128.2018.10.15.05.47.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 05:47:41 -0700 (PDT)
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
References: <20181012112008.GA27955@cmpxchg.org>
 <20181012120858.GX5873@dhcp22.suse.cz>
 <9174f087-3f6f-f0ed-6009-509d4436a47a@i-love.sakura.ne.jp>
 <20181012124137.GA29330@cmpxchg.org>
 <0417c888-d74e-b6ae-a8f0-234cbde03d38@i-love.sakura.ne.jp>
 <bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp>
 <20181013112238.GA762@cmpxchg.org>
 <b61b2e60-d899-90c6-579a-587815cebff6@i-love.sakura.ne.jp>
 <20181015081934.GD18839@dhcp22.suse.cz>
 <ea637f9a-5dd0-f927-d26d-d0b4fd8ccb6f@i-love.sakura.ne.jp>
 <20181015112427.GI18839@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <6c0a57b3-bfd4-d832-b0bd-5dd3bcae460e@i-love.sakura.ne.jp>
Date: Mon, 15 Oct 2018 21:47:08 +0900
MIME-Version: 1.0
In-Reply-To: <20181015112427.GI18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On 2018/10/15 20:24, Michal Hocko wrote:
> On Mon 15-10-18 19:57:35, Tetsuo Handa wrote:
>> On 2018/10/15 17:19, Michal Hocko wrote:
>>> As so many dozens of times before, I will point you to an incremental
>>> nature of changes we really prefer in the mm land. We are also after a
>>> simplicity which your proposal lacks in many aspects. You seem to ignore
>>> that general approach and I have hard time to consider your NAK as a
>>> relevant feedback. Going to an extreme and basing a complex solution on
>>> it is not going to fly. No killable process should be a rare event which
>>> requires a seriously misconfigured memcg to happen so wildly. If you can
>>> trigger it with a normal user privileges then it would be a clear bug to
>>> address rather than work around with printk throttling.
>>>
>>
>> I can trigger 200+ times / 900+ lines / 69KB+ of needless OOM messages
>> with a normal user privileges. This is a lot of needless noise/delay.
> 
> I am pretty sure you have understood the part of my message you have
> chosen to not quote where I have said that the specific rate limitting
> decisions can be changed based on reasonable configurations. There is
> absolutely zero reason to NAK a natural decision to unify the throttling
> and cook a per-memcg way for a very specific path instead.
> 
>> No killable process is not a rare event, even without root privileges.
>>
>> [root@ccsecurity kumaneko]# time ./a.out
>> Killed
>>
>> real    0m2.396s
>> user    0m0.000s
>> sys     0m2.970s
>> [root@ccsecurity ~]# dmesg | grep 'no killable' | wc -l
>> 202
>> [root@ccsecurity ~]# dmesg | wc
>>     942    7335   70716
> 
> OK, so this is 70kB worth of data pushed throug the console. Is this
> really killing any machine?
> 

Nobody can prove that it never kills some machine. This is just one example result of
one example stress tried in my environment. Since I am secure programming man from security
subsystem, I really hate your "Can you trigger it?" resistance. Since this is OOM path
where nobody tests, starting from being prepared for the worst case keeps things simple.
