Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 509406B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 02:08:00 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id n104so4910192wrb.20
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 23:08:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p193si5300710wme.51.2017.04.27.23.07.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 23:07:58 -0700 (PDT)
Date: Fri, 28 Apr 2017 08:07:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
Message-ID: <20170428060755.GA8143@dhcp22.suse.cz>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170427143721.GK4706@dhcp22.suse.cz>
 <87pofxk20k.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87pofxk20k.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Thu 27-04-17 13:51:23, Andi Kleen wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Tue 25-04-17 16:27:51, Laurent Dufour wrote:
> >> When page are poisoned, they should be uncharged from the root memory
> >> cgroup.
> >> 
> >> This is required to avoid a BUG raised when the page is onlined back:
> >> BUG: Bad page state in process mem-on-off-test  pfn:7ae3b
> >> page:f000000001eb8ec0 count:0 mapcount:0 mapping:          (null)
> >> index:0x1
> >> flags: 0x3ffff800200000(hwpoison)
> >
> > My knowledge of memory poisoning is very rudimentary but aren't those
> > pages supposed to leak and never come back? In other words isn't the
> > hoplug code broken because it should leave them alone?
> 
> Yes that would be the right interpretation. If it was really offlined
> due to a hardware error the memory will be poisoned and any access
> could cause a machine check.

OK, thanks for the clarification. Then I am not sure the patch is
correct. Why do we need to uncharge that page at all? It is not freed.
The correct thing to do is to not online it in the first place which is
done in patch2 [1]. Even if we need to uncharge the page the reason is
not to silent the BUG, that is merely papering a issue than a real fix.
Laurent can you elaborate please.

[1] http://lkml.kernel.org/r/1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
