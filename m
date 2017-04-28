Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80F5D6B0038
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 09:48:36 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r3so5838831wrb.19
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 06:48:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x203si3033439wmx.126.2017.04.28.06.48.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Apr 2017 06:48:35 -0700 (PDT)
Date: Fri, 28 Apr 2017 15:48:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
Message-ID: <20170428134831.GB26705@dhcp22.suse.cz>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170427143721.GK4706@dhcp22.suse.cz>
 <87pofxk20k.fsf@firstfloor.org>
 <20170428060755.GA8143@dhcp22.suse.cz>
 <20170428073136.GE8143@dhcp22.suse.cz>
 <3eb86373-dafc-6db9-82cd-84eb9e8b0d37@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3eb86373-dafc-6db9-82cd-84eb9e8b0d37@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Fri 28-04-17 11:17:34, Laurent Dufour wrote:
> On 28/04/2017 09:31, Michal Hocko wrote:
> > [CC Johannes and Vladimir - the patch is
> > http://lkml.kernel.org/r/1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com]
> > 
> > On Fri 28-04-17 08:07:55, Michal Hocko wrote:
> >> On Thu 27-04-17 13:51:23, Andi Kleen wrote:
> >>> Michal Hocko <mhocko@kernel.org> writes:
> >>>
> >>>> On Tue 25-04-17 16:27:51, Laurent Dufour wrote:
> >>>>> When page are poisoned, they should be uncharged from the root memory
> >>>>> cgroup.
> >>>>>
> >>>>> This is required to avoid a BUG raised when the page is onlined back:
> >>>>> BUG: Bad page state in process mem-on-off-test  pfn:7ae3b
> >>>>> page:f000000001eb8ec0 count:0 mapcount:0 mapping:          (null)
> >>>>> index:0x1
> >>>>> flags: 0x3ffff800200000(hwpoison)
> >>>>
> >>>> My knowledge of memory poisoning is very rudimentary but aren't those
> >>>> pages supposed to leak and never come back? In other words isn't the
> >>>> hoplug code broken because it should leave them alone?
> >>>
> >>> Yes that would be the right interpretation. If it was really offlined
> >>> due to a hardware error the memory will be poisoned and any access
> >>> could cause a machine check.
> >>
> >> OK, thanks for the clarification. Then I am not sure the patch is
> >> correct. Why do we need to uncharge that page at all?
> > 
> > Now, I have realized that we actually want to uncharge that page because
> > it will pin the memcg and we do not want to have that memcg and its
> > whole hierarchy pinned as well. This used to work before the charge
> > rework 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API") I guess
> > because we used to uncharge on page cache removal.
> > 
> > I do not think the patch is correct, though. memcg_kmem_enabled() will
> > check whether kmem accounting is enabled and we are talking about page
> > cache pages here. You should be using mem_cgroup_uncharge instead.
> 
> Thanks for the review Michal.
> 
> I was not comfortable either with this patch.
> 
> I did some tests calling mem_cgroup_uncharge() when isolate_lru_page()
> succeeds only, so not calling it if isolate_lru_page() failed.

Wait a moment. This cannot possibly work. isolate_lru_page asumes page
count > 0 and increments the counter so the resulting page count is > 1
I have only now realized that we have VM_BUG_ON_PAGE(page_count(page), page)
in uncharge_list().

This is getting quite hairy. What is the expected page count of the
hwpoison page? I guess we would need to update the VM_BUG_ON in the
memcg uncharge code to ignore the page count of hwpoison pages if it can
be arbitrary.

Before we go any further, is there any documentation about the expected
behavior and the state of the hwpoison pages? I have a very bad feeling
that the current behavior is quite arbitrary and "testing driven"
holes plugging will make it only more messy. So let's start with the
clear description of what should happen with the hwpoison pages.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
