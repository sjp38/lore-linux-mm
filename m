Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CCB58E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 12:06:12 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so39917013qka.7
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 09:06:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s188si83683qkh.260.2019.01.03.09.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 09:06:11 -0800 (PST)
Date: Thu, 3 Jan 2019 12:06:09 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <495081357.93179893.1546535169172.JavaMail.zimbra@redhat.com>
In-Reply-To: <1808265696.93134171.1546519652798.JavaMail.zimbra@redhat.com>
References: <1323128903.93005102.1546461004635.JavaMail.zimbra@redhat.com> <6e608107-e071-90c0-bd73-4215325433c1@oracle.com> <dc056866-0e60-6ffa-54d5-5cafa1a4a53f@oracle.com> <1808265696.93134171.1546519652798.JavaMail.zimbra@redhat.com>
Subject: Re: [bug] problems with migration of huge pages with
 v4.20-10214-ge1ef035d272e
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, kirill shutemov <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, ltp@lists.linux.it, mhocko@kernel.org, Rachel Sibley <rasibley@redhat.com>, hughd@google.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, aneesh kumar <aneesh.kumar@linux.vnet.ibm.com>, dave@stgolabs.net, prakash sangappa <prakash.sangappa@oracle.com>, colin king <colin.king@canonical.com>



----- Original Message -----
<snip>

> > That commit does cause BUGs for migration and page poisoning of anon hu=
ge
> > pages.  The patch was trying to take care of i_mmap_rwsem locking outsi=
de
> > try_to_unmap infrastructure.  This is because try_to_unmap will take th=
e
> > semaphore in read mode (for file mappings) and we really need it to be
> > taken in write mode.
> >=20
> > The patch below continues to take the semaphore outside try_to_unmap fo=
r
> > the file mapping case.  For anon mappings, the locking is done as a spe=
cial
> > case in try_to_unmap_one.  This is something I was trying to avoid as i=
t
> > it harder to follow/understand.  Any suggestions on how to restructure =
this
> > or make it more clear are welcome.
> >=20
> > Adding Andrew on Cc as he already sent the commit causing the BUGs
> > upstream.
> >=20
> > From: Mike Kravetz <mike.kravetz@oracle.com>
> >=20
> > hugetlbfs: fix migration and poisoning of anon huge pages
> >=20
> > Expanded use of i_mmap_rwsem for pmd sharing synchronization incorrectl=
y
> > used page_mapping() of anon huge pages to get to address_space
> > i_mmap_rwsem.  Since page_mapping() is NULL for pages of anon mappings,
> > an "unable to handle kernel NULL pointer" BUG would occur with stack
> > similar to:
> >=20
> > RIP: 0010:down_write+0x1b/0x40
> > Call Trace:
> >  migrate_pages+0x81f/0xb90
> >  __ia32_compat_sys_migrate_pages+0x190/0x190
> >  do_move_pages_to_node.isra.53.part.54+0x2a/0x50
> >  kernel_move_pages+0x566/0x7b0
> >  __x64_sys_move_pages+0x24/0x30
> >  do_syscall_64+0x5b/0x180
> >  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> >=20
> > To fix, only use page_mapping() for non-anon or file pages.  For anon
> > pages wait until we find a vma in which the page is mapped and get the
> > address_space from vm_file.
> >=20
> > Fixes: b43a99900559 ("hugetlbfs: use i_mmap_rwsem for more pmd sharing
> > synchronization")
> > Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>=20
> Mike,
>=20
> 1) with LTP move_pages12 (MAP_PRIVATE version of reproducer)
> Patch below fixes the panic for me.
> It didn't apply cleanly to latest master, but conflicts were easy to reso=
lve.
>=20
> 2) with MAP_SHARED version of reproducer
> It still hangs in user-space.
> v4.19 kernel appears to work fine so I've started a bisect.

My bisect with MAP_SHARED version arrived at same 2 commits:
  c86aa7bbfd55 hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race
  b43a99900559 hugetlbfs: use i_mmap_rwsem for more pmd sharing synchroniza=
tion

Maybe a deadlock between page lock and mapping->i_mmap_rwsem?

thread1:
  hugetlbfs_evict_inode
    i_mmap_lock_write(mapping);
    remove_inode_hugepages
      lock_page(page);

thread2:
  __unmap_and_move
    trylock_page(page) / lock_page(page)
      remove_migration_ptes
        rmap_walk_file
          i_mmap_lock_read(mapping);

Here's strace output:
<snip>
1196  11:27:16 mmap(NULL, 4194304, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_ANO=
NYMOUS|MAP_HUGETLB, -1, 0) =3D 0x7f646c400000
1197  11:27:16 set_robust_list(0x7f646d5b0e60, 24) =3D 0
1197  11:27:16 getppid()                =3D 1196
1197  11:27:16 move_pages(1196, 1024, [0x7f646c400000, 0x7f646c401000, 0x7f=
646c402000, 0x7f646c403000, 0x7f646c404000, 0x7f646c405000, 0x7f646c406000,=
 0x7f646c407000, 0x7f646c408000, 0x7f646c409000, 0x7f646c40a000, 0x7f646c40=
b000, 0x7f646c40c000, 0x7f646c40d000, 0x7f646c40e000, 0x7f646c40f000, 0x7f6=
46c410000, 0x7f646c411000, 0x7f646c412000, 0x7f646c413000, 0x7f646c414000, =
0x7f646c415000, 0x7f646c416000, 0x7f646c417000, 0x7f646c418000, 0x7f646c419=
000, 0x7f646c41a000, 0x7f646c41b000, 0x7f646c41c000, 0x7f646c41d000, 0x7f64=
6c41e000, 0x7f646c41f000, ...], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, =
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...], [-ENOENT, -ENOE=
NT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT,=
 -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -E=
NOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOE=
NT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, ...], MPOL_MF_MOVE_ALL) =
=3D 0
1197  11:27:16 move_pages(1196, 1024, [0x7f646c400000, 0x7f646c401000, 0x7f=
646c402000, 0x7f646c403000, 0x7f646c404000, 0x7f646c405000, 0x7f646c406000,=
 0x7f646c407000, 0x7f646c408000, 0x7f646c409000, 0x7f646c40a000, 0x7f646c40=
b000, 0x7f646c40c000, 0x7f646c40d000, 0x7f646c40e000, 0x7f646c40f000, 0x7f6=
46c410000, 0x7f646c411000, 0x7f646c412000, 0x7f646c413000, 0x7f646c414000, =
0x7f646c415000, 0x7f646c416000, 0x7f646c417000, 0x7f646c418000, 0x7f646c419=
000, 0x7f646c41a000, 0x7f646c41b000, 0x7f646c41c000, 0x7f646c41d000, 0x7f64=
6c41e000, 0x7f646c41f000, ...], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, =
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...], [1, -EACCES, 1,=
 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,=
 1, 1, 1, 1, ...], MPOL_MF_MOVE_ALL) =3D 0
1197  11:27:16 move_pages(1196, 1024, [0x7f646c400000, 0x7f646c401000, 0x7f=
646c402000, 0x7f646c403000, 0x7f646c404000, 0x7f646c405000, 0x7f646c406000,=
 0x7f646c407000, 0x7f646c408000, 0x7f646c409000, 0x7f646c40a000, 0x7f646c40=
b000, 0x7f646c40c000, 0x7f646c40d000, 0x7f646c40e000, 0x7f646c40f000, 0x7f6=
46c410000, 0x7f646c411000, 0x7f646c412000, 0x7f646c413000, 0x7f646c414000, =
0x7f646c415000, 0x7f646c416000, 0x7f646c417000, 0x7f646c418000, 0x7f646c419=
000, 0x7f646c41a000, 0x7f646c41b000, 0x7f646c41c000, 0x7f646c41d000, 0x7f64=
6c41e000, 0x7f646c41f000, ...], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, =
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...],  <unfinished ..=
.>
1196  11:27:16 munmap(0x7f646c400000, 4194304 <unfinished ...>
<hangs>

Regards,
Jan
