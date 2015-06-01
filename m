Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A747A6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 12:42:33 -0400 (EDT)
Received: by wizo1 with SMTP id o1so112737000wiz.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 09:42:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9si19579432wiv.44.2015.06.01.09.42.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 09:42:32 -0700 (PDT)
Message-ID: <556C8B75.1030405@suse.cz>
Date: Mon, 01 Jun 2015 18:42:29 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: do not call reclaim if !__GFP_WAIT
References: <1432833966-25538-1-git-send-email-vdavydov@parallels.com> <20150528125934.198f57db4c5daf19dd15b184@linux-foundation.org> <20150529065504.GA22728@dhcp22.suse.cz>
In-Reply-To: <20150529065504.GA22728@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On 05/29/2015 08:55 AM, Michal Hocko wrote:
> On Thu 28-05-15 12:59:34, Andrew Morton wrote:
>> On Thu, 28 May 2015 20:26:06 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
>> 
>> > When trimming memcg consumption excess (see memory.high), we call
>> > try_to_free_mem_cgroup_pages without checking if we are allowed to sleep
>> > in the current context, which can result in a deadlock. Fix this.
>> 
>> Why does it deadlock?  try_to_free_mem_cgroup_pages() is passed the
>> gfp_mask and should honour its __GFP_WAIT setting?
> 
> The only instance of __GFP_WAIT check in vmscan code is in zone_reclaim.
> Page allocations and memcg reclaim avoids calling reclaim if __GFP_WAIT
> is not set. Maybe we can move the check to do_try_to_free_pages?

I think it's conceptually wrong. All other paths check it before calling
into do_try_to_free_pages() and act appropriately. Here it would potentially
mask any atomic-specific fallback strategy.

What would make some sense in do_try_to_free_pages() is VM_WARN_ON_ONCE() which
however I assume doesn't exist? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
