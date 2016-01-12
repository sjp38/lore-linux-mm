Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 34D154403D9
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 23:07:10 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id n128so55635644pfn.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 20:07:10 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id u84si2217680pfa.199.2016.01.11.20.07.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 20:07:09 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: soft-offline: check return value in second
 __get_any_page() call
Date: Tue, 12 Jan 2016 03:29:35 +0000
Message-ID: <20160112032932.GA8314@hori1.linux.bs1.fc.nec.co.jp>
References: <1452237748-10822-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160108075158.GA28640@hori1.linux.bs1.fc.nec.co.jp>
 <20160108153626.16332573d71cdfcdbc1637cd@linux-foundation.org>
In-Reply-To: <20160108153626.16332573d71cdfcdbc1637cd@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <BAC5ECFA05E901408EA34BE48A0DD8A6@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jan 08, 2016 at 03:36:26PM -0800, Andrew Morton wrote:
> On Fri, 8 Jan 2016 07:51:59 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.=
com> wrote:
>=20
> > >   [   52.600579]  [<ffffffff811bd18c>] SyS_madvise+0x6bc/0x6f0
> > >   [   52.600579]  [<ffffffff8104d0ac>] ? fpu__restore_sig+0xcc/0x320
> > >   [   52.600579]  [<ffffffff810a0003>] ? do_sigaction+0x73/0x1b0
> > >   [   52.600579]  [<ffffffff8109ceb2>] ? __set_task_blocked+0x32/0x70
> > >   [   52.600579]  [<ffffffff81652757>] entry_SYSCALL_64_fastpath+0x12=
/0x6a
> > >   [   52.600579] Code: 8b fc ff ff 5b 5d c3 48 89 df e8 b0 fa ff ff 4=
8 89 df 31 f6 e8 c6 7d ff ff 5b 5d c3 48 c7 c6 08 54 a2 81 48 89 df e8 a4 c=
5 01 00 <0f> 0b 66 90 66 66 66 66 90 55 48 89 e5 41 55 41 54 53 48 8b 47
> > >   [   52.600579] RIP  [<ffffffff8118998c>] put_page+0x5c/0x60
> > >   [   52.600579]  RSP <ffff88007c213e00>
> > >=20
> > > The root cause resides in get_any_page() which retries to get a refco=
unt of
> > > the page to be soft-offlined. This function calls put_hwpoison_page()=
, expecting
> > > that the target page is putback to LRU list. But it can be also freed=
 to buddy.
> > > So the second check need to care about such case.
> > >=20
> > > Fixes: af8fae7c0886 ("mm/memory-failure.c: clean up soft_offline_page=
()")
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Cc: stable@vger.kernel.org # v3.9+
>=20
> Please don't top-post.  I manually fixed it here.

sorry, I keep this rule in mind.

> > Sorry, I forgot to notice that this specific problem is already fixed i=
n
> > mmotm with patch "mm: hwpoison: adjust for new thp refcounting", but
> > considering backporting to -stable, it's easier to handle this separate=
ly.
> >=20
> > So Andrew, could you separate out the code of this patch from
> > "mm: hwpoison: adjust for new thp refcounting"?
>=20
> I don't understand what you're asking for.  Please be very
> specific and carefully identify patches by filename or Subject:.

OK, so what I really wanted is that (1) applying this patch just before
http://ozlabs.org/~akpm/mmots/broken-out/mm-hwpoison-adjust-for-new-thp-ref=
counting.patch
and (2) removing the following chunk from the mm-hwpoison-adjust-for-new-th=
p-refcounting.patch:

@@ -1575,7 +1540,7 @@ static int get_any_page(struct page *pag
 		 * Did it turn free?
 		 */
 		ret =3D __get_any_page(page, pfn, 0);
-		if (!PageLRU(page)) {
+		if (ret =3D=3D 1 && !PageLRU(page)) {
 			/* Drop page reference which is from __get_any_page() */
 			put_hwpoison_page(page);
 			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
