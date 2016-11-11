Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7736B026F
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 20:09:47 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id q124so77199598itd.2
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 17:09:47 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id i15si6226170pag.284.2016.11.10.17.09.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 17:09:46 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 01/12] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7
 to bit 6
Date: Fri, 11 Nov 2016 01:08:36 +0000
Message-ID: <20161111010834.GA28679@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <534caa72-c109-9716-15d2-5e80f4038f8d@intel.com>
In-Reply-To: <534caa72-c109-9716-15d2-5e80f4038f8d@intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4519D00B843E514D95B1F7709ACA6AA8@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Nov 10, 2016 at 03:29:51PM -0800, Dave Hansen wrote:
> On 11/07/2016 03:31 PM, Naoya Horiguchi wrote:
> > pmd_present() checks _PAGE_PSE along with _PAGE_PRESENT to avoid false =
negative
> > return when it races with thp spilt (during which _PAGE_PRESENT is temp=
orary
> > cleared.) I don't think that dropping _PAGE_PSE check in pmd_present() =
works
> > well because it can hurt optimization of tlb handling in thp split.
> > In the current kernel, bit 6 is not used in non-present format because =
nonlinear
> > file mapping is obsolete, so let's move _PAGE_SWP_SOFT_DIRTY to that bi=
t.
> > Bit 7 is used as reserved (always clear), so please don't use it for ot=
her
> > purpose.
> ...
> >  #ifdef CONFIG_MEM_SOFT_DIRTY
> > -#define _PAGE_SWP_SOFT_DIRTY	_PAGE_PSE
> > +#define _PAGE_SWP_SOFT_DIRTY	_PAGE_DIRTY
> >  #else
> >  #define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
> >  #endif
>=20
> I'm not sure this works.  Take a look at commit 00839ee3b29 and the
> erratum it works around.  I _think_ this means that a system affected by
> the erratum might see an erroneous _PAGE_SWP_SOFT_DIRTY/_PAGE_DIRTY get
> set in swap ptes.
>=20
> There are much worse things that can happen, but I don't think bits 5
> (Accessed) and 6 (Dirty) are good choices since they're affected by the
> erratum.

Thank you for the information. According to 00839ee3b29, some bits which
are safe from the errata are reclaimed, so assigning one of such bits for
_PAGE_SWP_SOFT_DIRTY seems to work. And I'll update the description.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
