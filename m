Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6DDD6B025F
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:48:59 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a66so112387151qkg.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:48:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o94si2764096qge.94.2016.04.27.08.48.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 08:48:58 -0700 (PDT)
Date: Wed, 27 Apr 2016 17:48:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCHv7 00/29] THP-enabled tmpfs/shmem using compound pages
Message-ID: <20160427154854.GA11700@redhat.com>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
 <571565F0.9070203@linaro.org>
 <20160419165024.GB24312@redhat.com>
 <CAJu=L59T4KsEORSOza7TBdnbWtypKgyuGUOZpzvMTENo4rmSqg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJu=L59T4KsEORSOza7TBdnbWtypKgyuGUOZpzvMTENo4rmSqg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: "Shi, Yang" <yang.shi@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Hello Andres,

On Tue, Apr 19, 2016 at 10:07:29AM -0700, Andres Lagar-Cavilla wrote:
> Andrea, we provide the, ahem, adjustments to
> transparent_hugepage_adjust. Rest assured we aggressively use mmu
> notifiers with no further changes required.

Did you notice I just fixed a THP related bug in the very function I
quoted that broke with the THP refcounting in v4.5? That very function
had a major bug after the THP refcounting that was corrupting memory
even with regular anonymous memory THP backing.

https://marc.info/?l=linux-mm&m=146175869123580&w=2

> As in: zero changes have been required in the lifetime (years) of
> kvm+huge tmpfs at Google, other than mod'ing
> transparent_hugepage_adjust.

Zero changes required until the THP model gets improved over time to
accomodate for huge-DAX, tmpfs, ext4 and everything else. THP
refcounting in v4.5 also didn't change this function and that thing
broke off silently.

When I found the bug I realized I just quoted the very buggy function
earlier in this thread, as an example of why we don't want more
complexity in the kernel... and that just reinforced my not wanting
more complexity and wanting just 1 single model for all THP in the
kernel, hence this email.

> As noted by Paolo, the additions to transparent_hugepage_adjust could
> be lifted outside of kvm (into shmem.c? maybe) for any consumer of
> huge tmpfs with mmu notifiers.

That function is not duplicated across the kernel, moving it to common
code can be helpful if others have the same needs to save some .text
but where such function goes and if it's duplicated or not, changes
nothing in terms of overall kernel complexity to maintain with two
completely different THP models in different memory management parts.

Dismissing the complexity of supporting and maintaining two completely
different models of transparent hugepages that provides different
kernel APIs to deal with them for secondary MMU drivers as a
triviality, is proven wrong by what just happened to this function in
v4.5 I think.

The model for THP should be just one, either PageTeam and disaband
works for all THP including ext4 and anonymous memory, or
PageTransCompoundMap and the same split_huge_pmd/split_huge_page
functions already works for tmpfs THP and anon THP exactly in the same
way.

We already have to support a slight different model for hugetlbfs, and
thankfully it's not really different, it's just a "subset" of the THP
model, and it's simpler, so it's not complicating anything (nor
get_user_pages, nor KVM, nor the transparent_hugepage_adjust
function).

In fact the PageTransCompoundMap already works for both hugetlbfs and
THP transparently, the page->_mapcount < 1 check is full bypass for
hugetlbfs exactly because the model is actually the same as THP but a
"subset". hugetlbfs uses compound pages too of course to be much
faster than it ever would with the Team page model.

We don't want another model that just increases the complexity of the
kernel for no good and this was agreed at the MM summit too.

In fact I'd go as far as saying Team Pages must work for hugetlbfs too
and not only anonymous memory, for them to be considered as an
attractive option for tmpfs.

You should drop compound pages from hugetlbfs too, if you intend to
pursue the Team pages direction for the upstream kernel.

Kirill great work for v4.5 in addition of simplifying
get_page/put_page (with a mico-performance improvement for
get_user_pages_fast for tail pages) was a dependency in order to allow
compound page to enter the tmpfs and ext4 land. Clearly it introduced
complexity elsewhere (i.e. split_huge_page now can fail) but the model
is now more generic and powerful in allowing both pmd_trans_huge and
ptes to map compound pages natively, which is needed for tmpfs.

Now that such work is done and upstream I don't see why we want to go
in a direction that isn't justified anymore. Team pages made sense to
reduce the time to market in not having to do the THP refcounting work
Kirill just did to achieve compound THP in tmpfs. They're a fine
not-upstream patchset and they would be suitable to ship in a
distribution kernel or in your proprietary
behind-the-firewall-source-not-released usage. For upstream we should
focus on the long term design not on short term production matters.

Furthermore even for production Team pages also still miss khugepaged,
so there's no point to keep going in that direction when the patchset
is double the size of compound THP pages in tmpfs, and the compound
THP patchset already inlcudes khugepaged in half the size.

I already mentioned why I think Team Pages can't work nearly as
efficiently as compound pages for Anonymous memory in the previous
email and the same issue applies to hugetlbfs too.

Furthermore even for small files the current team pages model of
allocating a contiguous hugepage and then mapping only 4k of the 2M
contiguous chunk of ram allocated is counter productive and is fine
for qemu production usage on tmpfs but not ok for generic production
usage. Team pages as currently implemented will trigger memory
pressure 512 times faster than Kirill's tmpfs version if dealing with
4k files only, running specfs or something. After memory pressure
triggers, the not mapped part of the team page is freed right away so
all work done at the allocation stage is just triggering memory
pressure 512 times faster and then the VM has to do even more useless
work to undo the initial contiguous allocation.

Kirill's compound THP in tmpfs by default is a full bypass for <2MB
i_size, so it'll perform exactly the same for small files and it won't
risk to trigger memory pressure nor require undoing the work done to
allocate the hugepages in the first place. This is fundamental for
XGD_RUNTIME_DIR even on the desktop, not just specfs. If the file
grows over time and the allocation is long lived, Kirill's khugepaged
will collapse THP compound pages asynchronously.

If you don't believe that allocating 2MB for small files and then
freeing the memory when eventually memory pressure trigger 512 times
faster, and missing khugepaged are a showstopper, just check the
discussion on linux-mm where they're proposing to disable direct
compaction and relay only on khugepaged and kcompactd for THP in
anonymous memory, because direct compaction is hurting short lived
allocations on large systems that may require lots of defrag to get
the hugepage (it's not THP itself the problem, THP native compound
faults are a speedup for short lived allocation too and they only get
allocated if the vma is large enough, and in Kirill's THP in tmpfs
version, when the i_size is large enough).

Again, if you only focus on qemu and long lived allocation, both
works great and are amazing work.

However for the long term design we need a single THP design, and
hugetlbfs has to be a subset of it. The design used for THP in
anonymous memory is the one that provides the lowest probability that
no matter the load (short lived, long lived, anything) the risk that
THP is a slowdown is the minimum possible and this shall not
change. Furthermore the compound design is a tremendous speedup also
for short allocations as we don't fault it 4k at time like team pages
would do if the i_size is truncated right away at >=2MB (and the vma
is large enough and properly file-offset hugepage aligned).

For long lived allocations and qemu usage both will work the same, and
you can't notice all the downsides of team pages if you only focus on 
THP craving workloads like KVM.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
