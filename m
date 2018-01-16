Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB8926B0268
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 12:33:31 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 79so15543760ion.20
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 09:33:31 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u65si2468532ith.164.2018.01.16.09.33.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 09:33:29 -0800 (PST)
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201801142054.FAD95378.LVOOFQJOFtMFSH@I-love.SAKURA.ne.jp>
	<CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
	<201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
	<CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
In-Reply-To: <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
Message-Id: <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
Date: Wed, 17 Jan 2018 02:33:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, dave.hansen@linux.intel.com, mingo@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-fsdevel@vger.kernel.org, mhocko@kernel.org

Linus Torvalds wrote:
> On Mon, Jan 15, 2018 at 5:15 PM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >
> > I can't reproduce this with CONFIG_FLATMEM=y . But I'm not sure whether
> > we are hitting a bug in CONFIG_SPARSEMEM=y code, for the bug is highly
> > timing dependent.
> 
> Hmm. Maybe. But sparsemem really also generates *much* more complex
> code particularly for the pfn_to_page() case.

Since I got a faster reproducer, I tried full bisection between 4.11 and 4.12-rc1.
But I have no idea why bisection arrives at c0332694903a37cf.

----------
gcc -Wall -O3 -m32 -o /mnt/a.out -x c - << "EOF"
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
        if (argc != 1) {
                unsigned long long size;
                char *buf = NULL;
                unsigned long long i;
                for (size = 1048576; size < 512ULL * (1 << 30); size += 1048576) {
                        char *cp = realloc(buf, size);
                        if (!cp) {
                                size -= 1048576;
                                break;
                        }
                        buf = cp;
                }
                for (i = 0; i < size; i += 4096)
                        buf[i] = 0;
                _exit(0);
        } else
                while (1) {
                        if (fork() == 0) {
                                execlp(argv[0], argv[0], "", NULL);
                                _exit(0);
                        }
                        sleep(1);
                }
        return 0;
}
EOF
----------

----------
# bad: [2ea659a9ef488125eb46da6eb571de5eae5c43f6] Linux 4.12-rc1
# good: [a351e9b9fc24e982ec2f0e76379a49826036da12] Linux 4.11
git bisect start 'HEAD' 'v4.11'
# good: [221656e7c4ce342b99c31eca96c1cbb6d1dce45f] Merge tag 'sound-4.12-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect good 221656e7c4ce342b99c31eca96c1cbb6d1dce45f
# good: [c6a677c6f37bb7abc85ba7e3465e82b9f7eb1d91] Merge tag 'staging-4.12-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging
git bisect good c6a677c6f37bb7abc85ba7e3465e82b9f7eb1d91
# bad: [0ff4c01b279a590a2826ade9321ad8c7ca5a1b6c] Merge tag 'armsoc-arm64' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
git bisect bad 0ff4c01b279a590a2826ade9321ad8c7ca5a1b6c
# bad: [8f3207c7eab9d885cc64c778416537034a7d9c5b] Merge tag 'tty-4.12-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty
git bisect bad 8f3207c7eab9d885cc64c778416537034a7d9c5b
# bad: [9c6ee01ed5bb1ee489d580eaa60d7eb5a8ede336] Merge branch 'for-linus' of git://git.armlinux.org.uk/~rmk/linux-arm
git bisect bad 9c6ee01ed5bb1ee489d580eaa60d7eb5a8ede336
# bad: [fe7a719b30dfdb4d55680461954b99b257ebe671] Merge branch 'for-next' of git://git.samba.org/sfrench/cifs-2.6
git bisect bad fe7a719b30dfdb4d55680461954b99b257ebe671
# good: [d557d1b58b3546bab2c5bc2d624c5709840e6b10] refcount: change EXPORT_SYMBOL markings
git bisect good d557d1b58b3546bab2c5bc2d624c5709840e6b10
# good: [8f720d9f892e0e223dab8400f03130bc208c72e7] xfs: publish UUID in struct super_block
git bisect good 8f720d9f892e0e223dab8400f03130bc208c72e7
# bad: [d173a25165c124442182f6b21d0c2ec381a0eebe] blk-mq: move debugfs declarations to a separate header file
git bisect bad d173a25165c124442182f6b21d0c2ec381a0eebe
# bad: [2719aa217e0d025dbfce74ac777815776ccec072] blk-mq: don't use sync workqueue flushing from drivers
git bisect bad 2719aa217e0d025dbfce74ac777815776ccec072
# bad: [9f2779bff2f178496fb00b89797734ee245d2c93] blk-mq-sched: remove hack that bypasses scheduler for reserved requests
git bisect bad 9f2779bff2f178496fb00b89797734ee245d2c93
# bad: [8afdd94c74e416de74a8ee61d79e4bf93466420b] mtip32xx: kill atomic argument to mtip_quiesce_io()
git bisect bad 8afdd94c74e416de74a8ee61d79e4bf93466420b
# bad: [0f6422a2c57c6afcf66ead903dc3fa6641184aa4] mtip32xx: get rid of 'atomic' argument to mtip_exec_internal_command()
git bisect bad 0f6422a2c57c6afcf66ead903dc3fa6641184aa4
# bad: [c0332694903a37cf8ecdc9102d5c9e09cf8643d0] block: Remove elevator_change()
git bisect bad c0332694903a37cf8ecdc9102d5c9e09cf8643d0
# first bad commit: [c0332694903a37cf8ecdc9102d5c9e09cf8643d0] block: Remove elevator_change()
----------

I tried different routes from mm/sparse.c , but I feel I can't find the culprit.

----------
# bad: [7660a6fddcbae344de8583aa4092071312f110c3] mm: allow slab_nomerge to be set at build time
# good: [60a7a88dbb9fc9adcca78a10a3ecf36966b5a45c] mm/sparse: refine usemap_size() a little
git bisect start '7660a6fddcbae344de8583aa4092071312f110c3' '60a7a88dbb9fc9adcca78a10a3ecf36966b5a45c'
# bad: [9786e34e0a6055dbd1b46e16dfa791ac2b3da289] Merge tag 'for-linus-20170510' of git://git.infradead.org/linux-mtd
git bisect bad 9786e34e0a6055dbd1b46e16dfa791ac2b3da289
# good: [1062ae4982cabbf60f89b4e069fbb7def7edc8f7] Merge tag 'drm-forgot-about-tegra-for-v4.12-rc1' of git://people.freedesktop.org/~airlied/linux
git bisect good 1062ae4982cabbf60f89b4e069fbb7def7edc8f7
# bad: [bf5f89463f5b3109a72ed13ca62b57e90213387d] Merge branch 'akpm' (patches from Andrew)
git bisect bad bf5f89463f5b3109a72ed13ca62b57e90213387d
# good: [2b0d92b265324cfe42839a23cb46677bb0112c2c] staging: ks7010: remove cast from netdev_priv()
git bisect good 2b0d92b265324cfe42839a23cb46677bb0112c2c
# bad: [d484467c860dab3e17893d23b2238e1f581460fa] Merge tag 'xfs-4.12-merge-7' of git://git.kernel.org/pub/scm/fs/xfs/xfs-linux
git bisect bad d484467c860dab3e17893d23b2238e1f581460fa
# good: [e8357cdec3d1b6b42566ce3bc960e5e10c2b3787] [media] media: stk1160: Add Kconfig help on snd-usb-audio requirement
git bisect good e8357cdec3d1b6b42566ce3bc960e5e10c2b3787
# good: [53ef7d0e208fa38c3f63d287e0c3ab174f1e1235] Merge tag 'libnvdimm-for-4.12' of git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm
git bisect good 53ef7d0e208fa38c3f63d287e0c3ab174f1e1235
# good: [044f1daaaaf7c86bc4fcf433848b7baae236946b] Merge branch 'for-linus' of git://git.kernel.dk/linux-block
git bisect good 044f1daaaaf7c86bc4fcf433848b7baae236946b
# good: [bf8eadbacb24e321c99bbdd901589942712810d1] xfs: remove xfs_bmap_remap_alloc
git bisect good bf8eadbacb24e321c99bbdd901589942712810d1
# good: [e2a641922a3592b5ea226624d5abeb13eb49622c] xfs: corruption needs to respect endianess too!
git bisect good e2a641922a3592b5ea226624d5abeb13eb49622c
# good: [3c3781951c9a155a56e5eed567349118374cc315] xfs: Allow user to kill fstrim process
git bisect good 3c3781951c9a155a56e5eed567349118374cc315
# good: [ae2c4ac2dd39b23a87ddb14ceddc3f2872c6aef5] xfs: update ag iterator to support wait on new inodes
git bisect good ae2c4ac2dd39b23a87ddb14ceddc3f2872c6aef5
# good: [fe0be23e68200573de027de9b8cc2b27e7fce35e] xfs: reserve enough blocks to handle btree splits when remapping
git bisect good fe0be23e68200573de027de9b8cc2b27e7fce35e
# good: [161f55efba5ddccc690139fae9373cafc3447a97] xfs: fix use-after-free in xfs_finish_page_writeback
git bisect good 161f55efba5ddccc690139fae9373cafc3447a97
# first bad commit: [d484467c860dab3e17893d23b2238e1f581460fa] Merge tag 'xfs-4.12-merge-7' of git://git.kernel.org/pub/scm/fs/xfs/xfs-linux



# bad: [7660a6fddcbae344de8583aa4092071312f110c3] mm: allow slab_nomerge to be set at build time
# good: [60a7a88dbb9fc9adcca78a10a3ecf36966b5a45c] mm/sparse: refine usemap_size() a little
git bisect start 'HEAD' '60a7a88dbb9fc9adcca78a10a3ecf36966b5a45c' 'mm/'
# bad: [499118e966f1d2150bd66647c8932343c4e9a0b8] mm: introduce memalloc_noreclaim_{save,restore}
git bisect bad 499118e966f1d2150bd66647c8932343c4e9a0b8
# good: [5e82cd120382ad7bbcc82298e34a034538b4384c] kasan: introduce helper functions for determining bug type
git bisect good 5e82cd120382ad7bbcc82298e34a034538b4384c
# bad: [f25ba6dccc3bfe7e1524f4498a171be038507c45] mm, compaction: reorder fields in struct compact_control
git bisect bad f25ba6dccc3bfe7e1524f4498a171be038507c45
# good: [b19385993623c1a18a686b6b271cd24d5aa96f52] kasan: separate report parts by empty lines
git bisect good b19385993623c1a18a686b6b271cd24d5aa96f52
# good: [ab182e67ec99ea0c8d7435a32a4a1ed9bb02559a] Merge tag 'arm64-upstream' of git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux
git bisect good ab182e67ec99ea0c8d7435a32a4a1ed9bb02559a
# good: [e4231bcda72daef497af45e195a33daa0f9357d0] cma: Introduce cma_for_each_area
git bisect good e4231bcda72daef497af45e195a33daa0f9357d0
# good: [c6a677c6f37bb7abc85ba7e3465e82b9f7eb1d91] Merge tag 'staging-4.12-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging
git bisect good c6a677c6f37bb7abc85ba7e3465e82b9f7eb1d91
# first bad commit: [f25ba6dccc3bfe7e1524f4498a171be038507c45] mm, compaction: reorder fields in struct compact_control
----------

> 
> It also has much less testing. For example, on x86-64 we do use
> sparsemem, but we use the VMEMMAP version of sparsemem: the version
> that does *not* play really odd and complex games with that whole
> pfn_to_page().
> 
> I've always felt like sparsemem was really damn complicated.  The
> whole "section_mem_map" encoding is really subtle and odd.
> 
> And considering that we're getting what appears to be a invalid page,
> in one of the more complicated sequences that very much does that
> whole pfn_to_page(), I really wonder.
> 
> I wonder if somebody could add some VM_BUG_ON() checks to the
> non-vmemmap case of sparsemem in include/asm-generic/memory_model.h.
> 
> Because this:
> 
>   #define __pfn_to_page(pfn)                              \
>   ({      unsigned long __pfn = (pfn);                    \
>           struct mem_section *__sec = __pfn_to_section(__pfn);    \
>           __section_mem_map_addr(__sec) + __pfn;          \
>   })
> 
> is really subtle, and if we have some case where we pass in an
> out-of-range pfn, or some case where we get the section wrong (because
> the pfn is between sections or whatever due to some subtle setup bug),
> things will really go sideways.
> 
> The reason I was hoping you could do this for FLATMEM is that it's
> much easier to verify the pfn range in that case.  The sparsemem cases
> really makes it much nastier.
> 
> That said, all of that code is really old. Most of it goes back to
> -05/06 or so. But since you seem to be able to reproduce at least back
> to 4.8, I guess this bug does back years too.

I feel that the bug in 4.8 is a different one, though the reproducer is the same.

> 
> But I'm adding Dave Hansen explicitly to the cc, in case he has any
> ideas. Not because I blame him, but he's touched the sparsemem code
> fairly recently, so maybe he'd have some idea on adding sanity
> checking to the sparsemem version of pfn_to_page().
> 
> > I dont know why but selecting CONFIG_FLATMEM=y seems to avoid a different bug
> > where bootup of qemu randomly fails at
> 
> Hmm. That looks very different indeed. But if CONFIG_SPARSEMEM
> (presumably together with HIGHMEM) has some odd off-by-one corner case
> or similar, who knows *what* issues it could trigger.

It turned out that CONFIG_FLATMEM was irrelevant. I just did not hit it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
