Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AED86B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 08:41:40 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s123-v6so11387290qkf.12
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 05:41:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a19-v6sor671633qkg.45.2018.10.12.05.41.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 05:41:39 -0700 (PDT)
Date: Fri, 12 Oct 2018 08:41:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
Message-ID: <20181012124137.GA29330@cmpxchg.org>
References: <000000000000dc48d40577d4a587@google.com>
 <20181010151135.25766-1-mhocko@kernel.org>
 <20181012112008.GA27955@cmpxchg.org>
 <20181012120858.GX5873@dhcp22.suse.cz>
 <9174f087-3f6f-f0ed-6009-509d4436a47a@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9174f087-3f6f-f0ed-6009-509d4436a47a@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 12, 2018 at 09:10:40PM +0900, Tetsuo Handa wrote:
> On 2018/10/12 21:08, Michal Hocko wrote:
> >> So not more than 10 dumps in each 5s interval. That looks reasonable
> >> to me. By the time it starts dropping data you have more than enough
> >> information to go on already.
> > 
> > Yeah. Unless we have a storm coming from many different cgroups in
> > parallel. But even then we have the allocation context for each OOM so
> > we are not losing everything. Should we ever tune this, it can be done
> > later with some explicit examples.
> > 
> >> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > Thanks! I will post the patch to Andrew early next week.
> > 
> 
> How do you handle environments where one dump takes e.g. 3 seconds?
> Counting delay between first message in previous dump and first message
> in next dump is not safe. Unless we count delay between last message
> in previous dump and first message in next dump, we cannot guarantee
> that the system won't lockup due to printk() flooding.

How is that different from any other printk ratelimiting? If a dump
takes 3 seconds you need to fix your console. It doesn't make sense to
design KERN_INFO messages for the slowest serial consoles out there.

That's what we did, btw. We used to patch out the OOM header because
our serial console was so bad, but obviously that's not a generic
upstream solution. We've since changed the loglevel on the serial and
use netconsole[1] for the chattier loglevels.

[1] https://github.com/facebook/fbkutils/tree/master/netconsd
