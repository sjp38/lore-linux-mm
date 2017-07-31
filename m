Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDBC6B05D9
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 04:37:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o201so20017082wmg.3
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 01:37:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e12si13460562wrd.321.2017.07.31.01.37.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 01:37:27 -0700 (PDT)
Date: Mon, 31 Jul 2017 10:37:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't zero ballooned pages
Message-ID: <20170731083724.GF15767@dhcp22.suse.cz>
References: <1501474413-21580-1-git-send-email-wei.w.wang@intel.com>
 <20170731065508.GE13036@dhcp22.suse.cz>
 <597EDF3D.8020101@intel.com>
 <20170731075153.GD15767@dhcp22.suse.cz>
 <32d9c53d-5310-25a7-0348-a6cf362a5dcd@youruncloud.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <32d9c53d-5310-25a7-0348-a6cf362a5dcd@youruncloud.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ZhenweiPi <zhenwei.pi@youruncloud.com>
Cc: Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mst@redhat.com, mawilcox@microsoft.com, dave.hansen@intel.com, akpm@linux-foundation.org

On Mon 31-07-17 16:23:26, ZhenweiPi wrote:
> On 07/31/2017 03:51 PM, Michal Hocko wrote:
> 
> >On Mon 31-07-17 15:41:49, Wei Wang wrote:
> >>>On 07/31/2017 02:55 PM, Michal Hocko wrote:
> >>>> >On Mon 31-07-17 12:13:33, Wei Wang wrote:
> >>>>> >>Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
> >>>>> >>shouldn't be given to the host ksmd to scan.
> >>>> >Could you point me where this MADV_DONTNEED is done, please?
> >>>
> >>>Sure. It's done in the hypervisor when the balloon pages are received.
> >>>
> >>>Please see line 40 at
> >>>https://github.com/qemu/qemu/blob/master/hw/virtio/virtio-balloon.c
> >And one more thing. I am not familiar with ksm much. But how is
> >MADV_DONTNEED even helping? This madvise is not sticky - aka it will
> >unmap the range without leaving any note behind. AFAICS the only way
> >to have vma scanned is to have VM_MERGEABLE and that is an opt in:
> >See Documentation/vm/ksm.txt
> >"
> >KSM only operates on those areas of address space which an application
> >has advised to be likely candidates for merging, by using the madvise(2)
> >system call: int madvise(addr, length, MADV_MERGEABLE).
> >"
> >
> >So what exactly is going on here? The original patch looks highly
> >suspicious as well. If somebody wants to make that memory mergable then
> >the user of that memory should zero them out.
> 
> Kernel starts a kthread named "ksmd". ksmd scans the VM_MERGEABLE
> memory, and merge the same pages.(same page means memcmp(page1,
> page2, PAGESIZE) == 0).
> 
> Guest can not use ballooned pages, and these pages will not be accessed
> in a long time. Kswapd on host will swap these pages out and get more
> free memory.
> 
> Rather than swapping, KSM has better performence.  Presently pages in
> the balloon device have random value,  they usually cannot be merged.
> So enqueue zero pages will resolve this problem.
> 
> Because MADV_DONTNEED depends on host os capability and hypervisor capability,
> I prefer to enqueue zero pages to balloon device and made this patch.

So why exactly are we zeroying pages (and pay some cost for that) in
guest when we do not know what host actually does with them?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
