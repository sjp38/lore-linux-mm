Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D44DF6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 07:27:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h24so10167101pfh.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 04:27:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m65si40098253pfk.229.2016.10.19.04.27.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 04:27:54 -0700 (PDT)
Subject: Re: How to make warn_alloc() reliable?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201610182004.AEF87559.FOOHVLJOQFFtSM@I-love.SAKURA.ne.jp>
	<20161018122749.GE12092@dhcp22.suse.cz>
In-Reply-To: <20161018122749.GE12092@dhcp22.suse.cz>
Message-Id: <201610192027.GFB17670.VOtOLQFFOSMJHF@I-love.SAKURA.ne.jp>
Date: Wed, 19 Oct 2016 20:27:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> This is not about warn_alloc reliability but more about
> too_many_isolated waiting for an unbounded amount of time. And that
> should be fixed. I do not have a good idea how right now.

I'm not talking about only too_many_isolated() case. If I were talking about
this specific case, I would have proposed leaving this loop using timeout.
For example, where is the guarantee that current thread never get stuck
at shrink_inactive_list() after leaving this too_many_isolated() loop?

I think that perception of ordinary Linux user's memory management is
"Linux reclaims memory when needed. Thus, it is normal that MemFree:
field of /proc/meminfo is small." and "Linux invokes the OOM killer if
memory allocation request can't make forward progress". However we know
"Linux may not be able to invoke the OOM killer even if memory allocation
request can't make forward progress". You suddenly bring up (or admit to)
implications/limitations/problems most Linux users do not know. That's
painful for me who went to a lot of trouble to get some clue at a support
center.

When we were off-list talking about CVE-2016-2847, your response had been
"Your machine is DoSed already" until we notice the "too small to fail"
memory-allocation rule. If I were not continuing examining until I make
you angry, we would not have come to correct answer. I don't like your
optimistic "Fix it if you can trigger it." approach which will never give
users (and troubleshooting staffs at support centers) a proof. I want a
"Expose what Michal Hocko is not aware of or does not care" mechanism.

What I'm talking about is "why don't you stop playing whack-a-mole games
with missing warn_alloc() calls". I don't blame you for not having a good
idea, but I blame you for not having a reliable warn_alloc() mechanism.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
