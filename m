Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13B516B02F5
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 01:54:00 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 31so429616plk.20
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 22:54:00 -0800 (PST)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTPS id 5si299400plx.384.2018.01.02.22.53.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jan 2018 22:53:58 -0800 (PST)
Content-Type: text/plain;
	charset=gb2312
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] mm/fadvise: discard partial pages iff endbyte is also eof
From: "=?UTF-8?B?5aS35YiZKENhc3Bhcik=?=" <jinli.zjl@alibaba-inc.com>
In-Reply-To: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
Date: Wed, 03 Jan 2018 14:53:43 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <8DAEE48B-AD5D-4702-AB4B-7102DD837071@alibaba-inc.com>
References: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@techsingularity.net, Andrew Morton <akpm@linux-foundation.org>
Cc: green@linuxhacker.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?B?5p2o5YuHKOaZuuW9uyk=?= <zhiche.yy@alibaba-inc.com>, =?UTF-8?B?5Y2B5YiA?= <shidao.ytt@alibaba-inc.com>



> =D4=DA 2017=C4=EA12=D4=C223=C8=D5=A3=AC12:16=A3=AC=CA=AE=B5=B6 =
<shidao.ytt@alibaba-inc.com> =D0=B4=B5=C0=A3=BA
>=20
> From: "shidao.ytt" <shidao.ytt@alibaba-inc.com>
>=20
> in commit 441c228f817f7 ("mm: fadvise: document the
> fadvise(FADV_DONTNEED) behaviour for partial pages") Mel Gorman
> explained why partial pages should be preserved instead of discarded
> when using fadvise(FADV_DONTNEED), however the actual codes to =
calcuate
> end_index was unexpectedly wrong, the code behavior didn't match to =
the
> statement in comments; Luckily in another commit 18aba41cbf
> ("mm/fadvise.c: do not discard partial pages with =
POSIX_FADV_DONTNEED")
> Oleg Drokin fixed this behavior
>=20
> Here I come up with a new idea that actually we can still discard the
> last parital page iff the page-unaligned endbyte is also the end of
> file, since no one else will use the rest of the page and it should be
> safe enough to discard.

+akpm...

Hi Mel, Andrew:

Would you please take a look at this patch, to see if this proposal
is reasonable enough, thanks in advance!

Thanks,
Caspar

>=20
> Signed-off-by: shidao.ytt <shidao.ytt@alibaba-inc.com>
> Signed-off-by: Caspar Zhang <jinli.zjl@alibaba-inc.com>
> ---
> mm/fadvise.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/fadvise.c b/mm/fadvise.c
> index ec70d6e..f74b21e 100644
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -127,7 +127,8 @@
> 		 */
> 		start_index =3D (offset+(PAGE_SIZE-1)) >> PAGE_SHIFT;
> 		end_index =3D (endbyte >> PAGE_SHIFT);
> -		if ((endbyte & ~PAGE_MASK) !=3D ~PAGE_MASK) {
> +		if ((endbyte & ~PAGE_MASK) !=3D ~PAGE_MASK &&
> +				endbyte !=3D inode->i_size - 1) {
> 			/* First page is tricky as 0 - 1 =3D -1, but =
pgoff_t
> 			 * is unsigned, so the end_index >=3D =
start_index
> 			 * check below would be true and we'll discard =
the whole
> --=20
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
