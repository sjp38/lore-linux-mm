Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF036B007B
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:26:35 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id f15so33711501lbj.5
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 15:26:34 -0800 (PST)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id e5si8809060lae.71.2015.01.29.15.26.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 15:26:33 -0800 (PST)
Received: by mail-lb0-f177.google.com with SMTP id p9so33692914lbv.8
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 15:26:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150129081643.GK25850@nuc-i3427.alporthouse.com>
References: <CAPM=9tyyP_pKpWjc7LBZU7e6wAt26XGZsyhRh7N497B2+28rrQ@mail.gmail.com>
	<20150128084852.GC28132@nuc-i3427.alporthouse.com>
	<20150128143242.GF6542@dhcp22.suse.cz>
	<20150129081643.GK25850@nuc-i3427.alporthouse.com>
Date: Fri, 30 Jan 2015 09:26:32 +1000
Message-ID: <CAPM=9tyy0QWT_TGNKQmXc25_wGd81SPA9JNnAv8_297B6fGvkg@mail.gmail.com>
Subject: Re: [Intel-gfx] memcontrol.c BUG
From: Dave Airlie <airlied@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, Michal Hocko <mhocko@suse.cz>, Dave Airlie <airlied@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Jet Chen <jet.chen@intel.com>, Felipe Balbi <balbi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 29 January 2015 at 18:16, Chris Wilson <chris@chris-wilson.co.uk> wrote:
> On Wed, Jan 28, 2015 at 03:32:43PM +0100, Michal Hocko wrote:
>> On Wed 28-01-15 08:48:52, Chris Wilson wrote:
>> > On Wed, Jan 28, 2015 at 08:13:06AM +1000, Dave Airlie wrote:
>> > > https://bugzilla.redhat.com/show_bug.cgi?id=1165369
>> > >
>> > > ov 18 09:23:22 elissa.gathman.org kernel: page:f5e36a40 count:2
>> > > mapcount:0 mapping:  (null) index:0x0
>> > > Nov 18 09:23:22 elissa.gathman.org kernel: page flags:
>> > > 0x80090029(locked|uptodate|lru|swapcache|swapbacked)
>> > > Nov 18 09:23:22 elissa.gathman.org kernel: page dumped because:
>> > > VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage))
>> > > Nov 18 09:23:23 elissa.gathman.org kernel: ------------[ cut here ]------------
>> > > Nov 18 09:23:23 elissa.gathman.org kernel: kernel BUG at mm/memcontrol.c:6733!
>>
>> I guess this matches the following bugon in your kernel:
>>         VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage), oldpage);
>>
>> so the oldpage is on the LRU list already. I am completely unfamiliar
>> with 965GM but is the page perhaps shared with somebody with a different
>> gfp mask requirement (e.g. userspace accessing the memory via mmap)? So
>> the other (racing) caller didn't need to move the page and put it on
>> LRU.
>
> Generally, yes. The shmemfs filp is exported through a vm_mmap() as well
> as pinned into the GPU via shmem_read_mapping_page_gfp(). But I would
> not expect that to be the case very often, if at all, on 965GM as the
> two access paths are incoherent. Still it sounds promising, hopefully
> Dave can put it into a fedora kernel for testing?

http://kojipkgs.fedoraproject.org/scratch/airlied/task_8760024/

done, also asked on the bug for testers.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
