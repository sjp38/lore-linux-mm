Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id E79C46B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 12:52:59 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id h97-v6so12871594lji.21
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 09:52:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v79-v6sor15244087lje.5.2018.10.22.09.52.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 09:52:57 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
Date: Mon, 22 Oct 2018 18:52:53 +0200
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181022165253.uphv3xzqivh44o3d@pc636>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022125142.GD18839@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

On Mon, Oct 22, 2018 at 02:51:42PM +0200, Michal Hocko wrote:
> Hi,
> I haven't read through the implementation yet but I have say that I
> really love this cover letter. It is clear on intetion, it covers design
> from high level enough to start discussion and provides a very nice
> testing coverage. Nice work!
> 
> I also think that we need a better performing vmalloc implementation
> long term because of the increasing number of kvmalloc users.
> 
> I just have two mostly workflow specific comments.
> 
> > A test-suite patch you can find here, it is based on 4.18 kernel.
> > ftp://vps418301.ovh.net/incoming/0001-mm-vmalloc-stress-test-suite-v4.18.patch
> 
> Can you fit this stress test into the standard self test machinery?
> 
If you mean "tools/testing/selftests", then i can fit that as a kernel module.
But not all the tests i can trigger from kernel module, because 3 of 8 tests
use __vmalloc_node_range() function that is not marked as EXPORT_SYMBOL.

> > It is fixed by second commit in this series. Please see more description in
> > the commit message of the patch.
> 
> Bug fixes should go first and new functionality should be built on top.
>
Thanks for the good point.

> A kernel crash sounds serious enough to have a fix marked for stable. If
> the fix is too hard/complex then we might consider a revert of the
> faulty commit.
>
The fix is straightforward and easy. It adds a threshold passing which we
forbid cond_resched_lock() and continue draining of lazy pages.

> >
> > 3) This one is related to PCPU allocator(see pcpu_alloc_test()). In that
> > stress test case i see that SUnreclaim(/proc/meminfo) parameter gets increased,
> > i.e. there is a memory leek somewhere in percpu allocator. It sounds like
> > a memory that is allocated by pcpu_get_vm_areas() sometimes is not freed.
> > Resulting in memory leaking or "Kernel panic":
> > 
> > ---[ end Kernel panic - not syncing: Out of memory and no killable processes...
> 
> It would be great to pin point this one down before the rework as well.
> 
Actually it has been fixed recently. Roman Gushchin pointed to the:

6685b357363b ("percpu: stop leaking bitmap metadata blocks")

i have checked, it works fine and fixes a leak i see.

Thank you!

--
Vlad Rezki

> Thanks a lot!
> -- 
> Michal Hocko
> SUSE Labs
