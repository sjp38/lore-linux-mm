Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 423CF6B0038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 02:21:08 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so212543190pad.1
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 23:21:08 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id wp3si59223391pab.160.2015.10.26.23.21.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 26 Oct 2015 23:21:07 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCHv12 26/37] mm: rework mapcount accounting to enable 4k
 mapping of THPs
Date: Tue, 27 Oct 2015 06:18:01 +0000
Message-ID: <20151027061800.GA336@hori1.linux.bs1.fc.nec.co.jp>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-27-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1444145044-72349-27-git-send-email-kirill.shutemov@linux.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F4110747753DEC47A27C4B903188BA0D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Oct 06, 2015 at 06:23:53PM +0300, Kirill A. Shutemov wrote:
> We're going to allow mapping of individual 4k pages of THP compound.
> It means we need to track mapcount on per small page basis.
>
> Straight-forward approach is to use ->_mapcount in all subpages to track
> how many time this subpage is mapped with PMDs or PTEs combined. But
> this is rather expensive: mapping or unmapping of a THP page with PMD
> would require HPAGE_PMD_NR atomic operations instead of single we have
> now.
>
> The idea is to store separately how many times the page was mapped as
> whole -- compound_mapcount. This frees up ->_mapcount in subpages to
> track PTE mapcount.
>
> We use the same approach as with compound page destructor and compound
> order to store compound_mapcount: use space in first tail page,
> ->mapping this time.
>
> Any time we map/unmap whole compound page (THP or hugetlb) -- we
> increment/decrement compound_mapcount. When we map part of compound page
> with PTE we operate on ->_mapcount of the subpage.
>
> page_mapcount() counts both: PTE and PMD mappings of the page.
>
> Basically, we have mapcount for a subpage spread over two counters.
> It makes tricky to detect when last mapcount for a page goes away.
>
> We introduced PageDoubleMap() for this. When we split THP PMD for the
> first time and there's other PMD mapping left we offset up ->_mapcount
> in all subpages by one and set PG_double_map on the compound page.
> These additional references go away with last compound_mapcount.
>
> This approach provides a way to detect when last mapcount goes away on
> per small page basis without introducing new overhead for most common
> cases.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Jerome Marchand <jmarchan@redhat.com>

I found that recent mmotm hit the following BUG_ON() by reading
/proc/kpageflags over pfn backed by a thp.

  [  268.024519] page:ffffea00033e0000 count:0 mapcount:0 mapping:         =
 (null) index:0x700000200
  [  268.026076] flags: 0x4000000000000000()
  [  268.026778] page dumped because: VM_BUG_ON_PAGE(!PageHead(page))
  [  268.027816] page->mem_cgroup:ffff88021588cc00
  [  268.028638] ------------[ cut here ]------------
  [  268.029932] kernel BUG at /src/linux-dev/include/linux/page-flags.h:55=
2!
  [  268.031092] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
  [  268.032125] Modules linked in: cfg80211 rfkill crc32c_intel virtio_bal=
loon serio_raw i2c_piix4 virtio_blk virtio_net ata_generic pata_acpi
  [  268.032598] CPU: 0 PID: 1183 Comm: page-types Not tainted 4.2.0-mmotm-=
2015-10-21-14-41-151027-1418-00014-41+ #179
  [  268.032598] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
  [  268.032598] task: ffff880214a08bc0 ti: ffff880213e2c000 task.ti: ffff8=
80213e2c000
  [  268.032598] RIP: 0010:[<ffffffff812434b6>]  [<ffffffff812434b6>] stabl=
e_page_flags+0x336/0x340
  [  268.032598] RSP: 0018:ffff880213e2fda8  EFLAGS: 00010292
  [  268.032598] RAX: 0000000000000021 RBX: ffff8802150a39c0 RCX: 000000000=
0000000
  [  268.032598] RDX: ffff88021ec0ff38 RSI: ffff88021ec0d658 RDI: ffff88021=
ec0d658
  [  268.032598] RBP: ffff880213e2fdc8 R08: 000000000000000a R09: 000000000=
000132f
  [  268.032598] R10: 0000000000000000 R11: 000000000000132f R12: 400000000=
0000000
  [  268.032598] R13: ffffea00033e6340 R14: 00007fff8449e430 R15: ffffea000=
33e6340
  [  268.032598] FS:  00007ff7f9525700(0000) GS:ffff88021ec00000(0000) knlG=
S:0000000000000000
  [  268.032598] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  [  268.032598] CR2: 000000000063b800 CR3: 00000000d9e71000 CR4: 000000000=
00006f0
  [  268.032598] Stack:
  [  268.032598]  ffff8800db82df80 ffff8802150a39c0 0000000000000008 000000=
00000cf98d
  [  268.032598]  ffff880213e2fe18 ffffffff81243588 00007fff8449e430 ffff88=
0213e2ff20
  [  268.032598]  000000000063b800 ffff8802150a39c0 fffffffffffffffb ffff88=
0213e2ff20
  [  268.032598] Call Trace:
  [  268.032598]  [<ffffffff81243588>] kpageflags_read+0xc8/0x130
  [  268.032598]  [<ffffffff81235848>] proc_reg_read+0x48/0x70
  [  268.032598]  [<ffffffff811d6b08>] __vfs_read+0x28/0xd0
  [  268.032598]  [<ffffffff812ee43e>] ? security_file_permission+0xae/0xc0
  [  268.032598]  [<ffffffff811d6f53>] ? rw_verify_area+0x53/0xf0
  [  268.032598]  [<ffffffff811d707a>] vfs_read+0x8a/0x130
  [  268.032598]  [<ffffffff811d7bf7>] SyS_pread64+0x77/0x90
  [  268.032598]  [<ffffffff81648117>] entry_SYSCALL_64_fastpath+0x12/0x6a
  [  268.032598] Code: ca 00 00 40 01 48 39 c1 48 0f 44 da e9 a2 fd ff ff 4=
8 c7 c6 50 a6 a1 8 1 e8 58 ab f4 ff 0f 0b 48 c7 c6 90 a2 a1 81 e8 4a ab f4 =
ff <0f> 0b 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 41 57
  [  268.032598] RIP  [<ffffffff812434b6>] stable_page_flags+0x336/0x340
  [  268.032598]  RSP <ffff880213e2fda8>
  [  268.070504] ---[ end trace e5d18553088c026a ]---

page_mapcount() could be called for a tail page, so VM_BUG_ON_PAGE(!PageHea=
d())
in PageDoubleMap() introduced by this patch seems too strong restriction.
Could you handle this?

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
