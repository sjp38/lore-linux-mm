Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3B36B025F
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 04:19:07 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k192so491194lfb.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 01:19:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q12si785272wmd.24.2016.06.08.01.19.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Jun 2016 01:19:05 -0700 (PDT)
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish> <20160602092113.GH1995@dhcp22.suse.cz>
 <20160602120857.GA704@swordfish> <20160602122109.GM1995@dhcp22.suse.cz>
 <20160603135154.GD29930@redhat.com> <20160603144600.GK20676@dhcp22.suse.cz>
 <20160603151001.GG29930@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f136aef3-95c8-4394-3626-cd5bb4d04fbd@suse.cz>
Date: Wed, 8 Jun 2016 10:19:03 +0200
MIME-Version: 1.0
In-Reply-To: <20160603151001.GG29930@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On 06/03/2016 05:10 PM, Andrea Arcangeli wrote:
> Hello Michal,
>
> CC'ed Hugh,
>
> On Fri, Jun 03, 2016 at 04:46:00PM +0200, Michal Hocko wrote:
>> What do you think about the external dependencies mentioned above. Do
>> you think this is a sufficient argument wrt. occasional higher
>> latencies?
>
> It's a tradeoff and both latencies would be short and uncommon so it's
> hard to tell.

Shouldn't it be possible to do a mmput() before the hugepage allocation, 
and then again mmget_not_zero()? That way it's no longer a tradeoff?

> There's also mmput_async for paths that may care about mmput
> latencies. Exit itself cannot use it, it's mostly for people taking
> the mm_users pin that may not want to wait for mmput to run. It also
> shouldn't happen that often, it's a slow path.
>
> The whole model inherited from KSM is to deliberately depend only on
> the mmap_sem + test_exit + mm_count, and never on mm_users, which to
> me in principle doesn't sound bad. I consider KSM version a
> "finegrined" implementation but I never thought it would be a problem
> to wait a bit in exit() in case the slow path hits. I thought it was
> more of a problem if exit() runs, the parent then start a new task but
> the memory wasn't freed yet.
>
> So I would suggest Hugh to share his view on the down_write/up_write
> that may temporarily block mmput (until the next test_exit bailout
> point) vs higher latency in reaching exit_mmap for a real exit(2) that
> would happen with the proposed change.
>
> Thanks!
> Andrea
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
