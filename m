Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 321046B0006
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 23:55:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y8-v6so5519395pfl.17
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 20:55:19 -0700 (PDT)
Received: from mail.parknet.co.jp (mail.parknet.co.jp. [210.171.160.6])
        by mx.google.com with ESMTP id w31-v6si41141240pla.127.2018.06.07.20.55.17
        for <linux-mm@kvack.org>;
        Thu, 07 Jun 2018 20:55:17 -0700 (PDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [mmotm:master 174/212] fs///fat/inode.c:163:9: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'sector_t {aka long long unsigned int}'
References: <201806080946.h9NeMhUX%fengguang.wu@intel.com>
Date: Fri, 08 Jun 2018 12:54:58 +0900
In-Reply-To: <201806080946.h9NeMhUX%fengguang.wu@intel.com> (kbuild test
	robot's message of "Fri, 8 Jun 2018 09:38:56 +0800")
Message-ID: <87po12aq5p.fsf@mail.parknet.co.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

kbuild test robot <lkp@intel.com> writes:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   7393732bae530daa27567988b91d16ecfeef6c62
> commit: fe3e5c4f07cde4be67152518d21429bfbb875c0c [174/212] fat: use fat_fs_error() instead of BUG_ON() in __fat_get_block()
> config: i386-randconfig-s0-201822-CONFIG_DEBUG_INFO_REDUCED (attached as .config)
> compiler: gcc-6 (Debian 6.4.0-9) 6.4.0 20171026
> reproduce:
>         git checkout fe3e5c4f07cde4be67152518d21429bfbb875c0c
>         # save the attached .config to linux build tree
>         make ARCH=i386 
>
> All warnings (new ones prefixed by >>):
>
>    In file included from fs///fat/inode.c:24:0:
>    fs///fat/inode.c: In function '__fat_get_block':
>>> fs///fat/inode.c:163:9: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'sector_t {aka long long unsigned int}' [-Wformat=]
>             "invalid FAT chain (i_pos %lld, last_block %ld)",
>             ^
>    fs///fat/fat.h:397:24: note: in definition of macro 'fat_fs_error'
>      __fat_fs_error(sb, 1, fmt , ## args)

This is the updated patch to fix this warning. Please update

	fat-use-fat_fs_error-instead-of-bug_on-in-__fat_get_block.patch

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>


[PATCH] fat: Use fat_fs_error() instead of BUG_ON() in __fat_get_block()

If file size and FAT cluster chain is not matched (corrupted image),
we can hit BUG_ON(!phys) in __fat_get_block().

So, use fat_fs_error() instead.

Link: http://lkml.kernel.org/r/874lilcu67.fsf@mail.parknet.co.jp
Signed-off-by: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Reported-by: Anatoly Trosinenko <anatoly.trosinenko@gmail.com>
Tested-by: Anatoly Trosinenko <anatoly.trosinenko@gmail.com>
---

 fs/fat/inode.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff -puN fs/fat/inode.c~vfat-dont-bugon fs/fat/inode.c
--- linux/fs/fat/inode.c~vfat-dont-bugon	2018-06-02 20:15:04.441920069 +0900
+++ linux-hirofumi/fs/fat/inode.c	2018-06-08 12:38:09.891123649 +0900
@@ -158,8 +158,14 @@ static inline int __fat_get_block(struct
 	err = fat_bmap(inode, iblock, &phys, &mapped_blocks, create, false);
 	if (err)
 		return err;
+	if (!phys) {
+		fat_fs_error(sb,
+			     "invalid FAT chain (i_pos %lld, last_block %llu)",
+			     MSDOS_I(inode)->i_pos,
+			     (unsigned long long)last_block);
+		return -EIO;
+	}
 
-	BUG_ON(!phys);
 	BUG_ON(*max_blocks != mapped_blocks);
 	set_buffer_new(bh_result);
 	map_bh(bh_result, sb, phys);
_
