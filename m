Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFC26B0563
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 11:38:57 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o65so9127897qkl.12
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 08:38:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x184si25823307qke.29.2017.08.01.08.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 08:38:56 -0700 (PDT)
Date: Tue, 1 Aug 2017 18:38:54 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] mm: don't zero ballooned pages
Message-ID: <20170801183518-mutt-send-email-mst@kernel.org>
References: <1501474413-21580-1-git-send-email-wei.w.wang@intel.com>
 <20170731065508.GE13036@dhcp22.suse.cz>
 <597EDF3D.8020101@intel.com>
 <20170731075153.GD15767@dhcp22.suse.cz>
 <32d9c53d-5310-25a7-0348-a6cf362a5dcd@youruncloud.com>
 <20170731083724.GF15767@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731083724.GF15767@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: ZhenweiPi <zhenwei.pi@youruncloud.com>, Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mawilcox@microsoft.com, dave.hansen@intel.com, akpm@linux-foundation.org

On Mon, Jul 31, 2017 at 10:37:24AM +0200, Michal Hocko wrote:
> On Mon 31-07-17 16:23:26, ZhenweiPi wrote:
> > On 07/31/2017 03:51 PM, Michal Hocko wrote:
> > 
> > >On Mon 31-07-17 15:41:49, Wei Wang wrote:
> > >>>On 07/31/2017 02:55 PM, Michal Hocko wrote:
> > >>>> >On Mon 31-07-17 12:13:33, Wei Wang wrote:
> > >>>>> >>Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
> > >>>>> >>shouldn't be given to the host ksmd to scan.
> > >>>> >Could you point me where this MADV_DONTNEED is done, please?
> > >>>
> > >>>Sure. It's done in the hypervisor when the balloon pages are received.
> > >>>
> > >>>Please see line 40 at
> > >>>https://github.com/qemu/qemu/blob/master/hw/virtio/virtio-balloon.c
> > >And one more thing. I am not familiar with ksm much. But how is
> > >MADV_DONTNEED even helping? This madvise is not sticky - aka it will
> > >unmap the range without leaving any note behind. AFAICS the only way
> > >to have vma scanned is to have VM_MERGEABLE and that is an opt in:
> > >See Documentation/vm/ksm.txt
> > >"
> > >KSM only operates on those areas of address space which an application
> > >has advised to be likely candidates for merging, by using the madvise(2)
> > >system call: int madvise(addr, length, MADV_MERGEABLE).
> > >"
> > >
> > >So what exactly is going on here? The original patch looks highly
> > >suspicious as well. If somebody wants to make that memory mergable then
> > >the user of that memory should zero them out.
> > 
> > Kernel starts a kthread named "ksmd". ksmd scans the VM_MERGEABLE
> > memory, and merge the same pages.(same page means memcmp(page1,
> > page2, PAGESIZE) == 0).
> > 
> > Guest can not use ballooned pages, and these pages will not be accessed
> > in a long time. Kswapd on host will swap these pages out and get more
> > free memory.
> > 
> > Rather than swapping, KSM has better performence.  Presently pages in
> > the balloon device have random value,  they usually cannot be merged.
> > So enqueue zero pages will resolve this problem.
> > 
> > Because MADV_DONTNEED depends on host os capability and hypervisor capability,
> > I prefer to enqueue zero pages to balloon device and made this patch.

I think you should have hypervisor zero them out if it wants to then. Seems cleaner.

> 
> So why exactly are we zeroying pages (and pay some cost for that) in
> guest when we do not know what host actually does with them?

I suspect this is some special hypervisor that somehow benefits from
this patch. It should just use a feature bit for its special needs
I think.

Michal is also exactly right that patches like this should come
with some performance numbers.
I'll post a patch adding virtio lists for mm/balloon_compaction.c
so that we notice when people tweak it like that.

> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
