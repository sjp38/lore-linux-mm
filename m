Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0ADE36B0003
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 19:21:28 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id w22-v6so11299085ioc.5
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 16:21:28 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id s26-v6si13546699jaj.52.2018.11.12.16.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 16:21:26 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC][PATCH v1 02/11] mm: soft-offline: add missing error check
 of set_hwpoison_free_buddy_page()
Date: Tue, 13 Nov 2018 00:16:53 +0000
Message-ID: <20181113001652.GA5945@hori1.linux.bs1.fc.nec.co.jp>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <9ea93154-4843-231d-d72b-bf12c8807c24@arm.com>
In-Reply-To: <9ea93154-4843-231d-d72b-bf12c8807c24@arm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E2D5FBA3152315409C8D6F7D836BBB31@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>

Hi Anshuman,

On Fri, Nov 09, 2018 at 03:50:41PM +0530, Anshuman Khandual wrote:
>=20
>=20
> On 11/09/2018 12:17 PM, Naoya Horiguchi wrote:
> > set_hwpoison_free_buddy_page() could fail, then the target page is
> > finally not isolated, so it's better to report -EBUSY for userspace
> > to know the failure and chance of retry.
> >=20
>=20
> IIUC set_hwpoison_free_buddy_page() could only fail if the page is not
> free in the buddy. At least for soft_offline_huge_page() that wont be
> the case otherwise dissolve_free_huge_page() would have returned non
> zero -EBUSY. Is there any other reason set_hwpoison_free_buddy_page()
> would not succeed ?

There is a race window between page freeing (after successful soft-offline
-> page migration case) and the containment by set_hwpoison_free_buddy_page=
().
Or a target page can be allocated just after get_any_page() decided that
the target page is a free page.
So set_hwpoison_free_buddy_page() would safely fail in such cases.

Thanks,
Naoya Horiguchi

>=20
> > And for consistency, this patch moves set_hwpoison_free_buddy_page()
> > in unmap_and_move() to __soft_offline_page().
>=20
> Yeah this check should be handled in soft offline functions not inside
> migrations they trigger.
> =
