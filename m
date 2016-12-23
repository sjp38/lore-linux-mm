Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 96566280264
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 22:34:49 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 5so498031334pgi.2
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 19:34:49 -0800 (PST)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id l5si32712528pgk.200.2016.12.22.19.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 19:34:48 -0800 (PST)
Received: by mail-pg0-x233.google.com with SMTP id f188so104506259pgc.3
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 19:34:48 -0800 (PST)
Date: Thu, 22 Dec 2016 19:34:39 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: RE: A small window for a race condition in
 mm/rmap.c:page_lock_anon_vma_read
In-Reply-To: <23B7B563BA4E9446B962B142C86EF24ADBF309@CNMAILEX03.lenovo.com>
Message-ID: <alpine.LSU.2.11.1612221831580.2799@eggly.anvils>
References: <23B7B563BA4E9446B962B142C86EF24ADBD62C@CNMAILEX03.lenovo.com> <20161221144343.GD593@dhcp22.suse.cz> <20161222135106.GY3124@twins.programming.kicks-ass.net> <alpine.LSU.2.11.1612221351340.1744@eggly.anvils>
 <23B7B563BA4E9446B962B142C86EF24ADBF309@CNMAILEX03.lenovo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dashi DS1 Cao <caods1@lenovo.com>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>, Sasha Levin <alexander.levin@verizon.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 23 Dec 2016, Dashi DS1 Cao wrote:

> The kernel version is "RELEASE: 3.10.0-327.36.3.el7.x86_64". It was the latest kernel release of CentOS 7.2 at that time, or maybe still now.

Okay, thanks: so, basically a v3.10 kernel, with lots of added patches,
but also lacking many more recent fixes.

> I've tried to print the value of anon_vma from other three dumps, but the content is not available in the dump. 
> "gdb: page excluded: kernel virtual address: ffff882b47ddadc0"
> I guess it is not copied out because it has already been put into some unused list.

Useful info: that suggests that the anon_vma was rightly freed, and that
it's the page->_mapcount that's wrong.  The page isn't really mapped
anywhere now, but appearing to be still page_mapped(), it has tricked
page_lock_anon_vma_read() into thinking the stale anon_vma pointer is
safe to access.

That can happen if there's a race, and a page gets mapped with one pte
on top of another: only one of them will be unmapped later.  Incorrect
handling of page table entries.  But I cannot remember anywhere that
was shown to happen - beyond a project of my own, which never reached
the tree.

If it's a file page, that usually ends up as BUG_ON(page_mapped(page))
in __delete_from_page_cache() (in v3.10, changed a little later on),
when truncating or unlinking the file or unmounting the filesystem.
Those have been seen in the past, on rare occasions, but I don't
remember actually root-causing any of them.  If it's an anon page,
there is no equivalent place for such a BUG_ON.

mremap move has a tricky job to do, and might cause such a problem
if its locking were inadequate: but the only example I see since
v3.10 was dd18dbc2d42a "mm, thp: close race between mremap() and
split_huge_page()", and that used to crash in __split_huge_page().

Or see c0d73261f5c1 "mm/memory.c: use entry = ACCESS_ONCE(*pte)
in handle_pte_fault()", which brings us back to Peter's topic of
over-imaginative compilers; but none of us believed that change
really made a difference in practice.

Cc'ing Sasha Levin, long-time trinity-runner, just in case he might
remember any time when a BUG_ON(page_mapped(page)) was really solved:
if so, there's a chance the explanation might also apply to anonymous
pages, and be responsible for your page_lock_anon_vma_read() crashes.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
