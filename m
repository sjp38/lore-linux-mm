Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na6sys010bmx003.postini.com [74.125.246.103])
	by kanga.kvack.org (Postfix) with SMTP id D5D1E6B00AF
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 18:53:48 -0400 (EDT)
Date: Mon, 25 Mar 2013 15:53:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-v3.9-rc3: BUG: Bad page map in process trinity-child6
 pte:002f9045 pmd:29e421e1
Message-Id: <20130325155347.75290358a6985e17fb10ad14@linux-foundation.org>
In-Reply-To: <514C94C4.4050008@gmx.de>
References: <514C94C4.4050008@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toralf =?ISO-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Cc: user-mode-linux-user@lists.sourceforge.net, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, 22 Mar 2013 18:28:36 +0100 Toralf F__rster <toralf.foerster@gmx.de> wrote:

> Using trinity I often trigger under a user mode linux image with host kernel 3.8.4
> and guest kernel linux-v3.9-rc3-244-g9217cbb the following :
> (The UML guest is a 32bit stable Gentoo Linux)

I assume 3.8 is OK?

> 
> 2013-03-22T18:03:01.232+01:00 trinity kernel: BUG: Bad page map in process trinity-child6  pte:002f9045 pmd:29e421e1
> 2013-03-22T18:03:01.232+01:00 trinity kernel: page:0920df20 count:1 mapcount:-1 mapping:  (null) index:0x0

mapcount=-1.

> 2013-03-22T18:03:01.232+01:00 trinity kernel: page flags: 0x400(reserved)
> 2013-03-22T18:03:01.232+01:00 trinity kernel: addr:00100000 vm_flags:00060055 anon_vma:  (null) mapping:  (null) index:100
> 2013-03-22T18:03:01.232+01:00 trinity kernel: vma->vm_ops->fault: special_mapping_fault+0x0/0x80
> 2013-03-22T18:03:01.232+01:00 trinity kernel: 31e87d1c:  [<0833b8b8>] dump_stack+0x22/0x24
> 2013-03-22T18:03:01.232+01:00 trinity kernel: 31e87d34:  [<0833cc71>] print_bad_pte+0x17b/0x197
> 2013-03-22T18:03:01.232+01:00 trinity kernel: 31e87d78:  [<080e1138>] unmap_single_vma+0x268/0x430
> 2013-03-22T18:03:01.232+01:00 trinity kernel: 31e87dd8:  [<080e1837>] unmap_vmas+0x37/0x50
> 2013-03-22T18:03:01.232+01:00 trinity kernel: 31e87df4:  [<080e4970>] unmap_region+0x80/0xe0
> 2013-03-22T18:03:01.233+01:00 trinity kernel: 31e87e30:  [<080e6661>] do_munmap+0x231/0x2a0
> 2013-03-22T18:03:01.233+01:00 trinity kernel: 31e87e68:  [<080e8ae8>] sys_mremap+0x248/0x480
> 2013-03-22T18:03:01.233+01:00 trinity kernel: 31e87eac:  [<08062a82>] handle_syscall+0x82/0xb0
> 2013-03-22T18:03:01.233+01:00 trinity kernel: 31e87ef4:  [<08074dfd>] userspace+0x46d/0x590
> 2013-03-22T18:03:01.233+01:00 trinity kernel: 31e87fec:  [<0805f7bc>] fork_handler+0x6c/0x70
> 2013-03-22T18:03:01.233+01:00 trinity kernel: 31e87ffc:  [<00000000>] 0x0
> 2013-03-22T18:03:01.233+01:00 trinity kernel: 2013-03-22T18:03:01.233+01:00 trinity kernel: Disabling lock debugging due to kernel taint
> 2013-03-22T18:03:01.233+01:00 trinity kernel: BUG: Bad page state in process trinity-child6  pfn:002f9
> 2013-03-22T18:03:01.233+01:00 trinity kernel: page:0920df20 count:0 mapcount:-1 mapping:  (null) index:0x0
> 2013-03-22T18:03:01.235+01:00 trinity kernel: page flags: 0x400(reserved)
> 2013-03-22T18:03:01.235+01:00 trinity kernel: 31e87cd4:  [<0833b8b8>] dump_stack+0x22/0x24
> 2013-03-22T18:03:01.235+01:00 trinity kernel: 31e87cec:  [<080cd755>] bad_page+0xb5/0xe0
> 2013-03-22T18:03:01.235+01:00 trinity kernel: 31e87d08:  [<080cd7f3>] free_pages_prepare+0x73/0xb0
> 2013-03-22T18:03:01.235+01:00 trinity kernel: 31e87d24:  [<080cec1d>] free_hot_cold_page+0x1d/0x100
> 2013-03-22T18:03:01.235+01:00 trinity kernel: 31e87d4c:  [<080d15ae>] __put_single_page+0x1e/0x30
> 2013-03-22T18:03:01.235+01:00 trinity kernel: 31e87d60:  [<080d16d7>] put_page+0x27/0x30
> 2013-03-22T18:03:01.235+01:00 trinity kernel: 31e87d68:  [<080ee6ec>] free_page_and_swap_cache+0x3c/0x50
> 2013-03-22T18:03:01.235+01:00 trinity kernel: 31e87d78:  [<080e1155>] unmap_single_vma+0x285/0x430
> 2013-03-22T18:03:01.235+01:00 trinity kernel: 31e87dd8:  [<080e1837>] unmap_vmas+0x37/0x50
> 2013-03-22T18:03:01.236+01:00 trinity kernel: 31e87df4:  [<080e4970>] unmap_region+0x80/0xe0
> 2013-03-22T18:03:01.236+01:00 trinity kernel: 31e87e30:  [<080e6661>] do_munmap+0x231/0x2a0
> 2013-03-22T18:03:01.236+01:00 trinity kernel: 31e87e68:  [<080e8ae8>] sys_mremap+0x248/0x480
> 2013-03-22T18:03:01.236+01:00 trinity kernel: 31e87eac:  [<08062a82>] handle_syscall+0x82/0xb0
> 2013-03-22T18:03:01.236+01:00 trinity kernel: 31e87ef4:  [<08074dfd>] userspace+0x46d/0x590
> 2013-03-22T18:03:01.236+01:00 trinity kernel: 31e87fec:  [<0805f7bc>] fork_handler+0x6c/0x70
> 2013-03-22T18:03:01.236+01:00 trinity kernel: 31e87ffc:  [<00000000>] 0x0
> 2013-03-22T18:03:01.236+01:00 trinity kernel: 2013-03-22T18:03:01.236+01:00 trinity kernel: BUG: Bad page map in process trinity-child6  pte:29e38045 pmd:29e421e1
> 2013-03-22T18:03:01.236+01:00 trinity kernel: page:09744700 count:1 mapcount:-1 mapping:  (null) index:0x0
> 2013-03-22T18:03:01.237+01:00 trinity kernel: page flags: 0x0()
> 2013-03-22T18:03:01.237+01:00 trinity kernel: addr:00101000 vm_flags:00060055 anon_vma:  (null) mapping:  (null) index:101
> 2013-03-22T18:03:01.237+01:00 trinity kernel: vma->vm_ops->fault: special_mapping_fault+0x0/0x80
> 2013-03-22T18:03:01.237+01:00 trinity kernel: 31e87d1c:  [<0833b8b8>] dump_stack+0x22/0x24
> 2013-03-22T18:03:01.237+01:00 trinity kernel: 31e87d34:  [<0833cc71>] print_bad_pte+0x17b/0x197
> 2013-03-22T18:03:01.237+01:00 trinity kernel: 31e87d78:  [<080e1138>] unmap_single_vma+0x268/0x430
> 2013-03-22T18:03:01.237+01:00 trinity kernel: 31e87dd8:  [<080e1837>] unmap_vmas+0x37/0x50
> 2013-03-22T18:03:01.237+01:00 trinity kernel: 31e87df4:  [<080e4970>] unmap_region+0x80/0xe0
> 2013-03-22T18:03:01.237+01:00 trinity kernel: 31e87e30:  [<080e6661>] do_munmap+0x231/0x2a0
> 2013-03-22T18:03:01.237+01:00 trinity kernel: 31e87e68:  [<080e8ae8>] sys_mremap+0x248/0x480
> 2013-03-22T18:03:01.238+01:00 trinity kernel: 31e87eac:  [<08062a82>] handle_syscall+0x82/0xb0
> 2013-03-22T18:03:01.238+01:00 trinity kernel: 31e87ef4:  [<08074dfd>] userspace+0x46d/0x590
> 2013-03-22T18:03:01.238+01:00 trinity kernel: 31e87fec:  [<0805f7bc>] fork_handler+0x6c/0x70
> 2013-03-22T18:03:01.238+01:00 trinity kernel: 31e87ffc:  [<00000000>] 0x0
> 2013-03-22T18:03:01.238+01:00 trinity kernel: 2013-03-22T18:03:01.238+01:00 trinity kernel: BUG: Bad page state in process trinity-child6  pfn:29e38
> 2013-03-22T18:03:01.238+01:00 trinity kernel: page:09744700 count:0 mapcount:-1 mapping:  (null) index:0x0
> 2013-03-22T18:03:01.238+01:00 trinity kernel: page flags: 0x0()
> 2013-03-22T18:03:01.238+01:00 trinity kernel: 31e87cd4:  [<0833b8b8>] dump_stack+0x22/0x24
> 2013-03-22T18:03:01.238+01:00 trinity kernel: 31e87cec:  [<080cd755>] bad_page+0xb5/0xe0
> 2013-03-22T18:03:01.239+01:00 trinity kernel: 31e87d08:  [<080cd7f3>] free_pages_prepare+0x73/0xb0
> 2013-03-22T18:03:01.239+01:00 trinity kernel: 31e87d24:  [<080cec1d>] free_hot_cold_page+0x1d/0x100
> 2013-03-22T18:03:01.239+01:00 trinity kernel: 31e87d4c:  [<080d15ae>] __put_single_page+0x1e/0x30
> 2013-03-22T18:03:01.239+01:00 trinity kernel: 31e87d60:  [<080d16d7>] put_page+0x27/0x30
> 2013-03-22T18:03:01.239+01:00 trinity kernel: 31e87d68:  [<080ee6ec>] free_page_and_swap_cache+0x3c/0x50
> 2013-03-22T18:03:01.239+01:00 trinity kernel: 31e87d78:  [<080e1155>] unmap_single_vma+0x285/0x430
> 2013-03-22T18:03:01.239+01:00 trinity kernel: 31e87dd8:  [<080e1837>] unmap_vmas+0x37/0x50
> 2013-03-22T18:03:01.239+01:00 trinity kernel: 31e87df4:  [<080e4970>] unmap_region+0x80/0xe0
> 2013-03-22T18:03:01.239+01:00 trinity kernel: 31e87e30:  [<080e6661>] do_munmap+0x231/0x2a0
> 2013-03-22T18:03:01.239+01:00 trinity kernel: 31e87e68:  [<080e8ae8>] sys_mremap+0x248/0x480
> 2013-03-22T18:03:01.240+01:00 trinity kernel: 31e87eac:  [<08062a82>] handle_syscall+0x82/0xb0
> 2013-03-22T18:03:01.240+01:00 trinity kernel: 31e87ef4:  [<08074dfd>] userspace+0x46d/0x590
> 2013-03-22T18:03:01.240+01:00 trinity kernel: 31e87fec:  [<0805f7bc>] fork_handler+0x6c/0x70
> 2013-03-22T18:03:01.240+01:00 trinity kernel: 31e87ffc:  [<00000000>] 0x0
> 2013-03-22T18:03:01.240+01:00 trinity kernel: 2013-03-22T18:03:01.240+01:00 trinity kernel: Stub registers -
> 2013-03-22T18:03:01.240+01:00 trinity kernel:   0 - 100000
> 2013-03-22T18:03:01.240+01:00 trinity kernel:   1 - 300000
> 2013-03-22T18:03:01.240+01:00 trinity kernel:   2 - 0
> 2013-03-22T18:03:01.240+01:00 trinity kernel:   3 - 0
> 2013-03-22T18:03:01.243+01:00 trinity kernel:   4 - 0
> 2013-03-22T18:03:01.243+01:00 trinity kernel:   5 - 0
> 2013-03-22T18:03:01.243+01:00 trinity kernel:   6 - 0
> 2013-03-22T18:03:01.243+01:00 trinity kernel:   7 - 7b
> 2013-03-22T18:03:01.243+01:00 trinity kernel:   8 - 7b
> 2013-03-22T18:03:01.243+01:00 trinity kernel:   9 - 0
> 2013-03-22T18:03:01.243+01:00 trinity kernel:   10 - 33
> 2013-03-22T18:03:01.243+01:00 trinity kernel:   11 - ffffffff
> 2013-03-22T18:03:01.243+01:00 trinity kernel:   12 - 1000c3
> 2013-03-22T18:03:01.243+01:00 trinity kernel:   13 - 73
> 2013-03-22T18:03:01.244+01:00 trinity kernel:   14 - 10206
> 2013-03-22T18:03:01.244+01:00 trinity kernel:   15 - 101028
> 2013-03-22T18:03:01.244+01:00 trinity kernel:   16 - 7b
> 2013-03-22T18:03:01.244+01:00 trinity kernel: wait_stub_done : failed to wait for SIGTRAP, pid = 3143, n = 3143, errno = 0, status = 0xb7f
> 
> 
> -- 
> MfG/Sincerely
> Toralf F__rster
> pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
