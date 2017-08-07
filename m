Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7B706B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:24:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x43so1556795wrb.9
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:24:11 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s2si9859718edk.134.2017.08.07.11.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:24:10 -0700 (PDT)
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
References: <20170806140425.20937-1-riel@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a0d79f77-f916-d3d6-1d61-a052581dbd4a@oracle.com>
Date: Mon, 7 Aug 2017 11:23:50 -0700
MIME-Version: 1.0
In-Reply-To: <20170806140425.20937-1-riel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On 08/06/2017 07:04 AM, riel@redhat.com wrote:
> v2: fix MAP_SHARED case and kbuild warnings
> 
> Introduce MADV_WIPEONFORK semantics, which result in a VMA being
> empty in the child process after fork. This differs from MADV_DONTFORK
> in one important way.

It seems that the target use case might be private anonymous mappings.
If a shared or file backed mapping exists, one would assume that it
was created with the intention of sharing, even across fork.  So,
setting MADV_DONTFORK on such a mapping seems to change the meaning
and conflict with the original intention of the mapping.

If my thoughts above are correct, what about returning EINVAL if one
attempts to set MADV_DONTFORK on mappings set up for sharing?

If not, and you really want this to be applicable to all mappings, then
you should be more specific about what happens at fork time.  Do they
all get turned into anonymous mappings?  What happens to file references?
What about the really ugly case of hugetlb mappings?  Do they get
'transformed' to non-hugetlb mappings?  Or, do you create a separate
hugetlb mapping for the child?

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
