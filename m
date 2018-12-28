Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C57C38E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 16:09:41 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a2so20627151pgt.11
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 13:09:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r2si16565938pgo.483.2018.12.28.13.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 13:09:40 -0800 (PST)
Date: Fri, 28 Dec 2018 13:09:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: KASAN: use-after-free Read in filemap_fault
Message-Id: <20181228130938.c9e42c213cdcc35a93dd0dac@linux-foundation.org>
In-Reply-To: <000000000000b57d19057e1b383d@google.com>
References: <000000000000b57d19057e1b383d@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com>
Cc: darrick.wong@oracle.com, hannes@cmpxchg.org, hughd@google.com, jack@suse.cz, josef@toxicpanda.com, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, willy@infradead.org

On Fri, 28 Dec 2018 12:51:04 -0800 syzbot <syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com> wrote:

> Hello,
> 
> syzbot found the following crash on:

uh-oh.  Josef, could you please take a look?

:	page = find_get_page(mapping, offset);
: 	if (likely(page) && !(vmf->flags & FAULT_FLAG_TRIED)) {
: 		/*
: 		 * We found the page, so try async readahead before
: 		 * waiting for the lock.
: 		 */
: 		fpin = do_async_mmap_readahead(vmf, page);
: 	} else if (!page) {
: 		/* No page in the page cache at all */
: 		fpin = do_sync_mmap_readahead(vmf);
: 		count_vm_event(PGMAJFAULT);
: 		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);

vmf->vma has been freed at this point.

: 		ret = VM_FAULT_MAJOR;
: retry_find:
: 		page = pagecache_get_page(mapping, offset,
: 					  FGP_CREAT|FGP_FOR_MMAP,
: 					  vmf->gfp_mask);
: 		if (!page) {
: 			if (fpin)
: 				goto out_retry;
: 			return vmf_error(-ENOMEM);
: 		}
: 	}
