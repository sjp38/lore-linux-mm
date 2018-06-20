Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 000596B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 08:21:35 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j82-v6so1688049oiy.18
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 05:21:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 38-v6si786155ots.143.2018.06.20.05.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 05:21:34 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180620115531.GL13685@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <f6e65320-d8d3-f1ff-0346-13d1446c2675@i-love.sakura.ne.jp>
Date: Wed, 20 Jun 2018 21:21:21 +0900
MIME-Version: 1.0
In-Reply-To: <20180620115531.GL13685@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On 2018/06/20 20:55, Michal Hocko wrote:
> On Wed 20-06-18 20:20:38, Tetsuo Handa wrote:
>> Sleeping with oom_lock held can cause AB-BA lockup bug because
>> __alloc_pages_may_oom() does not wait for oom_lock. Since
>> blocking_notifier_call_chain() in out_of_memory() might sleep, sleeping
>> with oom_lock held is currently an unavoidable problem.
> 
> Could you be more specific about the potential deadlock? Sleeping while
> holding oom lock is certainly not nice but I do not see how that would
> result in a deadlock assuming that the sleeping context doesn't sleep on
> the memory allocation obviously.

"A" is "owns oom_lock" and "B" is "owns CPU resources". It was demonstrated
at "mm,oom: Don't call schedule_timeout_killable() with oom_lock held." proposal.

But since you don't accept preserving the short sleep which is a heuristic for
reducing the possibility of AB-BA lockup, the only way we would accept will be
wait for the owner of oom_lock (e.g. by s/mutex_trylock/mutex_lock/ or whatever)
which is free of heuristic and free of AB-BA lockup.

> 
>> As a preparation for not to sleep with oom_lock held, this patch brings
>> OOM notifier callbacks to outside of OOM killer, with two small behavior
>> changes explained below.
> 
> Can we just eliminate this ugliness and remove it altogether? We do not
> have that many notifiers. Is there anything fundamental that would
> prevent us from moving them to shrinkers instead?
> 

For long term, it would be possible. But not within this patch. For example,
I think that virtio_balloon wants to release memory only when we have no
choice but OOM kill. If virtio_balloon trivially releases memory, it will
increase the risk of killing the entire guest by OOM-killer from the host
side.
