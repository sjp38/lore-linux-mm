Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 29931828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 02:52:58 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id q63so6433238pfb.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 23:52:58 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id o6si69245923pap.162.2016.01.07.23.52.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 23:52:57 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: soft-offline: check return value in second
 __get_any_page() call
Date: Fri, 8 Jan 2016 07:51:59 +0000
Message-ID: <20160108075158.GA28640@hori1.linux.bs1.fc.nec.co.jp>
References: <1452237748-10822-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1452237748-10822-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F7A69A76D1177643BCEB42B3F53AFE8E@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Sorry, I forgot to notice that this specific problem is already fixed in
mmotm with patch "mm: hwpoison: adjust for new thp refcounting", but
considering backporting to -stable, it's easier to handle this separately.

So Andrew, could you separate out the code of this patch from
"mm: hwpoison: adjust for new thp refcounting"?

Thanks,
Naoya Horiguchi

On Fri, Jan 08, 2016 at 04:22:28PM +0900, Naoya Horiguchi wrote:
> I saw the following BUG_ON triggered in a testcase where a process calls
> madvise(MADV_SOFT_OFFLINE) on thps, along with a background process that
> calls migratepages command repeatedly (doing ping-pong among different
> NUMA nodes) for the first process:
>=20
>   [   52.556731] Soft offlining page 0x60000 at 0x700000600000
>   [   52.592620] __get_any_page: 0x60000 free buddy page
>   [   52.593451] page:ffffea0001800000 count:0 mapcount:-127 mapping:    =
      (null) index:0x1
>   [   52.594767] flags: 0x1fffc0000000000()
>   [   52.595402] page dumped because: VM_BUG_ON_PAGE(atomic_read(&page->_=
count) =3D=3D 0)
>   [   52.596602] ------------[ cut here ]------------
>   [   52.597339] kernel BUG at /src/linux-dev/include/linux/mm.h:342!
>   [   52.598284] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
>   [   52.599193] Modules linked in: cfg80211 rfkill crc32c_intel serio_ra=
w virtio_balloon i2c_piix4 virtio_blk virtio_net ata_generic pata_acpi
>   [   52.600579] CPU: 3 PID: 3035 Comm: test_alloc_gene Tainted: G       =
    O    4.4.0-rc8-v4.4-rc8-160107-1501-00000-rc8+ #74
>   [   52.600579] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>   [   52.600579] task: ffff88007c63d5c0 ti: ffff88007c210000 task.ti: fff=
f88007c210000
>   [   52.600579] RIP: 0010:[<ffffffff8118998c>]  [<ffffffff8118998c>] put=
_page+0x5c/0x60
>   [   52.600579] RSP: 0018:ffff88007c213e00  EFLAGS: 00010246
>   [   52.600579] RAX: 0000000000000044 RBX: ffffea0001800000 RCX: 0000000=
000000000
>   [   52.600579] RDX: ffff88011f50f570 RSI: 0000000000000000 RDI: ffff880=
11f50cc18
>   [   52.600579] RBP: ffff88007c213e08 R08: 000000000000000a R09: 0000000=
00000149c
>   [   52.600579] R10: ffff8800dac927f8 R11: 000000000000149c R12: ffffea0=
001800000
>   [   52.600579] R13: 0000000000060000 R14: ffffea0001800000 R15: 0000000=
000000065
>   [   52.600579] FS:  00007feb79d7d740(0000) GS:ffff88011f500000(0000) kn=
lGS:0000000000000000
>   [   52.600579] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>   [   52.600579] CR2: 00007f3032cd2000 CR3: 00000000da6c4000 CR4: 0000000=
0000006e0
>   [   52.600579] Stack:
>   [   52.600579]  ffffea0001800000 ffff88007c213e28 ffffffff811eb2ee ffff=
ea0001800000
>   [   52.600579]  00000000fffffffb ffff88007c213e70 ffffffff811eccd1 0000=
000000000018
>   [   52.600579]  ffff88007c213e50 0000700000600000 0000700000601000 0000=
160000000000
>   [   52.600579] Call Trace:
>   [   52.600579]  [<ffffffff811eb2ee>] put_hwpoison_page+0x4e/0x80
>   [   52.600579]  [<ffffffff811eccd1>] soft_offline_page+0x501/0x520
>   [   52.600579]  [<ffffffff811bd18c>] SyS_madvise+0x6bc/0x6f0
>   [   52.600579]  [<ffffffff8104d0ac>] ? fpu__restore_sig+0xcc/0x320
>   [   52.600579]  [<ffffffff810a0003>] ? do_sigaction+0x73/0x1b0
>   [   52.600579]  [<ffffffff8109ceb2>] ? __set_task_blocked+0x32/0x70
>   [   52.600579]  [<ffffffff81652757>] entry_SYSCALL_64_fastpath+0x12/0x6=
a
>   [   52.600579] Code: 8b fc ff ff 5b 5d c3 48 89 df e8 b0 fa ff ff 48 89=
 df 31 f6 e8 c6 7d ff ff 5b 5d c3 48 c7 c6 08 54 a2 81 48 89 df e8 a4 c5 01=
 00 <0f> 0b 66 90 66 66 66 66 90 55 48 89 e5 41 55 41 54 53 48 8b 47
>   [   52.600579] RIP  [<ffffffff8118998c>] put_page+0x5c/0x60
>   [   52.600579]  RSP <ffff88007c213e00>
>=20
> The root cause resides in get_any_page() which retries to get a refcount =
of
> the page to be soft-offlined. This function calls put_hwpoison_page(), ex=
pecting
> that the target page is putback to LRU list. But it can be also freed to =
buddy.
> So the second check need to care about such case.
>=20
> Fixes: af8fae7c0886 ("mm/memory-failure.c: clean up soft_offline_page()")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # v3.9+
> ---
>  mm/memory-failure.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git v4.4-rc8/mm/memory-failure.c v4.4-rc8_patched/mm/memory-failur=
e.c
> index 8424b64..750b789 100644
> --- v4.4-rc8/mm/memory-failure.c
> +++ v4.4-rc8_patched/mm/memory-failure.c
> @@ -1572,7 +1572,7 @@ static int get_any_page(struct page *page, unsigned=
 long pfn, int flags)
>  		 * Did it turn free?
>  		 */
>  		ret =3D __get_any_page(page, pfn, 0);
> -		if (!PageLRU(page)) {
> +		if (ret =3D=3D 1 && !PageLRU(page)) {
>  			/* Drop page reference which is from __get_any_page() */
>  			put_hwpoison_page(page);
>  			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
> --=20
> 1.7.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
