Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 645A92802E6
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 22:44:14 -0400 (EDT)
Received: by obre1 with SMTP id e1so38901432obr.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:44:14 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id a4si5161953oib.120.2015.07.15.19.44.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 19:44:13 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1 3/4] mm/memory-failure: give up error handling for
 non-tail-refcounted thp
Date: Thu, 16 Jul 2015 02:41:07 +0000
Message-ID: <20150716024106.GA13135@hori1.linux.bs1.fc.nec.co.jp>
References: <1437010894-10262-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1437010894-10262-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150716023307.GF1747@two.firstfloor.org>
In-Reply-To: <20150716023307.GF1747@two.firstfloor.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <40B8A6E291556241882BF753BB4C77A1@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 16, 2015 at 04:33:07AM +0200, Andi Kleen wrote:
> > @@ -909,6 +909,15 @@ int get_hwpoison_page(struct page *page)
> >  	 * directly for tail pages.
> >  	 */
> >  	if (PageTransHuge(head)) {
> > +		/*
> > +		 * Non anonymous thp exists only in allocation/free time. We
> > +		 * can't handle such a case correctly, so let's give it up.
> > +		 * This should be better than triggering BUG_ON when kernel
> > +		 * tries to touch a "partially handled" page.
> > +		 */
> > +		if (!PageAnon(head))
> > +			return 0;
>=20
> Please print a message for this case. In the future there will be
> likely more non anonymous THP pages from Kirill's large page cache work
> (so eventually we'll need it)

OK, I'll do this.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
