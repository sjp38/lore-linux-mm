Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9F866B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:42:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id h12-v6so10637871pls.23
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 10:42:43 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0095.outbound.protection.outlook.com. [104.47.42.95])
        by mx.google.com with ESMTPS id z20-v6si12514955plo.462.2018.04.16.10.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 10:42:42 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 17:42:38 +0000
Message-ID: <20180416174236.GL2341@sasha-vm>
References: <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416122019.1c175925@gandalf.local.home>
 <20180416162757.GB2341@sasha-vm> <20180416163952.GA8740@amd>
 <20180416164310.GF2341@sasha-vm> <20180416125307.0c4f6f28@gandalf.local.home>
 <20180416170936.GI2341@sasha-vm> <20180416133321.40a166a4@gandalf.local.home>
In-Reply-To: <20180416133321.40a166a4@gandalf.local.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <9262C86D82ADEB48ACEB473174B565E2@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, Apr 16, 2018 at 01:33:21PM -0400, Steven Rostedt wrote:
>On Mon, 16 Apr 2018 17:09:38 +0000
>Sasha Levin <Alexander.Levin@microsoft.com> wrote:
>
>> Let's play a "be the -stable maintainer" game. Would you take any
>> of the following commits?
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/=
commit?id=3Dfc90441e728aa461a8ed1cfede08b0b9efef43fb
>
>No, not automatically, or without someone from KVM letting me know what
>side-effects that may have. Not stopping on a breakpoint is not that
>critical, it may be a bit annoying. I would ask the KVM maintainers if
>they feel it's critical enough for backporting, but without hearing
>from them, I would leave it be.

Fair enough.

>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/=
commit?id=3Da918d2bcea6aab6e671bfb0901cbecc3cf68fca1
>
>Sure. Even if it has a subtle regression, that's a critical bug being
>fixed.

This was later reverted, in -stable:

"""
Commit d63c7dd5bcb9 ("ipr: Fix out-of-bounds null overwrite") removed
the end of line handling when storing the update_fw sysfs attribute.
This changed the userpace API because it started refusing writes
terminated by a line feed, which broke the update tools we already have.
"""

>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/=
commit?id=3Db1999fa6e8145305a6c8bda30ea20783717708e6
>
>I would consider unlocking a mutex that one didn't lock a critical bug,
>so yes.
>
>Again, things that deal with locking or buffer overflows, I would take
>the fix, as those are critical. But other behavior issues where it's
>not critical, I would leave be unless told further by someone else.

This too, was reverted:

"""
It causes run-time breakage in the 4.4-stable tree and more patches are
needed to be applied first before this one in order to resolve the
issue.
"""

This is how fun it is reviewing AUTOSEL commits :)

Even the small "trivial", "obviously correct" patches have room for
errors for various reasons.

Also note that all of these patches were tagged for stable and actually
ended up in at least one tree.

This is why I'm basing a lot of my decision making on the rejection rate.
If the AUTOSEL process does the job well enough as the "regular"
process did before, why push it back?=
