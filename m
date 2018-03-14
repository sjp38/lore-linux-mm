Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8093D6B000E
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 05:08:54 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id k4-v6so1181298pls.15
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 02:08:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m1-v6si1665525plk.318.2018.03.14.02.08.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Mar 2018 02:08:53 -0700 (PDT)
Date: Wed, 14 Mar 2018 10:08:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Hangs in balance_dirty_pages with arm-32 LPAE + highmem
Message-ID: <20180314090851.GG4811@dhcp22.suse.cz>
References: <b77a6596-3b35-84fe-b65b-43d2e43950b3@redhat.com>
 <20180226142839.GB16842@dhcp22.suse.cz>
 <4ba43bef-37f0-c21c-23a7-bbf696c926fd@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ba43bef-37f0-c21c-23a7-bbf696c926fd@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-block@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On Mon 05-03-18 13:04:24, Laura Abbott wrote:
> On 02/26/2018 06:28 AM, Michal Hocko wrote:
> > On Fri 23-02-18 11:51:41, Laura Abbott wrote:
> > > Hi,
> > > 
> > > The Fedora arm-32 build VMs have a somewhat long standing problem
> > > of hanging when running mkfs.ext4 with a bunch of processes stuck
> > > in D state. This has been seen as far back as 4.13 but is still
> > > present on 4.14:
> > > 
> > [...]
> > > This looks like everything is blocked on the writeback completing but
> > > the writeback has been throttled. According to the infra team, this problem
> > > is _not_ seen without LPAE (i.e. only 4G of RAM). I did see
> > > https://patchwork.kernel.org/patch/10201593/ but that doesn't seem to
> > > quite match since this seems to be completely stuck. Any suggestions to
> > > narrow the problem down?
> > 
> > How much dirtyable memory does the system have? We do allow only lowmem
> > to be dirtyable by default on 32b highmem systems. Maybe you have the
> > lowmem mostly consumed by the kernel memory. Have you tried to enable
> > highmem_is_dirtyable?
> > 
> 
> Setting highmem_is_dirtyable did fix the problem. The infrastructure
> people seemed satisfied enough with this (and are happy to have the
> machines back). I'll see if they are willing to run a few more tests
> to get some more state information.

Please be aware that highmem_is_dirtyable is not for free. There are
some code paths which can only allocate from lowmem (e.g. block device
AFAIR) and those could fill up the whole lowmem without any throttling.
-- 
Michal Hocko
SUSE Labs
