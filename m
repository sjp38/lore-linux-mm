Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE9126B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 03:07:04 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p89so11396434pfk.5
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 00:07:04 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g129si1358448pfc.338.2018.01.16.00.07.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 00:07:03 -0800 (PST)
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
References: <201801142054.FAD95378.LVOOFQJOFtMFSH@I-love.SAKURA.ne.jp>
 <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
 <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <7f100b0f-3588-be25-41f6-a0e4dde27916@linux.intel.com>
Date: Tue, 16 Jan 2018 00:06:59 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On 01/15/2018 06:14 PM, Linus Torvalds wrote:
> But I'm adding Dave Hansen explicitly to the cc, in case he has any
> ideas. Not because I blame him, but he's touched the sparsemem code
> fairly recently, so maybe he'd have some idea on adding sanity
> checking to the sparsemem version of pfn_to_page().

I swear I haven't touched it lately!

I'm not sure I'd go after pfn_to_page().  *Maybe* if we were close to
the places where we've done a pfn_to_page(), but I'm not seeing those.
These, for instance (from the January 5th post) have sane (~500MB) PFNs
and all BUG_ON() because of seeing the page being locked at free:

[  192.152510] BUG: Bad page state in process a.out  pfn:18566
[   77.872133] BUG: Bad page state in process a.out  pfn:1873a
[  188.992549] BUG: Bad page state in process a.out  pfn:197ea

and the page in all those cases came off a list, not out of a pte or
something that would need pfn_to_page().  The page fault path leading up
to the "EIP is at page_cache_tree_insert+0xbe/0xc0" probably doesn't
have a pfn_to_page() anywhere in there at all.

Did anyone else notice the

	[   31.068198]  ? vmalloc_sync_all+0x150/0x150

present in a bunch of the stack traces?  That should be pretty uncommon.
 Is it just part of the normal do_page_fault() stack and the stack
dumper picks up on it?

A few things from earlier in this thread:

> [   44.103192] page:5a5a0697 count:-1055023618 mapcount:-1055030029 mapping:26f4be11 index:0xc11d7c83
> [   44.103196] flags: 0xc10528fe(waiters|error|referenced|uptodate|dirty|lru|active|reserved|private_2|mappedtodisk|swapbacked)
> [   44.103200] raw: c10528fe c114fff7 c11d7c83 c11d84f2 c11d9dfe c11daa34 c11daaa0 c13e65df
> [   44.103201] raw: c13e4a1c c13e4c62
> [   44.103202] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) <= 0)
> [   44.103203] page->mem_cgroup:35401b27

Isn't that 'page:' a non-aligned address in userspace?  It's also weird
that you start dumping out kernel-looking addresses that came from
userspace addresses.  Which VM_SPLIT option are you running with, btw?

I'm still pretty stumped, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
