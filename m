Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D350F6B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 03:41:23 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 73so12382200pfz.11
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 00:41:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w11si8097503pgq.163.2017.12.18.00.41.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 00:41:22 -0800 (PST)
Date: Mon, 18 Dec 2017 09:41:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: thp: use down_read_trylock in khugepaged to avoid
 long block
Message-ID: <20171218084119.GJ16951@dhcp22.suse.cz>
References: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
 <20171215102753.GY16951@dhcp22.suse.cz>
 <13f935a9-42af-98f4-1813-456a25200d9d@alibaba-inc.com>
 <20171216114525.GH16951@dhcp22.suse.cz>
 <20171216200925.kxvkuqoyhkonj7m6@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171216200925.kxvkuqoyhkonj7m6@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Yang Shi <yang.s@alibaba-inc.com>, kirill.shutemov@linux.intel.com, hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 16-12-17 23:09:25, Kirill A. Shutemov wrote:
> On Sat, Dec 16, 2017 at 12:45:25PM +0100, Michal Hocko wrote:
> > On Sat 16-12-17 04:04:10, Yang Shi wrote:
[...]
> > > Shall we add "cond_resched()" in unmap_vmas(), i.e for every 100 vmas? It
> > > may improve the responsiveness a little bit for non-preempt kernel, although
> > > it still can't release the semaphore.
> > 
> > We already do, once per pmd (see zap_pmd_range).
> 
> It doesn't help. We would need to find a way to drop mmap_sem, if we're
> holding it way too long. And doing it on per-vma count basis is not right
> call. It won't address issue with single huge vma.

Absolutely agreed. I just wanted to point out that a new cond_resched is
not really needed. One way to reduce the lock starvation is to use range
locking.

> Do we have any instrumentation that would help detect starvation on a
> rw_semaphore?

I am afraid we don't.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
