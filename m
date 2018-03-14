Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1D7E6B000E
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 05:12:43 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f59-v6so1184024plb.7
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 02:12:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f12-v6si1661997plo.91.2018.03.14.02.12.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Mar 2018 02:12:42 -0700 (PDT)
Date: Wed, 14 Mar 2018 10:12:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Hangs in balance_dirty_pages with arm-32 LPAE + highmem
Message-ID: <20180314091240.GH4811@dhcp22.suse.cz>
References: <b77a6596-3b35-84fe-b65b-43d2e43950b3@redhat.com>
 <20180226142839.GB16842@dhcp22.suse.cz>
 <4ba43bef-37f0-c21c-23a7-bbf696c926fd@redhat.com>
 <201803062028.ECG56737.OHOFVFQFtOMSJL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803062028.ECG56737.OHOFVFQFtOMSJL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: labbott@redhat.com, dchinner@redhat.com, linux-mm@kvack.org, linux-block@vger.kernel.org

On Tue 06-03-18 20:28:59, Tetsuo Handa wrote:
> Laura Abbott wrote:
> > On 02/26/2018 06:28 AM, Michal Hocko wrote:
> > > On Fri 23-02-18 11:51:41, Laura Abbott wrote:
> > >> Hi,
> > >>
> > >> The Fedora arm-32 build VMs have a somewhat long standing problem
> > >> of hanging when running mkfs.ext4 with a bunch of processes stuck
> > >> in D state. This has been seen as far back as 4.13 but is still
> > >> present on 4.14:
> > >>
> > > [...]
> > >> This looks like everything is blocked on the writeback completing but
> > >> the writeback has been throttled. According to the infra team, this problem
> > >> is _not_ seen without LPAE (i.e. only 4G of RAM). I did see
> > >> https://patchwork.kernel.org/patch/10201593/ but that doesn't seem to
> > >> quite match since this seems to be completely stuck. Any suggestions to
> > >> narrow the problem down?
> > > 
> > > How much dirtyable memory does the system have? We do allow only lowmem
> > > to be dirtyable by default on 32b highmem systems. Maybe you have the
> > > lowmem mostly consumed by the kernel memory. Have you tried to enable
> > > highmem_is_dirtyable?
> > > 
> > 
> > Setting highmem_is_dirtyable did fix the problem. The infrastructure
> > people seemed satisfied enough with this (and are happy to have the
> > machines back).
> 
> That's good.
> 
> >                 I'll see if they are willing to run a few more tests
> > to get some more state information.
> 
> Well, I'm far from understanding what is happening in your case, but I'm
> interested in other threads which were trying to allocate memory. Therefore,
> I appreciate if they can take SysRq-m + SysRq-t than SysRq-w (as described
> at http://akari.osdn.jp/capturing-kernel-messages.html ).
> 
> Code which assumes that kswapd can make progress can get stuck when kswapd
> is blocked somewhere. And wbt_wait() seems to change behavior based on
> current_is_kswapd(). If everyone is waiting for kswapd but kswapd cannot
> make progress, I worry that it leads to hangups like your case.

Tetsuo, could you stop this finally, pretty please? This is a
well known limitation of 32b architectures with more than 4G. The lowmem
can only handle 896MB of memory and that can be filled up with other
kernel allocations. Stalled writeback is _usually_ a result of only
little dirtyable memory which is left in the lowmem. We cannot simply
allow highmem to be dirtyable by default due to reasons explained in
other email.

I can imagine that it is hard for you to grasp that not everything is
"silent hang during OOM" but there are other things going on in the VM.
-- 
Michal Hocko
SUSE Labs
