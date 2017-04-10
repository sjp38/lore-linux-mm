Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 724EE6B0038
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 08:06:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id m33so16093782wrm.23
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 05:06:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3si11879977wme.93.2017.04.10.05.06.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 05:06:41 -0700 (PDT)
Date: Mon, 10 Apr 2017 14:06:38 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [patch 1/3] mm: protect set_page_dirty() from ongoing truncation
Message-ID: <20170410120638.GD3224@quack2.suse.cz>
References: <1417791166-32226-1-git-send-email-hannes@cmpxchg.org>
 <20170410022230.xe5sukvflvoh4ula@sasha-lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20170410022230.xe5sukvflvoh4ula@sasha-lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.levin@verizon.com
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon 10-04-17 02:22:33, alexander.levin@verizon.com wrote:
> On Fri, Dec 05, 2014 at 09:52:44AM -0500, Johannes Weiner wrote:
> > Tejun, while reviewing the code, spotted the following race condition
> > between the dirtying and truncation of a page:
> >=20
> > __set_page_dirty_nobuffers()       __delete_from_page_cache()
> >   if (TestSetPageDirty(page))
> >                                      page->mapping =3D NULL
> > 				     if (PageDirty())
> > 				       dec_zone_page_state(page, NR_FILE_DIRTY);
> > 				       dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> >     if (page->mapping)
> >       account_page_dirtied(page)
> >         __inc_zone_page_state(page, NR_FILE_DIRTY);
> > 	__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> >=20
> > which results in an imbalance of NR_FILE_DIRTY and BDI_RECLAIMABLE.
> >=20
> > Dirtiers usually lock out truncation, either by holding the page lock
> > directly, or in case of zap_pte_range(), by pinning the mapcount with
> > the page table lock held.  The notable exception to this rule, though,
> > is do_wp_page(), for which this race exists.  However, do_wp_page()
> > already waits for a locked page to unlock before setting the dirty
> > bit, in order to prevent a race where clear_page_dirty() misses the
> > page bit in the presence of dirty ptes.  Upgrade that wait to a fully
> > locked set_page_dirty() to also cover the situation explained above.
> >=20
> > Afterwards, the code in set_page_dirty() dealing with a truncation
> > race is no longer needed.  Remove it.
> >=20
> > Reported-by: Tejun Heo <tj@kernel.org>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: <stable@vger.kernel.org>
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>=20
> Hi Johannes,
>=20
> I'm seeing the following while fuzzing with trinity on linux-next (I've c=
hanged
> the WARN to a VM_BUG_ON_PAGE for some extra page info).

But this looks more like a bug in 9p which allows v9fs_write_end() to dirty
a !Uptodate page?

								Honza

>=20
> [   18.991007] page:ffffea000307c8c0 count:3 mapcount:0 mapping:ffff88010=
444cbf8 index:0x1^M
> [   18.993051] flags: 0x1fffc0000000011(locked|dirty)^M
> [   18.993621] raw: 01fffc0000000011 ffff88010444cbf8 0000000000000001 00=
000003ffffffff^M
> [   18.994522] raw: dead000000000100 dead000000000200 0000000000000000 ff=
ff880109c38008^M                                                           =
          [   18.995418] page dumped because: VM_BUG_ON_PAGE(!PagePrivate(p=
age) && !PageUptodate(page))^M
> [   18.996381] page->mem_cgroup:ffff880109c38008^M                       =
                                                                           =
          [   18.996935] ------------[ cut here ]------------^M            =
                                                                           =
                  [   18.997483] kernel BUG at mm/page-writeback.c:2486!^M =
                                                                           =
                          [   18.998063] invalid opcode: 0000 [#1] SMP DEBU=
G_PAGEALLOC KASAN^M
> [   18.998756] Modules linked in:^M                                      =
                                                                           =
          [   18.999129] CPU: 5 PID: 1388 Comm: trinity-c34 Not tainted 4.1=
1.0-rc5-next-20170407-dirty #12^M                                          =
                  [   19.000117] task: ffff880106ee5d40 task.stack: ffff880=
0c0f40000^M                                                                =
                          [   19.000828] RIP: 0010:__set_page_dirty_nobuffe=
rs (??:?)
> [   19.001491] RSP: 0018:ffff8800c0f47318 EFLAGS: 00010006^M
> [   19.002103] RAX: 0000000000000000 RBX: 1ffff100181e8e67 RCX: 000000000=
0000000^M
> [   19.002929] RDX: 0000000000000021 RSI: 1ffff100181e8da7 RDI: ffffed001=
81e8e58^M
> [   19.004806] RBP: ffff8800c0f47440 R08: 3830303833633930 R09: 313038386=
6666666^M
> [   19.005626] R10: dffffc0000000000 R11: 0000000000001491 R12: ffff8800c=
0f47418^M
> [   19.006452] R13: ffffea000307c8c0 R14: ffff88010444cc10 R15: ffff88010=
444cbf8^M
> [   19.007277] FS:  00007ff6a26fb700(0000) GS:ffff88010a340000(0000) knlG=
S:0000000000000000^M
> [   19.008424] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
> [   19.009092] CR2: 00007ff6a155267c CR3: 00000000cb301000 CR4: 000000000=
00406a0^M
> [   19.009919] Call Trace:^M
> [   19.012266] set_page_dirty (mm/page-writeback.c:2579)
> [   19.020028] v9fs_write_end (fs/9p/vfs_addr.c:325)
> [   19.022473] generic_perform_write (mm/filemap.c:2842)
> [   19.024857] __generic_file_write_iter (mm/filemap.c:2957)
> [   19.025830] generic_file_write_iter (./include/linux/fs.h:702 mm/filem=
ap.c:2985)
> [   19.028549] __do_readv_writev (./include/linux/fs.h:1734 fs/read_write=
=2Ec:696 fs/read_write.c:862)
> [   19.029924] do_readv_writev (fs/read_write.c:895)
> [   19.034044] vfs_writev (fs/read_write.c:921)
> [   19.035223] do_writev (fs/read_write.c:955)
> [   19.036925] SyS_writev (fs/read_write.c:1024)
> [   19.037297] do_syscall_64 (arch/x86/entry/common.c:284)
> [   19.042085] entry_SYSCALL64_slow_path (arch/x86/entry/entry_64.S:249) =
                                                                           =
          [   19.042608] RIP: 0033:0x7ff6a200a8e9^M                        =
                                                                           =
                  [   19.043015] RSP: 002b:00007fff78079608 EFLAGS: 0000024=
6 ORIG_RAX: 0000000000000014^M
> [   19.044253] RAX: ffffffffffffffda RBX: 0000000000000014 RCX: 00007ff6a=
200a8e9^M                                                                  =
          [   19.045045] RDX: 0000000000000001 RSI: 0000000002337d60 RDI: 0=
00000000000018b^M
> [   19.045835] RBP: 00007ff6a2601000 R08: 000000482a1a83cf R09: fffdfffff=
fffffff^M                                                                  =
          [   19.046627] R10: 0012536735f82cf7 R11: 0000000000000246 R12: 0=
000000000000002^M                                                          =
                  [   19.047413] R13: 00007ff6a2601048 R14: 00007ff6a26fb69=
8 R15: 00007ff6a2601000^M                                                  =
                          [ 19.048212] Code: 89 85 f0 fe ff ff e8 39 1b 20 =
00 8b 85 f0 fe ff ff eb 1a e8 2c bd 12 00 31 c0 eb 11 48 c7 c6 e0 c4 47 83 =
4c 89 ef e8 39 44 07 00 <0f> 0b 48 ba 00 00 00 00 00 fc ff df 48 c7 04 13 0=
0 00 00 00 48 ^M                                                           =
                                          All code                         =
                                                                           =
                                                  =3D=3D=3D=3D=3D=3D=3D=3D =
                                                                           =
                                                                           =
  0:   89 85 f0 fe ff ff       mov    %eax,-0x110(%rbp)
>    6:   e8 39 1b 20 00          callq  0x201b44=20
>    b:   8b 85 f0 fe ff ff       mov    -0x110(%rbp),%eax=20
>   11:   eb 1a                   jmp    0x2d=20
>   13:   e8 2c bd 12 00          callq  0x12bd44=20
>   18:   31 c0                   xor    %eax,%eax=20
>   1a:   eb 11                   jmp    0x2d=20
>   1c:   48 c7 c6 e0 c4 47 83    mov    $0xffffffff8347c4e0,%rsi
>   23:   4c 89 ef                mov    %r13,%rdi
>   26:   e8 39 44 07 00          callq  0x74464
>   2b:*  0f 0b                   ud2             <-- trapping instruction
>   2d:   48 ba 00 00 00 00 00    movabs $0xdffffc0000000000,%rdx
>   34:   fc ff df
>   37:   48 c7 04 13 00 00 00    movq   $0x0,(%rbx,%rdx,1)
>   3e:   00
>   3f:   48                      rex.W
>         ...
>=20
> Code starting with the faulting instruction
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>    0:   0f 0b                   ud2
>    2:   48 ba 00 00 00 00 00    movabs $0xdffffc0000000000,%rdx
>    9:   fc ff df
>    c:   48 c7 04 13 00 00 00    movq   $0x0,(%rbx,%rdx,1)
>   13:   00
>   14:   48                      rex.W
>         ...
> [   19.050311] RIP: __set_page_dirty_nobuffers+0x407/0x450 RSP: ffff8800c=
0f47318^M (??:?)
>=20
> --=20
>=20
> Thanks,
> Sasha
--=20
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
