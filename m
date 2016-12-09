Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 48F8F6B0261
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 11:42:26 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id h201so19815945qke.7
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 08:42:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o190si20479398qkc.203.2016.12.09.08.42.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 08:42:25 -0800 (PST)
Date: Fri, 9 Dec 2016 17:42:22 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
 fast (de)inflating & fast live migration
Message-ID: <20161209164222.GI28786@redhat.com>
References: <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
 <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
 <2171e091-46ee-decd-7348-772555d3a5e3@redhat.com>
 <d3ff453c-56fa-19de-317c-1c82456f2831@intel.com>
 <20161207183817.GE28786@redhat.com>
 <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
 <20161207202824.GH28786@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A14E2AD@SHSMSX104.ccr.corp.intel.com>
 <060287c7-d1af-45d5-70ea-ad35d4bbeb84@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A14E339@SHSMSX104.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3A14E339@SHSMSX104.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

Hello,

On Fri, Dec 09, 2016 at 05:35:45AM +0000, Li, Liang Z wrote:
> > On 12/08/2016 08:45 PM, Li, Liang Z wrote:
> > > What's the conclusion of your discussion? It seems you want some
> > > statistic before deciding whether to  ripping the bitmap from the ABI,
> > > am I right?
> > 
> > I think Andrea and David feel pretty strongly that we should remove the
> > bitmap, unless we have some data to support keeping it.  I don't feel as
> > strongly about it, but I think their critique of it is pretty valid.  I think the
> > consensus is that the bitmap needs to go.
> > 
> 
> Thanks for you clarification.
> 
> > The only real question IMNHO is whether we should do a power-of-2 or a
> > length.  But, if we have 12 bits, then the argument for doing length is pretty
> > strong.  We don't need anywhere near 12 bits if doing power-of-2.
> > 
> So each item can max represent 16MB Bytes, seems not big enough,
> but enough for most case.
> Things became much more simple without the bitmap, and I like simple solution too. :)
> 
> I will prepare the v6 and remove all the bitmap related stuffs. Thank you all!

Sounds great!

I suggested to check the statistics, because collecting those stats
looked simpler and quicker than removing all bitmap related stuff from
the patchset. However if you prefer to prepare a v6 without the bitmap
another perhaps more interesting way to evaluate the usefulness of the
bitmap is to just run the same benchmark and verify that there is no
regression compared to the bitmap enabled code.

The other issue with the bitmap is, the best case for the bitmap is
ever less likely to materialize the more RAM is added to the guest. It
won't regress linearly because after all there can be some locality
bias in the buddy splits, but if sync compaction is used in the large
order allocations tried before reaching order 0, the bitmap payoff
will regress close to linearly with the increase of RAM.

So it'd be good to check the stats or the benchmark on large guests,
at least one hundred gigabytes or so.

Changing topic but still about the ABI features needed, so it may be
relevant for this discussion:

1) vNUMA locality: i.e. allowing host to specify which vNODEs to take
   memory from, using alloc_pages_node in guest. So you can ask to
   take X pages from vnode A, Y pages from vnode B, in one vmenter.

2) allowing qemu to tell the guest to stop inflating the balloon and
   report a fragmentation limit being hit, when sync compaction
   powered allocations fails at certain power-of-two order granularity
   passed by qemu to the guest. This order constraint will be passed
   by default for hugetlbfs guests with 2MB hpage size, while it can
   be used optionally on THP backed guests. This option with THP
   guests would allow a highlevel management software to provide a
   "don't reduce guest performance" while shrinking the memory size of
   the guest from the GUI. If you deselect the option, you can shrink
   down to the last freeable 4k guest page, but doing so may have to
   split THP in the host (you don't know for sure if they were really
   THP but they could have been), and it may regress
   performance. Inflating the balloon while passing a minimum
   granularity "order" of the pages being zapped, will guarantee
   inflating the balloon cannot decrease guest performance
   instead. Plus it's needed for hugetlbfs anyway as far as I can
   tell. hugetlbfs would not be host enforceable even if the idea is
   not to free memory but only reduce the available memory of the
   guest (not without major changes that maps a hugetlb page with 4k
   ptes at least). While for a more cooperative usage of hugetlbfs
   guests, it's simply not useful to inflate the balloon at anything
   less than the "HPAGE_SIZE" hugetlbfs granularity.

We also plan to use userfaultfd to make the balloon driver host
enforced (will work fine on hugetlbfs 2M and tmpfs too) but that's
going to be invisible to the ABI so it's not strictly relevant for
this discussion.

On a side note, registering userfaultfd on the ballooned range, will
keep khugepaged at bay so it won't risk to re-inflating the
MADV_DONTNEED zapped sub-THP fragments no matter the sysfs tunings.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
