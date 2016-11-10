Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57B606B0281
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:12:39 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a8so77437018pfg.0
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 01:12:39 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id qk7si3156108pac.167.2016.11.10.01.12.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 01:12:38 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 03/12] mm: thp: introduce separate TTU flag for thp
 freezing
Date: Thu, 10 Nov 2016 09:09:05 +0000
Message-ID: <20161110090904.GA9173@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5824307C.7070105@linux.vnet.ibm.com>
In-Reply-To: <5824307C.7070105@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <28695A655618C844BDCCAB546C54D2AD@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Nov 10, 2016 at 02:01:56PM +0530, Anshuman Khandual wrote:
> On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> > TTU_MIGRATION is used to convert pte into migration entry until thp spl=
it
> > completes. This behavior conflicts with thp migration added later patch=
es,
>
> Hmm, could you please explain why it conflicts with the PMD based
> migration without split ? Why TTU_MIGRATION cannot be used to
> freeze/hold on the PMD while it's being migrated ?

try_to_unmap() is used both for thp split (via freeze_page()) and page
migration (via __unmap_and_move()). In freeze_page(), ttu_flag given for
head page is like below (assuming anonymous thp):

    (TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS | TTU_RMAP_LOCKED | \
     TTU_MIGRATION | TTU_SPLIT_HUGE_PMD)

and ttu_flag given for tail pages is:

    (TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS | TTU_RMAP_LOCKED | \
     TTU_MIGRATION)

__unmap_and_move() calls try_to_unmap() with ttu_flag:

    (TTU_MIGRATION | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS)

Now I'm trying to insert a branch for thp migration at the top of
try_to_unmap_one() like below


  static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma=
,
                       unsigned long address, void *arg)
  {
          ...
          if (flags & TTU_MIGRATION) {
                  if (!PageHuge(page) && PageTransCompound(page)) {
                          set_pmd_migration_entry(page, vma, address);
                          goto out;
                  }
          }

, so try_to_unmap() for tail pages called by thp split can go into thp
migration code path (which converts *pmd* into migration entry), while
the expectation is to freeze thp (which converts *pte* into migration entry=
.)

I detected this failure as a "bad page state" error in a testcase where
split_huge_page() is called from queue_pages_pte_range().

Anyway, I'll add this explanation into the patch description in the next po=
st.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
