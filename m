Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B97A6B000A
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 08:12:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4-v6so1812630wmh.0
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 05:12:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h3-v6sor1179863wmb.78.2018.07.04.05.12.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 05:12:07 -0700 (PDT)
Date: Wed, 4 Jul 2018 14:12:05 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: kernel BUG at mm/gup.c:LINE!
Message-ID: <20180704121205.GA24526@techadventures.net>
References: <000000000000fe4b15057024bacd@google.com>
 <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
 <20180704111731.GJ22503@dhcp22.suse.cz>
 <FB141DA1-F8B8-4E9A-84E5-176B07463AEB@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <FB141DA1-F8B8-4E9A-84E5-176B07463AEB@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

> A strange thing is that __mm_populate() is only called by do_mlock() from mm/mlock.c,
> which makes len PAGE_ALIGN already. That VM_BUG_ON should not be triggered.

Unless I overlooked something, __mm_populate() gets called from:

load_elf_library() -> vm_brk() -> vm_brk_flags():

vm_brk_flags() {
	...
	populate = ((mm->def_flags & VM_LOCKED) != 0);
	...
	if (populate && !ret)
		mm_populate(addr, len);
}

mm_populate() -> __mm_populate():

__mm_populate() {
	...
	VM_BUG_ON(len != PAGE_ALIGN(len));
	...
}


In load_elf_library(), we have:

len = ELF_PAGESTART(eppnt->p_filesz + eppnt->p_vaddr +
			    ELF_MIN_ALIGN - 1);
bss = eppnt->p_memsz + eppnt->p_vaddr;
if (bss > len) {
	error = vm_brk(len, bss - len);
	if (error)
		goto out_free_ph;
}

So len gets page aligned, but not bss (eppnt->p_memsz + eppnt->p_vaddr), maybe that's the problem?


-- 
Oscar Salvador
SUSE L3
