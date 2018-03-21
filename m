Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE2B46B0008
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 17:24:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v3so3279596pfm.21
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:24:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t66si3689631pfk.215.2018.03.21.14.24.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 14:24:03 -0700 (PDT)
Date: Wed, 21 Mar 2018 22:23:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Message-ID: <20180321212355.GR23100@dhcp22.suse.cz>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321131449.GN23100@dhcp22.suse.cz>
 <8e0ded7b-4be4-fa25-f40c-d3116a6db4db@linux.alibaba.com>
 <cf87ade4-5a5c-3919-0fc6-acc40e12659b@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf87ade4-5a5c-3919-0fc6-acc40e12659b@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 21-03-18 10:16:41, Yang Shi wrote:
> 
> 
> On 3/21/18 9:50 AM, Yang Shi wrote:
> > 
> > 
> > On 3/21/18 6:14 AM, Michal Hocko wrote:
> > > On Wed 21-03-18 05:31:19, Yang Shi wrote:
> > > > When running some mmap/munmap scalability tests with large memory (i.e.
> > > > > 300GB), the below hung task issue may happen occasionally.
> > > > INFO: task ps:14018 blocked for more than 120 seconds.
> > > >         Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
> > > >   "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
> > > > message.
> > > >   ps              D    0 14018      1 0x00000004
> > > >    ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
> > > >    ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
> > > >    00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
> > > >   Call Trace:
> > > >    [<ffffffff817154d0>] ? __schedule+0x250/0x730
> > > >    [<ffffffff817159e6>] schedule+0x36/0x80
> > > >    [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
> > > >    [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
> > > >    [<ffffffff81717db0>] down_read+0x20/0x40
> > > >    [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
> > > Slightly off-topic:
> > > Btw. this sucks as well. Do we really need to take mmap_sem here? Do any
> > > of
> > >     arg_start = mm->arg_start;
> > >     arg_end = mm->arg_end;
> > >     env_start = mm->env_start;
> > >     env_end = mm->env_end;
> > > 
> > > change after exec or while the pid is already visible in proc? If yes
> > > maybe we can use a dedicated lock.
> 
> BTW, this is not the only place to acquire mmap_sem in
> proc_pid_cmdline_read(), it calls access_remote_vm() which need acquire
> mmap_sem too, so the mmap_sem scalability issue will be hit sooner or later.

Ohh, absolutely. mmap_sem is unfortunatelly abused and it would be great
to remove that. munmap should perform much better. How to do that safely
is a different question. I am not yet convinced that tearing down a vma
in batches is safe. The vast majority of time is spent on tearing down
pages and that is quite easy to move out of the write lock. That would
be an improvement already and it should be risk safe. If even that is
not sufficient then using range locking should help a lot. There
shouldn't be really any other address space operations within the range
most of the time so this would be basically non-contended access.
-- 
Michal Hocko
SUSE Labs
