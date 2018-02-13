Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 137476B0006
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 21:48:17 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id w16so7831770plp.20
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 18:48:17 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id x3-v6si1414315plo.2.2018.02.12.18.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Feb 2018 18:48:15 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB hugepage
In-Reply-To: <20180208121749.0ac09af2b5a143106f339f55@linux-foundation.org>
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp> <1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com> <87inbbjx2w.fsf@e105922-lin.cambridge.arm.com> <20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp> <87fu6bfytm.fsf@e105922-lin.cambridge.arm.com> <20180208121749.0ac09af2b5a143106f339f55@linux-foundation.org>
Date: Tue, 13 Feb 2018 13:48:06 +1100
Message-ID: <87wozhvc49.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Punit Agrawal <punit.agrawal@arm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.orglinuxppc-dev@lists.ozlabs.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 08 Feb 2018 12:30:45 +0000 Punit Agrawal <punit.agrawal@arm.com> wrote:
>
>> >
>> > So I don't think that the above test result means that errors are properly
>> > handled, and the proposed patch should help for arm64.
>> 
>> Although, the deviation of pud_huge() avoids a kernel crash the code
>> would be easier to maintain and reason about if arm64 helpers are
>> consistent with expectations by core code.
>> 
>> I'll look to update the arm64 helpers once this patch gets merged. But
>> it would be helpful if there was a clear expression of semantics for
>> pud_huge() for various cases. Is there any version that can be used as
>> reference?
>
> Is that an ack or tested-by?
>
> Mike keeps plaintively asking the powerpc developers to take a look,
> but they remain steadfastly in hiding.

Cc'ing linuxppc-dev is always a good idea :)

> Folks, this patch fixes a BUG and is marked for -stable.  Can we please
> prioritize it?

It's not crashing for me (on 4.16-rc1):

  # ./huge-poison 
  Poisoning page...once
  Poisoning page...once again
  madvise: Bad address

And I guess the above is the expected behaviour?

Looking at the function trace it looks like the 2nd madvise is going
down reasonable code paths, but I don't know for sure:

  8)               |  SyS_madvise() {
  8)               |    capable() {
  8)               |      ns_capable_common() {
  8)   0.094 us    |        cap_capable();
  8)   0.516 us    |      }
  8)   1.052 us    |    }
  8)               |    get_user_pages_fast() {
  8)   0.354 us    |      gup_pgd_range();
  8)               |      get_user_pages_unlocked() {
  8)   0.050 us    |        down_read();
  8)               |        __get_user_pages() {
  8)               |          find_extend_vma() {
  8)               |            find_vma() {
  8)   0.148 us    |              vmacache_find();
  8)   0.622 us    |            }
  8)   1.064 us    |          }
  8)   0.028 us    |          arch_vma_access_permitted();
  8)               |          follow_hugetlb_page() {
  8)               |            huge_pte_offset() {
  8)   0.128 us    |              __find_linux_pte();
  8)   0.580 us    |            }
  8)   0.048 us    |            _raw_spin_lock();
  8)               |            hugetlb_fault() {
  8)               |              huge_pte_offset() {
  8)   0.034 us    |                __find_linux_pte();
  8)   0.434 us    |              }
  8)   0.028 us    |              is_hugetlb_entry_migration();
  8)   0.032 us    |              is_hugetlb_entry_hwpoisoned();
  8)   2.118 us    |            }
  8)   4.940 us    |          }
  8)   7.468 us    |        }
  8)   0.056 us    |        up_read();
  8)   8.722 us    |      }
  8) + 10.264 us   |    }
  8) + 12.212 us   |  }


cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
