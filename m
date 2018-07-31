Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 814896B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 23:45:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y18-v6so799457wma.9
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 20:45:50 -0700 (PDT)
Received: from mail.nethype.de (mail.nethype.de. [5.9.56.24])
        by mx.google.com with ESMTPS id c81-v6si832282wmf.176.2018.07.30.20.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Jul 2018 20:45:49 -0700 (PDT)
Date: Tue, 31 Jul 2018 05:45:46 +0200
From: Marc Lehmann <schmorp@schmorp.de>
Subject: Re: post linux 4.4 vm oom kill, lockup and thrashing woes
Message-ID: <20180731034546.tro4gurwebmcpuqd@schmorp.de>
References: <20180710120755.3gmin4rogheqb3u5@schmorp.de>
 <20180710123222.GK14284@dhcp22.suse.cz>
 <20180717234549.4ng2expfkgaranuq@schmorp.de>
 <20180718083808.GR7193@dhcp22.suse.cz>
 <20180722233437.34e5ckq5pp24gsod@schmorp.de>
 <20180723125554.GE31229@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180723125554.GE31229@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On Mon, Jul 23, 2018 at 02:55:54PM +0200, Michal Hocko <mhocko@kernel.org> wrote:
> 
> Having more examples should help us to work with specific subsystems
> on a more appropriate fix. Depending on large order allocations has
> always been suboptimal if not outright wrong.

I think this is going into the wrong direction. First of all, keep in mind
that I have to actively work against getting more examples, as I have to keep
things running and will employ more and more workarounds.

More importantly, however, it's all good and well if the kernel fails
high order allocations when it has to, and it's all well to try to "fix"
them to not happen, but let's not forget the real problem, which is linux
thrashing, freezing or killing unrelated processes when it has no reason
to. specifically, if I have 32Gb ram and 30GB of page cache that isn't
locked, then linux has no conceivable reason to not satisfy even a high-order
allocation by moving some movable pages around.

I tzhink the examples I provides should already give some insight, for
example, doing a large mmap and faulting the pages in should not cause
these pages to be so stubbornly locked as to cause the machine to freeze
on a large alllocation, when it could "simply" drp a few gigabytes of
(non-dirty!) shared file pages instead.

It's possible that the post-4.4 vm changes are not the direct cause of this,
but only caused a hitherto unproblematic behaviour to cause problems e.g.
(totally made up) mmapped file data was freed in 4.4 simply because it tried
harder, and in post-4.4 kernels the kernel prefers to lock up instead. Then
the changes done in post-4.4 are not the cause of the problem, but simply the
trigger, just as the higher order allocations of some subsystems are not the
cause of the spurious oom kills, but simply the trigger.

Or, to put it bluntly, no matter how badly written kvm and/or the nvidia
subsystem,s are, the kernel has no business killing mysql on my boxes when
it has 95% of available memory. If this were by design, then linux should
have the ability of keeping memory free for suich uses (something like
min_free_kbytes) and not use memory for disk cache if this memory is then
lost to other applications.

And yes, if I see more "interesting" examples, I will of course tell you
about them :)

-- 
                The choice of a       Deliantra, the free code+content MORPG
      -----==-     _GNU_              http://www.deliantra.net
      ----==-- _       generation
      ---==---(_)__  __ ____  __      Marc Lehmann
      --==---/ / _ \/ // /\ \/ /      schmorp@schmorp.de
      -=====/_/_//_/\_,_/ /_/\_\
