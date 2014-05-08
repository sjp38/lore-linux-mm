Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9AE6B00E0
	for <linux-mm@kvack.org>; Thu,  8 May 2014 05:39:58 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so2541714pab.19
        for <linux-mm@kvack.org>; Thu, 08 May 2014 02:39:58 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id of4si247594pbb.148.2014.05.08.02.39.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 08 May 2014 02:39:57 -0700 (PDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N5900J8C1IJ7W10@mailout4.samsung.com> for linux-mm@kvack.org;
 Thu, 08 May 2014 18:39:55 +0900 (KST)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: quoted-printable
Message-id: <1399541860.13268.48.camel@kjgkr>
Subject: Re: [BUG] kmemleak on __radix_tree_preload
From: Jaegeuk Kim <jaegeuk.kim@samsung.com>
Reply-to: jaegeuk.kim@samsung.com
Date: Thu, 08 May 2014 18:37:40 +0900
In-reply-to: <20140508092646.GA17349@arm.com>
References: <1398390340.4283.36.camel@kjgkr> <20140501170610.GB28745@arm.com>
 <20140501184112.GH23420@cmpxchg.org> <1399431488.13268.29.camel@kjgkr>
 <20140507113928.GB17253@arm.com> <1399540611.13268.45.camel@kjgkr>
 <20140508092646.GA17349@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2014-05-08 (=EB=AA=A9), 10:26 +0100, Catalin Marinas:
> On Thu, May 08, 2014 at 06:16:51PM +0900, Jaegeuk Kim wrote:
> > 2014-05-07 (=EC=88=98), 12:39 +0100, Catalin Marinas:
> > > On Wed, May 07, 2014 at 03:58:08AM +0100, Jaegeuk Kim wrote:
> > > > unreferenced object 0xffff880004226da0 (size 576):
> > > >   comm "fsstress", pid 14590, jiffies 4295191259 (age 706.308s)
> > > >   hex dump (first 32 bytes):
> > > >     01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
> > > >     50 89 34 81 ff ff ff ff b8 6d 22 04 00 88 ff ff  P.4......m".....
> > > >   backtrace:
> > > >     [<ffffffff816c02e8>] kmemleak_update_trace+0x58/0x80
> > > >     [<ffffffff81349517>] radix_tree_node_alloc+0x77/0xa0
> > > >     [<ffffffff81349718>] __radix_tree_create+0x1d8/0x230
> > > >     [<ffffffff8113286c>] __add_to_page_cache_locked+0x9c/0x1b0
> > > >     [<ffffffff811329a8>] add_to_page_cache_lru+0x28/0x80
> > > >     [<ffffffff81132f58>] grab_cache_page_write_begin+0x98/0xf0
> > > >     [<ffffffffa02e4bf4>] f2fs_write_begin+0xb4/0x3c0 [f2fs]
> > > >     [<ffffffff81131b77>] generic_perform_write+0xc7/0x1c0
> > > >     [<ffffffff81133b7d>] __generic_file_aio_write+0x1cd/0x3f0
> > > >     [<ffffffff81133dfe>] generic_file_aio_write+0x5e/0xe0
> > > >     [<ffffffff81195c5a>] do_sync_write+0x5a/0x90
> > > >     [<ffffffff811968d2>] vfs_write+0xc2/0x1d0
> > > >     [<ffffffff81196daf>] SyS_write+0x4f/0xb0
> > > >     [<ffffffff816dead2>] system_call_fastpath+0x16/0x1b
> > > >     [<ffffffffffffffff>] 0xffffffffffffffff
> > > 
> > > OK, it shows that the allocation happens via add_to_page_cache_locked()
> > > and I guess it's page_cache_tree_insert() which calls
> > > __radix_tree_create() (the latter reusing the preloaded node). I'm not
> > > familiar enough to this code (radix-tree.c and filemap.c) to tell where
> > > the node should have been freed, who keeps track of it.
> > > 
> > > At a quick look at the hex dump (assuming that the above leak is struct
> > > radix_tree_node):
> > > 
> > > 	.path =3D 1
> > > 	.count =3D -0x7f (or 0xffffff81 as unsigned int)
> > > 	union {
> > > 		{
> > > 			.parent =3D NULL
> > > 			.private_data =3D 0xffffffff81348950
> > > 		}
> > > 		{
> > > 			.rcu_head.next =3D NULL
> > > 			.rcu_head.func =3D 0xffffffff81348950
> > > 		}
> > > 	}
> > > 
> > > The count is a bit suspicious.
> > > 
> > > From the union, it looks most likely like rcu_head information. Is
> > > radix_tree_node_rcu_free() function at the above rcu_head.func=3F
> 
> Thanks for the config. Could you please confirm that 0xffffffff81348950
> address corresponds to the radix_tree_node_rcu_free() function in your
> System.map (or something else)=3F

Yap, the address is matched to radix_tree_node_rcu_free().
Thanks,

> 
> > > Also, if you run echo scan > /sys/kernel/debug/kmemleak a few times, do
> > > any of the above leaks disappear (in case the above are some transient
> > > rcu freeing reports; normally this shouldn't happen as the objects are
> > > still referred but I'll look at the relevant code once I have your
> > > .config).
> > 
> > Once I run the echo, the leaks are still remained.
> 
> OK, so they aren't just transient.
> 
> Thanks.
> 

-- 
Jaegeuk Kim
Samsung

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
