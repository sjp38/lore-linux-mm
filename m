Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 65752900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 04:52:20 -0400 (EDT)
Received: by obbeb7 with SMTP id eb7so139791991obb.3
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 01:52:20 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id t5si896207oie.31.2015.04.21.01.52.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 01:52:19 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/memory-failure: call shake_page() when error hits
 thp tail page
Date: Tue, 21 Apr 2015 08:47:05 +0000
Message-ID: <20150421084705.GG21832@hori1.linux.bs1.fc.nec.co.jp>
References: <1429082714-26115-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150420143014.bd6c683d159758db1815799f@linux-foundation.org>
In-Reply-To: <20150420143014.bd6c683d159758db1815799f@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <79ADE403FA3D7841BA90AA54D7EF0BAD@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dean Nelson <dnelson@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Jin Dongming <jin.dongming@np.css.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Apr 20, 2015 at 02:30:14PM -0700, Andrew Morton wrote:
> On Wed, 15 Apr 2015 07:25:46 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > Currently memory_failure() calls shake_page() to sweep pages out from p=
cplists
> > only when the victim page is 4kB LRU page or thp head page. But we shou=
ld do
> > this for a thp tail page too.
> > Consider that a memory error hits a thp tail page whose head page is on=
 a
> > pcplist when memory_failure() runs. Then, the current kernel skips shak=
e_pages()
> > part, so hwpoison_user_mappings() returns without calling split_huge_pa=
ge() nor
> > try_to_unmap() because PageLRU of the thp head is still cleared due to =
the skip
> > of shake_page().
> > As a result, me_huge_page() runs for the thp, which is a broken behavio=
r.
> >=20
> > This patch fixes this problem by calling shake_page() for thp tail case=
.
> >=20
> > Fixes: 385de35722c9 ("thp: allow a hwpoisoned head page to be put back =
to LRU")
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: stable@vger.kernel.org  # v3.4+
>=20
> What are the userspace-visible effects of the bug?  This info is needed
> for backporting into -stable and other kernels, please.

One effect is memory leak of the thp. And another is to fail to isolate
the memory error, so later access to the error address causes another MCE,
which kills the processes which used the thp.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
