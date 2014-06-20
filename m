Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5901D6B0031
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 17:43:50 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so3402613pdb.39
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:43:50 -0700 (PDT)
Received: from mail-pb0-x230.google.com (mail-pb0-x230.google.com [2607:f8b0:400e:c01::230])
        by mx.google.com with ESMTPS id of3si11365602pbc.65.2014.06.20.14.43.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 14:43:49 -0700 (PDT)
Received: by mail-pb0-f48.google.com with SMTP id rq2so3546689pbb.7
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:43:48 -0700 (PDT)
Date: Fri, 20 Jun 2014 14:42:25 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at /src/linux-dev/mm/mempolicy.c:1738! on v3.16-rc1
In-Reply-To: <20140620211253.GC15620@nhori.bos.redhat.com>
Message-ID: <alpine.LSU.2.11.1406201438590.8689@eggly.anvils>
References: <20140619215641.GA9792@nhori.bos.redhat.com> <alpine.DEB.2.11.1406200923220.10271@gentwo.org> <20140620194639.GA30729@nhori.bos.redhat.com> <alpine.LSU.2.11.1406201257370.8123@eggly.anvils> <20140620211253.GC15620@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@gentwo.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 20 Jun 2014, Naoya Horiguchi wrote:
> On Fri, Jun 20, 2014 at 01:03:58PM -0700, Hugh Dickins wrote:
> > On Fri, 20 Jun 2014, Naoya Horiguchi wrote:
> > > On Fri, Jun 20, 2014 at 09:24:36AM -0500, Christoph Lameter wrote:
> > > > On Thu, 19 Jun 2014, Naoya Horiguchi wrote:
> > > >
> > > > > I'm suspecting that mbind_range() do something wrong around vma handling,
> > > > > but I don't have enough luck yet. Anyone has an idea?
> > > >
> > > > Well memory policy data corrupted. This looks like you were trying to do
> > > > page migration via mbind()?
> > > 
> > > Right.
> > > 
> > > > Could we get some more details as to what is
> > > > going on here? Specifically the parameters passed to mbind would be
> > > > interesting.
> > > 
> > > My view about the kernel behavior was in another email a few hours ago.
> > > And as for what userspace did, I attach the reproducer below. It's simply
> > > doing mbind(mode=MPOL_BIND, flags=MPOL_MF_MOVE_ALL) on random address/length/node.
> > 
> > Thanks for the additional information earlier.  ext4, so no shmem
> > shared mempolicy involved: that cuts down the bugspace considerably.
> > 
> > I agree from what you said that it looked like corrupt vm_area_struct
> > and hence corrupt policy.
> > 
> > Here's an obvious patch to try, entirely untested - thanks for the
> > reproducer, but I'd rather leave the testing to you.  Sounds like
> > you have a useful fuzzer there: good catch.
> > 
> > 
> > [PATCH] mm: fix crashes from mbind() merging vmas
> > 
> > v2.6.34's 9d8cebd4bcd7 ("mm: fix mbind vma merge problem") introduced
> > vma merging to mbind(), but it should have also changed the convention
> > of passing start vma from queue_pages_range() (formerly check_range())
> > to new_vma_page(): vma merging may have already freed that structure,
> > resulting in BUG at mm/mempolicy.c:1738 and probably worse crashes.
> > 
> > Fixes: 9d8cebd4bcd7 ("mm: fix mbind vma merge problem")
> > Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > Cc: stable@vger.kernel.org # 2.6.34+
> 
> With your patch, the bug doesn't reproduce in one hour testing. I think
> it's long enough because it took only a few minutes until the reproducer
> triggered the bug without your patch.
> So I think the problem was gone, thank you very much!
> 
> Tested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
& Acked-by: Christoph Lameter <cl@linux.com>

Great, thank you both.  I was afraid you might hit something else
immediately.  I'll send the patch to Andrew later - unless it
magically appears in his tree before.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
