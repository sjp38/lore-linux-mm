Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id DFB846B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 04:13:20 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so11812694igb.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 01:13:20 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id nt6si2201880igb.79.2015.07.31.01.13.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 01:13:20 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] memory_failure: remove redundant check for the
 PG_HWPoison flag of 'hpage'
Date: Fri, 31 Jul 2015 08:12:19 +0000
Message-ID: <20150731081218.GA14902@hori1.linux.bs1.fc.nec.co.jp>
References: <20150729155246.2fed1b96@hp>
 <20150729091725.GA1256@hori1.linux.bs1.fc.nec.co.jp>
 <20150730105246.6bcc0af5@hp>
In-Reply-To: <20150730105246.6bcc0af5@hp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <168C1A5C72F36C4D9BD0E5B84802A310@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jul 30, 2015 at 10:52:46AM +0800, Wang Xiaoqiang wrote:
...
> In your example, the 100th subage enter the memory
> error handler firstly, and then it uses the=20
> set_page_hwpoison_huge_page to set all subpages
> with PG_HWPoison flag, the 50th page handler waits
> for grab the lock_page(hpage) now.=20
>=20
> When the 100th page handler unlock the 'hpage',=20
> the 50th grab it, and now the 'hapge' has been=20
> set with PG_HWPosison. So PageHWPoison micro=20
> will return true, and the following code will
> be executed:
>=20
> if (PageHWPoison(hpage)) {
>     if ((hwpoison_filter(p) && TestClearPageHWPoison(p))
>         || (p !=3D hpage && TestSetPageHWPoison(hpage))) {
>         atomic_long_sub(nr_pages, &num_poisoned_pages);
>         unlock_page(hpage);
>         return 0;
>     }  =20
> }
>=20
> Now 'p' is 50th subpage, it doesn't equal the=20
> 'hpage' obviously, so if we don't have TestSetPageHWPoison
> here, it still will ignore the 50th error.

Ah, you're right, thanks for the explanation, Xiaoqiang!

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
