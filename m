Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19AD86B0005
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 04:01:57 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ug1so43639684pab.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 01:01:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id do10si6346244pac.124.2016.06.09.01.01.56
        for <linux-mm@kvack.org>;
        Thu, 09 Jun 2016 01:01:56 -0700 (PDT)
From: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Subject: RE: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page
 arrival
Date: Thu, 9 Jun 2016 08:01:52 +0000
Message-ID: <D6EDEBF1F91015459DB866AC4EE162CC023F8E78@IRSMSX103.ger.corp.intel.com>
References: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
 <20160608150422.GO22570@dhcp22.suse.cz>
In-Reply-To: <20160608150422.GO22570@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "mingli199x@qq.com" <mingli199x@qq.com>, "minchan@kernel.org" <minchan@kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Anaczkowski,
 Lukasz" <lukasz.anaczkowski@intel.com>

On Wed 08-07-16 17:04:00, Michal Hocko wrote:=20
> I do not see how a SIGTERM would make any difference. But see below.

This is how we encounter this problem initially, by hitting ctr-c while
running parallel  memory intensive workload, which ended up
not calling munmap on allocated memory.

> Is this really true? Both munmap and exit_mmap do the same
> lru_add_drain() which flushes only the local CPU cache so munmap
> shouldn't make any difference.

Damn, I forgot to escape # in pragma parallel, it should be
void main(){
#pragma parallel
{
(...)

And then yes, exit_mmap will flush just the local CPU cache, but not the
rest. This would be another way of fixing the problem, but I concluded
that it would hurt performance on short running processes like scripts
if we do it synchronously, and we will be racing with next processes if=20
we do it asynchronously, not tested it though.

> I believe this deserves a more explanation. What do you think about the
> following.
> "
> The primary point of the LRU add cache is to save the zone lru_lock
> contention with a hope that more pages will belong to the same zone
> and so their addition can be batched. The huge page is already a
> form of batched addition (it will add 512 worth of memory in one go)
> so skipping the batching seems like a safer option when compared to a
> potential excess in the caching which can be quite large and much
> harder to fix because lru_add_drain_all is way to expensive and
> it is not really clear what would be a good moment to call it.
>"
>
> Does this sound better?

Far better, thanks.

Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
