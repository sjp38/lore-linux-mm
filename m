Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C09BB82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 04:34:53 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so68146049pad.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:34:53 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id xt7si9213254pab.187.2015.10.30.01.34.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 30 Oct 2015 01:34:53 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCHv12 26/37] mm: rework mapcount accounting to enable 4k
 mapping of THPs
Date: Fri, 30 Oct 2015 08:33:48 +0000
Message-ID: <20151030083347.GA8259@hori1.linux.bs1.fc.nec.co.jp>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-27-git-send-email-kirill.shutemov@linux.intel.com>
 <20151027061800.GA336@hori1.linux.bs1.fc.nec.co.jp>
 <20151027093055.GA27031@node.shutemov.name>
 <20151027232421.GA15946@hori1.linux.bs1.fc.nec.co.jp>
 <20151029215047.GB13368@node.shutemov.name>
In-Reply-To: <20151029215047.GB13368@node.shutemov.name>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <8697FC5661FBFB4F90C830E94D1D80BE@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Oct 29, 2015 at 11:50:47PM +0200, Kirill A. Shutemov wrote:
...
>=20
> Okay, the problem is that the page was freed under stable_page_flags().
>=20
> Is the code performance sensitive? Can we get reference to the page befor=
e
> touching it? If not, we can rewrite the helper like this:
>
> static inline int PageDoubleMap(struct page *page)
> {
> 	return PageHead(page) && test_bit(PG_double_map, &page[1].flags);       =
                 =20
> }
>=20
> Just dropping the check would be wrong, I think, as we access the next
> page.
>=20

I don't think this interface is performance sensitive, but hopefully the
impact on other workload is minimum. So I like the above rewritten one.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
