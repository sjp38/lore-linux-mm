Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 80A9A6B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 14:55:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b20so3071377wma.11
        for <linux-mm@kvack.org>; Tue, 02 May 2017 11:55:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 39si21057502wry.53.2017.05.02.11.55.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 11:55:11 -0700 (PDT)
Date: Tue, 2 May 2017 20:55:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
Message-ID: <20170502185507.GB19165@dhcp22.suse.cz>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170427143721.GK4706@dhcp22.suse.cz>
 <87pofxk20k.fsf@firstfloor.org>
 <20170428060755.GA8143@dhcp22.suse.cz>
 <20170428073136.GE8143@dhcp22.suse.cz>
 <3eb86373-dafc-6db9-82cd-84eb9e8b0d37@linux.vnet.ibm.com>
 <20170428134831.GB26705@dhcp22.suse.cz>
 <c8ce6056-e89b-7470-c37a-85ab5bc7a5b2@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c8ce6056-e89b-7470-c37a-85ab5bc7a5b2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue 02-05-17 16:59:30, Laurent Dufour wrote:
> On 28/04/2017 15:48, Michal Hocko wrote:
[...]
> > This is getting quite hairy. What is the expected page count of the
> > hwpoison page?

OK, so from the quick check of the hwpoison code it seems that the ref
count will be > 1 (from get_hwpoison_page).

> > I guess we would need to update the VM_BUG_ON in the
> > memcg uncharge code to ignore the page count of hwpoison pages if it can
> > be arbitrary.
> 
> Based on the experiment I did, page count == 2 when isolate_lru_page()
> succeeds, even in the case of a poisoned page.

that would make some sense to me. The page should have been already
unmapped therefore but memory_failure increases the ref count and 1 is
for isolate_lru_page().

> In my case I think this
> is because the page is still used by the process which is calling madvise().
> 
> I'm wondering if I'm looking at the right place. May be the poisoned
> page should remain attach to the memory_cgroup until no one is using it.
> In that case this means that something should be done when the page is
> off-lined... I've to dig further here.

No, AFAIU the page will not drop the reference count down to 0 in most
cases. Maybe there are some scenarios where this can happen but I would
expect that the poisoned page will be mapped and in use most of the time
and won't drop down 0. And then we should really uncharge it because it
will pin the memcg and make it unfreeable which doesn't seem to be what
we want.  So does the following work reasonable? Andi, Johannes, what do
you think? I cannot say I would be really comfortable touching hwpoison
code as I really do not understand the workflow. Maybe we want to move
this uncharge down to memory_failure() right before we report success?
---
