Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id AE0466B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 11:59:32 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so100069858pab.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 08:59:32 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id tl10si2997737pac.177.2016.01.26.08.59.31
        for <linux-mm@kvack.org>;
        Tue, 26 Jan 2016 08:59:31 -0800 (PST)
From: "Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: mm: WARNING in __delete_from_page_cache
Date: Tue, 26 Jan 2016 16:59:27 +0000
Message-ID: <1453827566.32645.5.camel@intel.com>
References: <CACT4Y+aBnm8VLe5f=AwO2nUoQZaH-UVqUynGB+naAC-zauOQsQ@mail.gmail.com>
	 <20160124230422.GA8439@node.shutemov.name>
	 <20160125122206.GA24938@quack.suse.cz> <1453779754.32645.3.camel@intel.com>
	 <20160126125456.GK2948@linux.intel.com>
	 <20160126133636.GE23820@quack.suse.cz>
In-Reply-To: <20160126133636.GE23820@quack.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <E4D97631F8A25D418AEB8A2614C308AC@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jack@suse.cz" <jack@suse.cz>, "willy@linux.intel.com" <willy@linux.intel.com>
Cc: "syzkaller@googlegroups.com" <syzkaller@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kcc@google.com" <kcc@google.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "dvyukov@google.com" <dvyukov@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "gthelen@google.com" <gthelen@google.com>, "kirill@shutemov.name" <kirill@shutemov.name>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "jack@suse.com" <jack@suse.com>, "glider@google.com" <glider@google.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "j-nomura@ce.jp.nec.com" <j-nomura@ce.jp.nec.com>

On Tue, 2016-01-26 at 14:36 +-0100, Jan Kara wrote:
+AD4- On Tue 26-01-16 07:54:56, Matthew Wilcox wrote:
+AD4- +AD4- On Tue, Jan 26, 2016 at 03:42:34AM +-0000, Williams, Dan J wrot=
e:
+AD4- +AD4- +AD4- +AEAAQA- -2907,7 +-2912,12 +AEAAQA- extern void replace+A=
F8-mount+AF8-options(struct
+AD4- +AD4- +AD4- super+AF8-block +ACo-sb, char +ACo-options)+ADs-
+AD4- +AD4- +AD4- +AKA-
+AD4- +AD4- +AD4- +AKA-static inline bool io+AF8-is+AF8-direct(struct file =
+ACo-filp)
+AD4- +AD4- +AD4- +AKAAew-
+AD4- +AD4- +AD4- -	return (filp-+AD4-f+AF8-flags +ACY- O+AF8-DIRECT) +AHwA=
fA-
+AD4- +AD4- +AD4- IS+AF8-DAX(file+AF8-inode(filp))+ADs-
+AD4- +AD4-=20
+AD4- +AD4- I think this should just be a one-liner:
+AD4- +AD4-=20
+AD4- +AD4- -	return (filp-+AD4-f+AF8-flags +ACY- O+AF8-DIRECT) +AHwAfA-
+AD4- +AD4- IS+AF8-DAX(file+AF8-inode(filp))+ADs-
+AD4- +AD4- +-	return (filp-+AD4-f+AF8-flags +ACY- O+AF8-DIRECT) +AHwAfA- I=
S+AF8-DAX(filp-
+AD4- +AD4- +AD4-f+AF8-mapping-+AD4-host)+ADs-
+AD4- +AD4-=20
+AD4- +AD4- This does the right thing for block device inodes and filesyste=
m
+AD4- +AD4- inodes.
+AD4- +AD4- (see the opening stanzas of +AF8AXw-dax+AF8-fault for an exampl=
e).
+AD4-=20
+AD4- Ah, right. This looks indeed better.
+AD4-=20


Oh, yeah, looks good.

8+ADw----- (git am --scissors)
Subject: fs, block: force direct-I/O for dax-enabled block devices

From: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-

Similar to the file I/O path, re-direct all I/O to the DAX path for I/O
to a block-device special file.+AKAAoA-Both regular files and device specia=
l
files can use the common filp-+AD4-f+AF8-mapping-+AD4-host lookup to determ=
ing is
DAX is enabled.

Otherwise, we confuse the DAX code that does not expect to find live
data in the page cache:

+AKAAoACgAKA-------------+AFs- cut here +AF0-------------
+AKAAoACgAKA-WARNING: CPU: 0 PID: 7676 at mm/filemap.c:217
+AKAAoACgAKAAXwBf-delete+AF8-from+AF8-page+AF8-cache+-0x9f6/0xb60()
+AKAAoACgAKA-Modules linked in:
+AKAAoACgAKA-CPU: 0 PID: 7676 Comm: a.out Not tainted 4.4.0+- +ACM-276
+AKAAoACgAKA-Hardware name: QEMU Standard PC (i440FX +- PIIX, 1996), BIOS B=
ochs 01/01/2011
+AKAAoACgAKAAoA-00000000ffffffff ffff88006d3f7738 ffffffff82999e2d 00000000=
00000000
+AKAAoACgAKAAoA-ffff8800620a0000 ffffffff86473d20 ffff88006d3f7778 ffffffff=
81352089
+AKAAoACgAKAAoA-ffffffff81658d36 ffffffff86473d20 00000000000000d9 ffffea00=
00009d60
+AKAAoACgAKA-Call Trace:
+AKAAoACgAKAAoABbADwAoACgAKAAoACg-inline+AKAAoACgAKAAoAA+AF0- +AF8AXw-dump+=
AF8-stack lib/dump+AF8-stack.c:15
+AKAAoACgAKAAoABbADw-ffffffff82999e2d+AD4AXQ- dump+AF8-stack+-0x6f/0xa2 lib=
/dump+AF8-stack.c:50
+AKAAoACgAKAAoABbADw-ffffffff81352089+AD4AXQ- warn+AF8-slowpath+AF8-common+=
-0xd9/0x140 kernel/panic.c:482
+AKAAoACgAKAAoABbADw-ffffffff813522b9+AD4AXQ- warn+AF8-slowpath+AF8-null+-0=
x29/0x30 kernel/panic.c:515
+AKAAoACgAKAAoABbADw-ffffffff81658d36+AD4AXQ- +AF8AXw-delete+AF8-from+AF8-p=
age+AF8-cache+-0x9f6/0xb60 mm/filemap.c:217
+AKAAoACgAKAAoABbADw-ffffffff81658fb2+AD4AXQ- delete+AF8-from+AF8-page+AF8-=
cache+-0x112/0x200 mm/filemap.c:244
+AKAAoACgAKAAoABbADw-ffffffff818af369+AD4AXQ- +AF8AXw-dax+AF8-fault+-0x859/=
0x1800 fs/dax.c:487
+AKAAoACgAKAAoABbADw-ffffffff8186f4f6+AD4AXQ- blkdev+AF8-dax+AF8-fault+-0x2=
6/0x30 fs/block+AF8-dev.c:1730
+AKAAoACgAKAAoABbADwAoACgAKAAoACg-inline+AKAAoACgAKAAoAA+AF0- wp+AF8-pfn+AF=
8-shared mm/memory.c:2208
+AKAAoACgAKAAoABbADw-ffffffff816e9145+AD4AXQ- do+AF8-wp+AF8-page+-0xc85/0x1=
4f0 mm/memory.c:2307
+AKAAoACgAKAAoABbADwAoACgAKAAoACg-inline+AKAAoACgAKAAoAA+AF0- handle+AF8-pt=
e+AF8-fault mm/memory.c:3323
+AKAAoACgAKAAoABbADwAoACgAKAAoACg-inline+AKAAoACgAKAAoAA+AF0- +AF8AXw-handl=
e+AF8-mm+AF8-fault mm/memory.c:3417
+AKAAoACgAKAAoABbADw-ffffffff816ecec3+AD4AXQ- handle+AF8-mm+AF8-fault+-0x24=
83/0x4640 mm/memory.c:3446
+AKAAoACgAKAAoABbADw-ffffffff8127eff6+AD4AXQ- +AF8AXw-do+AF8-page+AF8-fault=
+-0x376/0x960 arch/x86/mm/fault.c:1238
+AKAAoACgAKAAoABbADw-ffffffff8127f738+AD4AXQ- trace+AF8-do+AF8-page+AF8-fau=
lt+-0xe8/0x420 arch/x86/mm/fault.c:1331
+AKAAoACgAKAAoABbADw-ffffffff812705c4+AD4AXQ- do+AF8-async+AF8-page+AF8-fau=
lt+-0x14/0xd0 arch/x86/kernel/kvm.c:264
+AKAAoACgAKAAoABbADw-ffffffff86338f78+AD4AXQ- async+AF8-page+AF8-fault+-0x2=
8/0x30 arch/x86/entry/entry+AF8-64.S:986
+AKAAoACgAKAAoABbADw-ffffffff86336c36+AD4AXQ- entry+AF8-SYSCALL+AF8-64+AF8-=
fastpath+-0x16/0x7a
+AKAAoACgAKA-arch/x86/entry/entry+AF8-64.S:185
+AKAAoACgAKA----+AFs- end trace dae21e0f85f1f98c +AF0----

Cc: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+AD4-
Fixes: 5a023cdba50c (+ACI-block: enable dax for raw block devices+ACI-)
Reported-by: Dmitry Vyukov +ADw-dvyukov+AEA-google.com+AD4-
Reported-by: Kirill A. Shutemov +ADw-kirill+AEA-shutemov.name+AD4-
Suggested-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
Reviewed-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
Suggested-by: Matthew Wilcox +ADw-willy+AEA-linux.intel.com+AD4-
Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
---
+AKA-include/linux/fs.h +AHwAoACgAKAAoA-2 +--
+AKA-1 file changed, 1 insertion(+-), 1 deletion(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1a2046275cdf..b10002d4a5f5 100644
--- a/include/linux/fs.h
+-+-+- b/include/linux/fs.h
+AEAAQA- -2907,7 +-2907,7 +AEAAQA- extern void replace+AF8-mount+AF8-option=
s(struct super+AF8-block +ACo-sb, char +ACo-options)+ADs-
+AKA-
+AKA-static inline bool io+AF8-is+AF8-direct(struct file +ACo-filp)
+AKAAew-
-	return (filp-+AD4-f+AF8-flags +ACY- O+AF8-DIRECT) +AHwAfA- IS+AF8-DAX(fil=
e+AF8-inode(filp))+ADs-
+-	return (filp-+AD4-f+AF8-flags +ACY- O+AF8-DIRECT) +AHwAfA- IS+AF8-DAX(fi=
lp-+AD4-f+AF8-mapping-+AD4-host)+ADs-
+AKAAfQ-
+AKA-
+AKA-static inline int iocb+AF8-flags(struct file +ACo-file)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
