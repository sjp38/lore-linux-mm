Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D1BD96B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 10:11:52 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id d201so73590947qkg.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 07:11:52 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0101.outbound.protection.outlook.com. [104.47.33.101])
        by mx.google.com with ESMTPS id f186si3155185qka.137.2017.02.07.07.11.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 07:11:51 -0800 (PST)
Message-ID: <5899E389.3040801@cs.rutgers.edu>
Date: Tue, 7 Feb 2017 09:11:05 -0600
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in zap_pmd_range()
References: <20170205161252.85004-1-zi.yan@sent.com> <20170205161252.85004-4-zi.yan@sent.com> <20170207141956.GA4789@node.shutemov.name>
In-Reply-To: <20170207141956.GA4789@node.shutemov.name>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="------------enigC6A69F5AE405986FE8731EA4"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Zi Yan <zi.yan@sent.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <ziy@nvidia.com>

--------------enigC6A69F5AE405986FE8731EA4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Kirill,

Kirill A. Shutemov wrote:
> On Sun, Feb 05, 2017 at 11:12:41AM -0500, Zi Yan wrote:
>> From: Zi Yan <ziy@nvidia.com>
>>
>> Originally, zap_pmd_range() checks pmd value without taking pmd lock.
>> This can cause pmd_protnone entry not being freed.
>>
>> Because there are two steps in changing a pmd entry to a pmd_protnone
>> entry. First, the pmd entry is cleared to a pmd_none entry, then,
>> the pmd_none entry is changed into a pmd_protnone entry.
>> The racy check, even with barrier, might only see the pmd_none entry
>> in zap_pmd_range(), thus, the mapping is neither split nor zapped.
>=20
> Okay, this only can happen to MADV_DONTNEED as we hold
> down_write(mmap_sem) for the rest of zap_pmd_range() and whoever modifi=
es
> page tables has to hold at least down_read(mmap_sem) or exclude paralle=
l
> modification in other ways.
>=20
> See 1a5a9906d4e8 ("mm: thp: fix pmd_bad() triggering in code paths hold=
ing
> mmap_sem read mode") for more details.
>=20
> +Andrea.
>=20
>> Later, in free_pmd_range(), pmd_none_or_clear() will see the
>> pmd_protnone entry and clear it as a pmd_bad entry. Furthermore,
>> since the pmd_protnone entry is not properly freed, the corresponding
>> deposited pte page table is not freed either.
>=20
> free_pmd_range() should be fine: we only free page tables after vmas go=
ne
> (under down_write(mmap_sem() in exit_mmap() and unmap_region()) or afte=
r
> pagetables moved (under down_write(mmap_sem) in shift_arg_pages()).

The leaked page is not pmd page tables, but a PTE page table that is in
pmd_page_table_page->pmd_huge_pte. If a pmd_protnone does not go into
__split_huge_pmd() nor zap_huge_pmd(), the corresponding deposited PTE
page table, put into the list via pgtable_trans_huge_deposit(), will not
be taken out via pgtable_trans_huge_withdraw().

Then, when the kernel at the end of free_pmd_range() is trying to call
pgtable_pmd_page_dtor()  in pmd_free_tlb(), it will encounter
VM_BUG_ON_PAGE(page->pmd_huge_pte, page). Either the kernel crashes or
it leaks a page.


>=20
>> This causes memory leak or kernel crashing, if VM_BUG_ON() is enabled.=

>=20
> The problem is that numabalancing calls change_huge_pmd() under
> down_read(mmap_sem), not down_write(mmap_sem) as the rest of users do.
> It makes numabalancing the only code path beyond page fault that can tu=
rn
> pmd_none() into pmd_trans_huge() under down_read(mmap_sem).
>=20
> This can lead to race when MADV_DONTNEED miss THP. That's not critical =
for
> pagefault vs. MADV_DONTNEED race as we will end up with clear page in t=
hat
> case. Not so much for change_huge_pmd().
>=20
> Looks like we need pmdp_modify() or something to modify protection bits=

> inplace, without clearing pmd.
>=20
> Not sure how to get crash scenario.
>=20
> BTW, Zi, have you observed the crash? Or is it based on code inspection=
?
> Any backtraces?

The problem should be very rare in the upstream kernel. I discover the
problem in my customized kernel which does very frequent page migration
and uses numa_protnone.

The crash scenario I guess is like:
1. A huge page pmd entry is in the middle of being changed into either a
pmd_protnone or a pmd_migration_entry. It is cleared to pmd_none.

2. At the same time, the application frees the vma this page belongs to.

3. zap_pmd_range() only see pmd_none in
"if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))",
it might catch pmd_protnone in
"if (pmd_none_or_trans_huge_or_clear_bad(pmd))". But nothing is done for
it. So the deposited PTE page table page associated with the huge pmd
entry is not withdrawn.

4. free_pmd_range() calls pmd_free_tlb() and in pgtable_pmd_page_dtor(),
VM_BUG_ON_PAGE(page->pmd_huge_pte, page) is triggered.

The crash log (you will see a pmd_migration_entry is regarded as bad
pmd, which should not be. I also saw pmd_protnone before.):

[ 1945.978677] mm/pgtable-generic.c:33: bad pmd
ffff8f07b13c1b90(0000004fed803c00)
                 ^^^^^^^^^^^^^^^^ a pmd migration entry

[ 1946.964974] page:fffffd1dd0c4f040 count:1 mapcount:-511 mapping:
     (null) index:0x0
[ 1946.974265] flags: 0x6ffff0000000000()
[ 1946.978486] raw: 06ffff0000000000 0000000000000000 0000000000000000
00000001fffffe00
[ 1946.987202] raw: dead000000000100 fffffd1dd0c45c80 ffff8f07aa38e340
ffff8efdca466678
[ 1946.995927] page dumped because: VM_BUG_ON_PAGE(page->pmd_huge_pte)
[ 1947.002984] page->mem_cgroup:ffff8efdca466678
[ 1947.007927] ------------[ cut here ]------------
[ 1947.013123] kernel BUG at ./include/linux/mm.h:1733!
[ 1947.018706] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[ 1947.024774] Modules linked in: ipt_MASQUERADE nf_nat_masquerade_ipv4
iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
xt_conntrack nf_conntrack intel_rapl sb_edac edac_corei
[ 1947.077814] CPU: 19 PID: 3303 Comm: python Not tainted
4.10.0-rc5-page-migration+ #283
[ 1947.086721] Hardware name: Dell Inc. PowerEdge R530/0HFG24, BIOS
1.5.4 10/05/2015
[ 1947.095140] task: ffff8f07a5870040 task.stack: ffffc37d64adc000
[ 1947.101796] RIP: 0010:___pmd_free_tlb+0x83/0x90
[ 1947.106890] RSP: 0018:ffffc37d64adfce8 EFLAGS: 00010282
[ 1947.112762] RAX: 0000000000000021 RBX: ffffc37d64adfe10 RCX:
0000000000000000
[ 1947.120770] RDX: 0000000000000000 RSI: ffff8f07c224dea8 RDI:
ffff8f07c224dea8
[ 1947.128809] RBP: ffffc37d64adfcf8 R08: 0000000000000001 R09:
0000000000000000
[ 1947.136818] R10: 000000000000000f R11: 0000000000000001 R12:
fffffd1dd0c4f040
[ 1947.144825] R13: 00007fae2d7fd000 R14: ffff8f07b13c1b60 R15:
ffffc37d64adfe10
[ 1947.152832] FS:  00007fafbcce6700(0000) GS:ffff8f07c2240000(0000)
knlGS:0000000000000000
[ 1947.161934] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1947.168380] CR2: 00007fafeb851188 CR3: 0000001432184000 CR4:
00000000001406e0
[ 1947.176393] Call Trace:
[ 1947.179160]  free_pgd_range+0x487/0x5d0
[ 1947.183476]  free_pgtables+0xc4/0x120
[ 1947.187593]  unmap_region+0xe1/0x130
[ 1947.191620]  do_munmap+0x273/0x400
[ 1947.195452]  SyS_munmap+0x53/0x70
[ 1947.199190]  entry_SYSCALL_64_fastpath+0x23/0xc6
[ 1947.204382] RIP: 0033:0x7fafeb59d387
[ 1947.208406] RSP: 002b:00007fafbcce5358 EFLAGS: 00000207 ORIG_RAX:
000000000000000b
[ 1947.216924] RAX: ffffffffffffffda RBX: 00007faf2c0b6780 RCX:
00007fafeb59d387
[ 1947.224933] RDX: 00007fae247fc030 RSI: 0000000009001000 RDI:
00007fae247fc000
[ 1947.232940] RBP: 00007fafbcce5390 R08: 00007faf48f9ed00 R09:
0000000000000100
[ 1947.240947] R10: 0000000000000020 R11: 0000000000000207 R12:
0000000002cf1fc0
[ 1947.248955] R13: 0000000002cf1fc0 R14: 000000000343d530 R15:
00007fafbcce5810
[ 1947.256965] Code: 4c 89 e6 48 89 df e8 0d b5 1a 00 84 c0 74 08 48 89
df e8 91 b4 1a 00 5b 41 5c 5d c3 48 c7 c6 d8 73 c7 b8 4c 89 e7 e8 dd 7b
1a 00 <0f> 0b 48 8b 3d 34 80 d9 00 eb 99 66 90
[ 1947.278200] RIP: ___pmd_free_tlb+0x83/0x90 RSP: ffffc37d64adfce8
[ 1947.285688] ---[ end trace 7864a23976d71e0a ]---

--=20
Best Regards,
Yan Zi


--------------enigC6A69F5AE405986FE8731EA4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJYmeOsAAoJEEGLLxGcTqbMfzYH/2vVa54Od7cYHXwRwsB+d7n8
jnNVf/jRyGeDhq9vf39DLkXdy94klQQy2kr1skWw5iAWx1MnJ3senQ2Hk9VlCBYP
Omm7OAlvHBfrhb7Fk2vjvPN5sq9aH33PL70N+6O7m8LZhB4HNrw0sjmcnjNuYh+E
MWyhWdRjbgukSb6aHDxbq32c0fNOs2yBoYEdUtKlrMn1FSQFlr2NCGx5MKcWLC20
KPdJFbALbB4BIkotrYm/1VpMjGxu5KByjq29EXd3FG8EJzaC7ohWIk6IYqTebdkN
8fuaZ9wpyqwO9UKRootpq0id/C4Btx9893hYWdX74tRS4go3v2OxXscfIR7bVCE=
=3tQH
-----END PGP SIGNATURE-----

--------------enigC6A69F5AE405986FE8731EA4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
