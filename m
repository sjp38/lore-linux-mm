Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 911AC8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 08:07:57 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id q11so69562otl.23
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 05:07:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q184si12098945oia.53.2019.01.07.05.07.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 05:07:56 -0800 (PST)
Subject: Re: [PATCH] memcg: killed threads should not invoke memcg OOM killer
References: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <f6d97ad3-ab04-f5e2-4822-96eac6ab45da@i-love.sakura.ne.jp>
 <20190107114139.GF31793@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <b0c4748e-f024-4d5c-a233-63c269660004@i-love.sakura.ne.jp>
Date: Mon, 7 Jan 2019 22:07:43 +0900
MIME-Version: 1.0
In-Reply-To: <20190107114139.GF31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Kirill Tkhai <ktkhai@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 2019/01/07 20:41, Michal Hocko wrote:
> On Sun 06-01-19 15:02:24, Tetsuo Handa wrote:
>> Michal and Johannes, can we please stop this stupid behavior now?
> 
> I have proposed a patch with a much more limited scope which is still
> waiting for feedback. I haven't heard it wouldn't be working so far.
> 

You mean

  mutex_lock_killable would take care of exiting task already. I would
  then still prefer to check for mark_oom_victim because that is not racy
  with the exit path clearing signals. I can update my patch to use
  _killable lock variant if we are really going with the memcg specific
  fix.

? No response for two months.

One memcg OOM killer kills all processes in that memcg is broken. What is
the race you are referring by "racy with the exit path clearing signals" ?
You are saying that a thread between clearing fatal signal and setting
PF_EXITING can invoke the memcg OOM killer again, aren't you? But how likely
is that? Even if it can happen, your patch can call mark_oom_victim() even
if my patch bailed out upon SIGKILL. That is, your patch and my patch are
not conflicting/exclusive.
