Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 498D86B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 15:11:10 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id hi2so7664520wib.1
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 12:11:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cw9si90577wib.94.2015.02.12.12.11.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 12:11:08 -0800 (PST)
Message-ID: <54DD08BC.2020008@redhat.com>
Date: Thu, 12 Feb 2015 15:10:36 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 03/24] mm: avoid PG_locked on tail pages
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com> <1423757918-197669-4-git-send-email-kirill.shutemov@linux.intel.com> <54DD054E.7000605@redhat.com>
In-Reply-To: <54DD054E.7000605@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/12/2015 02:55 PM, Rik van Riel wrote:
> On 02/12/2015 11:18 AM, Kirill A. Shutemov wrote:

>> @@ -490,6 +493,7 @@ extern int 
>> wait_on_page_bit_killable_timeout(struct page *page,
> 
>> static inline int wait_on_page_locked_killable(struct page *page)
>>  { +	page = compound_head(page); if (PageLocked(page)) return 
>> wait_on_page_bit_killable(page, PG_locked); return 0; @@ -510,6 
>> +514,7 @@ static inline void wake_up_page(struct page *page, int 
>> bit) */ static inline void wait_on_page_locked(struct page *page)
>>  { +	page = compound_head(page); if (PageLocked(page)) 
>> wait_on_page_bit(page, PG_locked); }
> 
> These are all atomic operations.
> 
> This may be a stupid question with the answer lurking somewhere in
> the other patches, but how do you ensure you operate on the right
> page lock during a THP collapse or split?

Kirill answered that question on IRC.

The VM takes a refcount on a page before attempting to take a page
lock, which prevents the THP code from doing anything with the
page. In other words, while we have a refcount on the page, we
will dereference the same page lock.

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU3Qi8AAoJEM553pKExN6D/44H/jUIn9btSRRIje/YBFFib8Dt
Zlvn4bFD6MbFonTQMJA5+vb6s0gxwdkbwLqGKpRo+FHWnKDxCvEpQfxuj708LaCq
1tqjnKIv1xt5bz31pV/UQhdAMcbcyKdEu4udH5mQigh4HIXYhUhe4w9TMUGu/f4U
FTx7dn3FfhQT3qWTVdZubdY/JRIXJcaXYqVIauvXQCRsCHfmx5YHD5YLulXP9OKw
HP0baxtbxP5njNPthbb9T947dcdndbBiwt3+Rnnlw4Ij4fB2kX7kvOC4M8v0eKKA
wKZ7A0sfzp27kJT7N/HlwGOXnX/e28LMbK7zA1avi5JDIIAYQU1Ris67EXTSKlg=
=1q7l
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
