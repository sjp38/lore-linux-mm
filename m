Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55B896B0003
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 18:07:22 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t5-v6so639930pgt.18
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 15:07:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s23-v6sor3393124pgk.104.2018.07.09.15.07.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 15:07:20 -0700 (PDT)
Date: Tue, 10 Jul 2018 01:07:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel BUG at mm/memory.c:LINE!
Message-ID: <20180709220711.2zz75g4mo4p76bbx@kshutemo-mobl1>
References: <0000000000004a7da505708a9915@google.com>
 <20180709101558.63vkwppwcgzcv3dg@kshutemo-mobl1>
 <CACT4Y+a=8NOg+h6fBzpmVHiZ-vNUiG7SW4QgQvK3vD=KBqQ3_Q@mail.gmail.com>
 <CACT4Y+baBmOHwH6rUL3DjKhGk-JjBAvKOmnq65_4z6b96ohrBQ@mail.gmail.com>
 <20180709142155.jlgytrhdmkyvowzh@kshutemo-mobl1>
 <20180709152508.smwg252x57pnfkoq@kshutemo-mobl1>
 <CACT4Y+YM=M0b_VVNyBNq6Qa25veRzw-WhxXkovS9Kmu23LPVVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YM=M0b_VVNyBNq6Qa25veRzw-WhxXkovS9Kmu23LPVVA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+3f84280d52be9b7083cc@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, ldufour@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Matthew Wilcox <willy@infradead.org>, ying.huang@intel.com

On Mon, Jul 09, 2018 at 07:23:15PM +0200, Dmitry Vyukov wrote:
> On Mon, Jul 9, 2018 at 5:25 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > On Mon, Jul 09, 2018 at 05:21:55PM +0300, Kirill A. Shutemov wrote:
> >> > This also happened only once so far:
> >> > https://syzkaller.appspot.com/bug?extid=3f84280d52be9b7083cc
> >> > and I can't reproduce it rerunning this program. So it's either a very
> >> > subtle race, or fd in the middle of netlink address magically matched
> >> > some fd once, or something else...
> >>
> >> Okay, I've got it reproduced. See below.
> >>
> >> The problem is that kcov doesn't set vm_ops for the VMA and it makes
> >> kernel think that the VMA is anonymous.
> >>
> >> It's not necessary the way it was triggered by syzkaller. I just found
> >> that kcov's ->mmap doesn't set vm_ops. There can more such cases.
> >> vma_is_anonymous() is what we need to fix.
> >>
> >> ( Although, I found logic around mmaping the file second time questinable
> >>   at best. It seems broken to me. )
> >>
> >> It is known that vma_is_anonymous() can produce false-positives. It tried
> >> to fix it once[1], but it back-fired[2].
> >>
> >> I'll look at this again.
> >
> > Below is a patch that seems work. But it definately requires more testing.
> >
> > Dmitry, could you give it a try in syzkaller?
> 
> Trying.
> 
> Not sure what you expect from this. Either way it will be hundreds of
> crashes before vs hundreds of crashes after ;)
> 
> But one that started popping up is this, looks like it's somewhere
> around the code your patch touches:
> 
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> CPU: 0 PID: 6711 Comm: syz-executor3 Not tainted 4.18.0-rc4+ #43
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> RIP: 0010:__get_vma_policy+0x61/0x160 mm/mempolicy.c:1620

Right, my bad. Here's fixup.

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index d508c7844681..12b2b3c7f51e 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -597,6 +597,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
 	pseudo_vma.vm_file = file;
+	pseudo_vma.vm_ops = &anon_vm_ops;

 	for (index = start; index < end; index++) {
 		/*
-- 
 Kirill A. Shutemov
