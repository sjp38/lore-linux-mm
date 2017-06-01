Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4246B02F3
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 18:10:27 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id s33so2466671qtg.1
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 15:10:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k9si21161103qtk.235.2017.06.01.15.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 15:10:26 -0700 (PDT)
Date: Thu, 1 Jun 2017 15:10:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-Id: <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
In-Reply-To: <20170601132808.GD9091@dhcp22.suse.cz>
References: <1496317427-5640-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170601115936.GA9091@dhcp22.suse.cz>
	<201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
	<20170601132808.GD9091@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

On Thu, 1 Jun 2017 15:28:08 +0200 Michal Hocko <mhocko@suse.com> wrote:

> On Thu 01-06-17 22:11:13, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> > > > Cong Wang has reported a lockup when running LTP memcg_stress test [1].
> > >
> > > This seems to be on an old and not pristine kernel. Does it happen also
> > > on the vanilla up-to-date kernel?
> > 
> > 4.9 is not an old kernel! It might be close to the kernel version which
> > enterprise distributions would choose for their next long term supported
> > version.
> > 
> > And please stop saying "can you reproduce your problem with latest
> > linux-next (or at least latest linux)?" Not everybody can use the vanilla
> > up-to-date kernel!
> 
> The changelog mentioned that the source of stalls is not clear so this
> might be out-of-tree patches doing something wrong and dump_stack
> showing up just because it is called often. This wouldn't be the first
> time I have seen something like that. I am not really keen on adding
> heavy lifting for something that is not clearly debugged and based on
> hand waving and speculations.

I'm thinking we should serialize warn_alloc anyway, to prevent the
output from concurrent calls getting all jumbled together?

I'm not sure I buy the "this isn't a mainline kernel" thing. 
warn_alloc() obviously isn't very robust, but we'd prefer that it be
robust to peculiar situations, wild-n-wacky kernel patches, etc.  It's
a low-level thing and it should Just Work.

I do think ratelimiting will be OK - if the kernel is producing such a
vast stream of warn_alloc() output then nobody is going to be reading
it all anyway.  Probably just the first one is enough for operators to
understand what's going wrong.

So...  I think both.  ratelimit *and* serialize.  Perhaps a simple but
suitable way of doing that is simply to disallow concurrent warn_allocs:

	/* comment goes here */
	if (test_and_set_bit(0, &foo))
		return;
	...
	clear_bit(0, &foo);

or whatever?

(And if we do decide to go with "mm,page_alloc: Serialize warn_alloc()
if schedulable", please do add code comments explaining what's going on)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
