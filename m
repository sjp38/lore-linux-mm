Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 445BE6B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 14:12:42 -0400 (EDT)
Received: by paceq1 with SMTP id eq1so9073014pac.3
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 11:12:41 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hu9si71343445pdb.252.2015.06.30.11.12.40
        for <linux-mm@kvack.org>;
        Tue, 30 Jun 2015 11:12:40 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC v2 PATCH 0/8] mm: mirrored memory support for page buddy
 allocations
Date: Tue, 30 Jun 2015 18:12:35 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32AA1974@ORSMSX114.amr.corp.intel.com>
References: <558E084A.60900@huawei.com> <20150630094149.GA6812@suse.de>
 <20150630104654.GA24932@gmail.com> <20150630115353.GB6812@suse.de>
In-Reply-To: <20150630115353.GB6812@suse.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, "leon@leon.nu" <leon@leon.nu>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Hansen,
 Dave" <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> Sounds logical. In that case, bootmem awareness would be crucial.
> Enabling support in just the page allocator is too late.

Andrew already applied some patches from me that I think covered bootmem
mirror allocations:

commit fc6daaf93151877748f8096af6b3fddb147f22d6
    mm/memblock: add extra "flags" to memblock to allow selection of memory=
 based on attribute
commit a3f5bafcc04aaf62990e0cf3ced1cc6d8dc6fe95
    mm/memblock: allocate boot time data structures from mirrored memory
commit b05b9f5f9dcf593a0e9327676b78e6c17b4218e8
    x86, mirror: x86 enabling - find mirrored memory ranges

If I missed something, please let me know.


>> In that sense 'protecting' all kernel allocations is natural: we don't k=
now how to=20
>> recover from faults that affect kernel memory.
>>=20
>
> It potentially uses all mirrored memory on memory that does not need that
> sort of guarantee. For example, if there was a MC on memory backing the
> inode cache then potentially that is recoverable as long as the inodes
> were not dirty.

Right now this is hard to do.  On Intel we get a broadcast machine check th=
at
may catch bystander cpus holding locks that we might need to look at kernel
structures to make decisions on what we just lost.  That may get easier wit=
h
local machine check (only the logical cpu that tried to consume the corrupt
data gets the machine check ... patches for Linux are in for basic support =
of
this ... waiting for h/w that does it).


> That's a minor detail as the kernel could later protect
> only MIGRATE_UNMOVABLE requests instead of all kernel allocations if fata=
l
> MC in kernel space could be distinguished from non-fatal checks.

So the immediate use case is large memory servers (hundred+ Gbytes to
TBytes) running some applications that use most of memory in user mode
(like a database).  We mirror enough memory to cover *all* the kernel alloc=
ations
so that a bad memory access with be fixed from the mirror for kernel, or re=
sult
in SIGBUS to a process for user page ... either way we don't crash the syst=
em.

Perhaps in the future we might find some places in the kernel where we can
cover a lot of memory without too many code changes ... e.g. things like
pagecopy().  At that time we'd have to think about allocation priorities.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
