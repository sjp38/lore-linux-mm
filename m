Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93C6E8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:14:01 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id q16so19492214ios.1
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 01:14:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x64sor47271743iof.102.2019.01.14.01.14.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 01:14:00 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-4-git-send-email-kernelfans@gmail.com> <20190114075113.GB1973@rapoport-lnx>
 <CAFgQCTtN4CGFz5xf+uci1ow032oQMB5pExHG01EtgrOpqXrJKA@mail.gmail.com> <20190114085037.GC1973@rapoport-lnx>
In-Reply-To: <20190114085037.GC1973@rapoport-lnx>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 14 Jan 2019 17:13:48 +0800
Message-ID: <CAFgQCTtKO445m9rq+cxuX2PqBW4uTNh=62ETFt7zVQGCZ4RaXA@mail.gmail.com>
Subject: Re: [PATCHv2 3/7] mm/memblock: introduce allocation boundary for
 tracing purpose
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On Mon, Jan 14, 2019 at 4:50 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Mon, Jan 14, 2019 at 04:33:50PM +0800, Pingfan Liu wrote:
> > On Mon, Jan 14, 2019 at 3:51 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > >
> > > Hi Pingfan,
> > >
> > > On Fri, Jan 11, 2019 at 01:12:53PM +0800, Pingfan Liu wrote:
> > > > During boot time, there is requirement to tell whether a series of func
> > > > call will consume memory or not. For some reason, a temporary memory
> > > > resource can be loan to those func through memblock allocator, but at a
> > > > check point, all of the loan memory should be turned back.
> > > > A typical using style:
> > > >  -1. find a usable range by memblock_find_in_range(), said, [A,B]
> > > >  -2. before calling a series of func, memblock_set_current_limit(A,B,true)
> > > >  -3. call funcs
> > > >  -4. memblock_find_in_range(A,B,B-A,1), if failed, then some memory is not
> > > >      turned back.
> > > >  -5. reset the original limit
> > > >
> > > > E.g. in the case of hotmovable memory, some acpi routines should be called,
> > > > and they are not allowed to own some movable memory. Although at present
> > > > these functions do not consume memory, but later, if changed without
> > > > awareness, they may do. With the above method, the allocation can be
> > > > detected, and pr_warn() to ask people to resolve it.
> > >
> > > To ensure there were that a sequence of function calls didn't create new
> > > memblock allocations you can simply check the number of the reserved
> > > regions before and after that sequence.
> > >
> > Yes, thank you point out it.
> >
> > > Still, I'm not sure it would be practical to try tracking what code that's called
> > > from x86::setup_arch() did memory allocation.
> > > Probably a better approach is to verify no memory ended up in the movable
> > > areas after their extents are known.
> > >
> > It is a probability problem whether allocated memory sit on hotmovable
> > memory or not. And if warning based on the verification, then it is
> > also a probability problem and maybe we will miss it.
>
> I'm not sure I'm following you here.
>
> After the hotmovable memory configuration is detected it is possible to
> traverse reserved memblock areas and warn if some of them reside in the
> hotmovable memory.
>
Oh, sorry that I did not explain it accurately. Let use say a machine
with nodeA/B/C from low to high memory address. With top-down
allocation by default, at this point, memory will always be allocated
from nodeC. But it depends on machine whether nodeC is hotmovable or
not. The verification can pass on a machine with unmovable nodeC , but
fails on a machine with movable nodeC. It will be a probability issue.

Thanks

[...]
