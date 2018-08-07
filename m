Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDCE6B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 01:45:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t17-v6so4970752edr.21
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 22:45:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f6-v6si619389edt.166.2018.08.06.22.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 22:45:27 -0700 (PDT)
Date: Tue, 7 Aug 2018 07:45:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v6 PATCH 2/2] mm: mmap: zap pages with read mmap_sem in
 munmap
Message-ID: <20180807054524.GQ10003@dhcp22.suse.cz>
References: <1532628614-111702-1-git-send-email-yang.shi@linux.alibaba.com>
 <1532628614-111702-3-git-send-email-yang.shi@linux.alibaba.com>
 <20180803090759.GI27245@dhcp22.suse.cz>
 <aff7e86d-2e48-ff58-5d5d-9c67deb68674@linux.alibaba.com>
 <20180806094005.GG19540@dhcp22.suse.cz>
 <76c0fc2b-fca7-9f22-214a-920ee2537898@linux.alibaba.com>
 <20180806204119.GL10003@dhcp22.suse.cz>
 <28de768b-c740-37b3-ea5a-8e2cb07d2bdc@linux.alibaba.com>
 <20180806205232.GN10003@dhcp22.suse.cz>
 <0cdff13a-2713-c5be-a33e-28c07e093bcc@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0cdff13a-2713-c5be-a33e-28c07e093bcc@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 06-08-18 15:19:06, Yang Shi wrote:
> 
> 
> On 8/6/18 1:52 PM, Michal Hocko wrote:
> > On Mon 06-08-18 13:48:35, Yang Shi wrote:
> > > 
> > > On 8/6/18 1:41 PM, Michal Hocko wrote:
> > > > On Mon 06-08-18 09:46:30, Yang Shi wrote:
> > > > > On 8/6/18 2:40 AM, Michal Hocko wrote:
> > > > > > On Fri 03-08-18 14:01:58, Yang Shi wrote:
> > > > > > > On 8/3/18 2:07 AM, Michal Hocko wrote:
> > > > > > > > On Fri 27-07-18 02:10:14, Yang Shi wrote:
> > > > [...]
> > > > > > > > > If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, they are
> > > > > > > > > considered as special mappings. They will be dealt with before zapping
> > > > > > > > > pages with write mmap_sem held. Basically, just update vm_flags.
> > > > > > > > Well, I think it would be safer to simply fallback to the current
> > > > > > > > implementation with these mappings and deal with them on top. This would
> > > > > > > > make potential issues easier to bisect and partial reverts as well.
> > > > > > > Do you mean just call do_munmap()? It sounds ok. Although we may waste some
> > > > > > > cycles to repeat what has done, it sounds not too bad since those special
> > > > > > > mappings should be not very common.
> > > > > > VM_HUGETLB is quite spread. Especially for DB workloads.
> > > > > Wait a minute. In this way, it sounds we go back to my old implementation
> > > > > with special handling for those mappings with write mmap_sem held, right?
> > > > Yes, I would really start simple and add further enhacements on top.
> > > If updating vm_flags with read lock is safe in this case, we don't have to
> > > do this. The only reason for this special handling is about vm_flags update.
> > Yes, maybe you are right that this is safe. I would still argue to have
> > it in a separate patch for easier review, bisectability etc...
> 
> Sorry, I'm a little bit confused. Do you mean I should have the patch
> *without* handling the special case (just like to assume it is safe to
> update vm_flags with read lock), then have the other patch on top of it,
> which simply calls do_munmap() to deal with the special cases?

Just skip those special cases in the initial implementation and handle
each special case in its own patch on top.
-- 
Michal Hocko
SUSE Labs
