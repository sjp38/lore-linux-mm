Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 06BAC6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 05:17:53 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so10707439pac.3
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 02:17:52 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id vw6si8496878pac.106.2015.08.12.02.17.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Aug 2015 02:17:52 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hwpoison: fix panic due to split huge zero page
Date: Wed, 12 Aug 2015 09:16:03 +0000
Message-ID: <20150812091602.GG32192@hori1.linux.bs1.fc.nec.co.jp>
References: <BLU437-SMTP5348473FAB81C31638A9A0807F0@phx.gbl>
In-Reply-To: <BLU437-SMTP5348473FAB81C31638A9A0807F0@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B88C0C2F8D0F1E42AA23728D16C5618A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Aug 11, 2015 at 06:47:57PM +0800, Wanpeng Li wrote:
> [ 1162.009854] ------------[ cut here ]------------
> [ 1162.014485] kernel BUG at mm/huge_memory.c:1957!
> [ 1162.019109] invalid opcode: 0000 [#1] SMP=20
> [ 1162.023236] Modules linked in: snd_hda_codec_hdmi i915 rpcsec_gss_krb5=
 snd_hda_codec_realtek snd_hda_codec_generic nfsv4 dns_re
> [ 1162.090181] CPU: 2 PID: 2576 Comm: test_huge Not tainted 4.2.0-rc5-mm1=
+ #27
> [ 1162.097150] Hardware name: Dell Inc. OptiPlex 7020/0F5C5X, BIOS A03 01=
/08/2015
> [ 1162.104378] task: ffff880204e3d600 ti: ffff8800db16c000 task.ti: ffff8=
800db16c000
> [ 1162.111867] RIP: 0010:[<ffffffff811dea3b>]  [<ffffffff811dea3b>] split=
_huge_page_to_list+0xdb/0x120
> [ 1162.120933] RSP: 0018:ffff8800db16fde8  EFLAGS: 00010246
> [ 1162.126246] RAX: ffffea0002310000 RBX: ffffea0002310000 RCX: ffff88021=
edd2000
> [ 1162.133383] RDX: 0000000000000011 RSI: 0000000000000000 RDI: ffffea000=
2310000
> [ 1162.140530] RBP: ffff8800db16fe08 R08: 000000000000fffe R09: 000000000=
0000001
> [ 1162.147668] R10: 0000000000000326 R11: 0000000000000326 R12: 000000000=
008c400
> [ 1162.154809] R13: 0000000000000000 R14: 0000000000000001 R15: 000000000=
0000000
> [ 1162.161947] FS:  00007f36f7d2e740(0000) GS:ffff88021eb00000(0000) knlG=
S:0000000000000000
> [ 1162.170043] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1162.175794] CR2: 00007f36eadffff8 CR3: 00000000a75db000 CR4: 000000000=
01406e0
> [ 1162.182931] Stack:
> [ 1162.184943]  ffff8800db16fe80 ffffea0002310000 000000000008c400 000000=
0000000001
> [ 1162.192391]  ffff8800db16fe68 ffffffff811ecb4e ffffea0002310000 000000=
0000000001
> [ 1162.199834]  ffff8800db16fe38 ffffea0002310000 ffff8800db16fe58 00007f=
36eae00000
> [ 1162.207278] Call Trace:
> [ 1162.209726]  [<ffffffff811ecb4e>] memory_failure+0x32e/0x7c0
> [ 1162.215388]  [<ffffffff811b9f1b>] madvise_hwpoison+0x8b/0x160
> [ 1162.221134]  [<ffffffff811ba680>] SyS_madvise+0x40/0x240
> [ 1162.226450]  [<ffffffff81066777>] ? do_page_fault+0x37/0x90
> [ 1162.232024]  [<ffffffff8166152e>] entry_SYSCALL_64_fastpath+0x12/0x71
> [ 1162.238467] Code: ff f0 41 ff 4c 24 30 74 0d 31 c0 48 83 c4 08 5b 41 5=
c 41 5d c9 c3 4c 89 e7 e8 e2 58 fd ff 48 83 c4 08 31 c0 =20
> [ 1162.258104] RIP  [<ffffffff811dea3b>] split_huge_page_to_list+0xdb/0x1=
20
> [ 1162.264815]  RSP <ffff8800db16fde8>
> [ 1162.273447] ---[ end trace aee7ce0df8e44076 ]---
>=20
> Testcase:
>=20
> #define _GNU_SOURCE
> #include <stdlib.h>
> #include <stdio.h>
> #include <sys/mman.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <sys/types.h>
> #include <errno.h>
> #include <string.h>
>=20
> #define MB 1024*1024
>=20
> int main(void)
> {
> 	char *mem;
>=20
> 	posix_memalign((void **)&mem, 2 * MB, 200 * MB);
>=20
> 	madvise(mem, 200 * MB, MADV_HWPOISON);
>=20
> 	free(mem);
>=20
> 	return 0;
> }
>=20
> Huge zero page is allocated if page fault w/o FAULT_FLAG_WRITE flag.=20
> The get_user_pages_fast() which called in madvise_hwpoison() will get=20
> huge zero page if the page is not allocated before. Huge zero page is=20
> a tranparent huge page, however, it is not an anonymous page. memory_fail=
ure=20
> will split the huge zero page and trigger BUG_ON(is_huge_zero_page(page))=
;=20
> After commit (98ed2b0: mm/memory-failure: give up error handling for=20
> non-tail-refcounted thp), memory_failure will not catch non anon thp=20
> from madvise_hwpoison path and this bug occur.
>=20
> Fix it by catching non anon thp in memory_failure in order to not split=20
> huge zero page in madvise_hwpoison path.
>=20
> After patch:
>=20
> [   51.825205] Injecting memory failure for page 0x202800 at 0x7fd8ae8000=
00
> [   51.825205] MCE: 0x202800: non anonymous thp
> [...]
>=20
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>

Nice fix.

# With removing the second split_huge_page as you replied to mm-commits ema=
il ...

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> Note: the patch is rebased on put_hwpoison_page() patches.
>=20
>  mm/memory-failure.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 6179fc1..0acafee 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1155,8 +1155,11 @@ int memory_failure(unsigned long pfn, int trapno, =
int flags)
>  	}
> =20
>  	if (!PageHuge(p) && PageTransHuge(hpage)) {
> -		if (unlikely(split_huge_page(hpage))) {
> -			pr_err("MCE: %#lx: thp split failed\n", pfn);
> +		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
> +			if (!PageAnon(hpage))
> +				pr_err("MCE: %#lx: non anonymous thp\n", pfn);
> +			else if (unlikely(split_huge_page(hpage)))
> +				pr_err("MCE: %#lx: thp split failed\n", pfn);
>  			if (TestClearPageHWPoison(p))
>  				atomic_long_sub(nr_pages, &num_poisoned_pages);
>  			put_hwpoison_page(p);
> --=20
> 1.7.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
