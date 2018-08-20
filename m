Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 22E0E6B1B56
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 18:03:33 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h17-v6so962168itj.0
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 15:03:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f11-v6si546921itf.129.2018.08.20.15.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 15:03:31 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
References: <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com>
 <20180810090735.GY1644@dhcp22.suse.cz>
 <be42a7c0-015e-2992-a40d-20af21e8c0fc@i-love.sakura.ne.jp>
 <20180810111604.GA1644@dhcp22.suse.cz>
 <d9595c92-6763-35cb-b989-0848cf626cb9@i-love.sakura.ne.jp>
 <20180814113359.GF32645@dhcp22.suse.cz>
 <49a73f8a-a472-a464-f5bf-ebd7994ce2d3@i-love.sakura.ne.jp>
 <20180820055417.GA29735@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <d5be452a-951f-ddc9-e7df-102d292f22c2@i-love.sakura.ne.jp>
Date: Tue, 21 Aug 2018 07:03:10 +0900
MIME-Version: 1.0
In-Reply-To: <20180820055417.GA29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 2018/08/20 14:54, Michal Hocko wrote:
>>>> Apart from the former is "sequential processing" and "the OOM reaper pays the cost
>>>> for reclaiming" while the latter is "parallel (or round-robin) processing" and "the
>>>> allocating thread pays the cost for reclaiming", both are timeout based back off
>>>> with number of retry attempt with a cap.
>>>
>>> And it is exactly the who pays the price concern I've already tried to
>>> explain that bothers me.
>>
>> Are you aware that we can fall into situation where nobody can pay the price for
>> reclaiming memory?
> 
> I fail to see how this is related to direct vs. kthread oom reaping
> though. Unless the kthread is starved by other means then it can always
> jump in and handle the situation.

I'm saying that concurrent allocators can starve the OOM reaper kernel thread.
I don't care if the OOM reaper kernel thread is starved by something other than
concurrent allocators, as long as that something is doing useful things.

Allocators wait for progress using (almost) busy loop is prone to lockup; they are
not doing useful things. But direct OOM reaping allows allocators avoid lockup and
do useful things.
