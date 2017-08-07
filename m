Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 04F3E6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 05:25:30 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z195so313257wmz.8
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 02:25:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l24si8528774wrb.200.2017.08.07.02.25.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Aug 2017 02:25:28 -0700 (PDT)
Date: Mon, 7 Aug 2017 11:25:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RESEND] mm: don't zero ballooned pages
Message-ID: <20170807092525.GE32434@dhcp22.suse.cz>
References: <1501761557-9758-1-git-send-email-wei.w.wang@intel.com>
 <9ac31505-0996-2822-752e-8ec055373aa0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9ac31505-0996-2822-752e-8ec055373aa0@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mst@redhat.com, zhenwei.pi@youruncloud.com, dave.hansen@intel.com, akpm@linux-foundation.org, mawilcox@microsoft.com, Andrea Arcangeli <aarcange@redhat.com>

On Mon 07-08-17 10:44:50, David Hildenbrand wrote:
> On 03.08.2017 13:59, Wei Wang wrote:
> > This patch is a revert of 'commit bb01b64cfab7 ("mm/balloon_compaction.c:
> > enqueue zero page to balloon device")'
> > 
> > Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
> > shouldn't be given to the host ksmd to scan. Therefore, it is not
> > necessary to zero ballooned pages, which is very time consuming when
> > the page amount is large. The ongoing fast balloon tests show that the
> > time to balloon 7G pages is increased from ~491ms to 2.8 seconds with
> > __GFP_ZERO added. So, this patch removes the flag.
> > 
> > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  mm/balloon_compaction.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> > index 9075aa5..b06d9fe 100644
> > --- a/mm/balloon_compaction.c
> > +++ b/mm/balloon_compaction.c
> > @@ -24,7 +24,7 @@ struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
> >  {
> >  	unsigned long flags;
> >  	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
> > -				__GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_ZERO);
> > +				       __GFP_NOMEMALLOC | __GFP_NORETRY);
> >  	if (!page)
> >  		return NULL;
> >  
> > 
> 
> Your assumption here is, that the hypervisor will always supply a zero
> page. Unfortunately, this assumption is wrong (and it stems from the
> lack of different page size support in virtio-balloon).
> 
> Think about these examples:
> 
> 1. Guest is backed by huge pages (hugetbfs). Ballooning kicks in.
> 
> MADV_DONTNEED is simply ignored in the hypervisor (hugetlbfs requires
> fallocate punshhole). Also, trying to zap 4k on e.g. 1MB pages will
> simply be ignored.
> 
> 2. Guest on PPC uses 4k pages. Hypervisor uses 64k pages. trying to
> MADV_DONTNEED 4K on 64k pages will simply be ignored.
> 
> So unfortunately, zeroing the page is the right thing to do to cover all
> cases.

Maybe it is my absolute lack of familiarity with what the host actually
does with balloon pages but I fail to see why the above matters at all.
ksm will not try to merge sub page units (4k for hugetlb or a large base
page). And if you need to hide the guest contents then the host can
clear the respective subpage just fine. So could you be more explicit
why MADV_DONTNEED matters at all? Also does any host actually share sub
pages between different guests? This sounds like a bad idea to me in
general.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
