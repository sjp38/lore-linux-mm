Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82E126B0005
	for <linux-mm@kvack.org>; Tue, 22 May 2018 16:29:02 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id x194-v6so8732216qkb.19
        for <linux-mm@kvack.org>; Tue, 22 May 2018 13:29:02 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g14-v6si2241055qtc.31.2018.05.22.13.29.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 13:29:01 -0700 (PDT)
Subject: Re: [PATCH v2 0/7] mm: pages for hugetlb's overcommit may be able to
 charge to memcg
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
 <240f1b14-ed7d-4983-6c52-be4899d4caa5@oracle.com>
 <8711fed5-fc35-a11a-3a17-740a9dca1f2a@ascade.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5c32a05e-da2e-84b8-3435-4cd5f8a1f0f9@oracle.com>
Date: Tue, 22 May 2018 13:28:30 -0700
MIME-Version: 1.0
In-Reply-To: <8711fed5-fc35-a11a-3a17-740a9dca1f2a@ascade.co.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: TSUKADA Koutaro <tsukada@ascade.co.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On 05/22/2018 06:04 AM, TSUKADA Koutaro wrote:
> 
> I stared at the commit log of mm/hugetlb_cgroup.c, but it did not seem to
> have specially considered of surplus hugepages. Later, I will send a mail
> to hugetlb cgroup's committer to ask about surplus hugepages charge
> specifications.
> 

I went back and looked at surplus huge page allocation.  Previously, I made
a statement that the hugetlb controller accounts for surplus huge pages.
Turns out that may not be 100% correct.

Thanks to Michal, all surplus huge page allocation is performed via the
alloc_surplus_huge_page() routine.  This will ultimately call into the
buddy allocator without any cgroup charges.  Calls to alloc_surplus_huge_page
are made from:
- alloc_huge_page() when allocating a huge page to a mapping/file.  In this
  case, appropriate calls to the hugetlb controller are in place.  So, any
  limits are enforced here.
- gather_surplus_pages() when allocating and setting aside 'reserved' huge
  pages. No accounting is performed here.  Do note that in this case the
  allocated huge pages are not assigned to the mapping/file.  Even though
  'reserved', they are deposited into the global pool and also counted as
  'free'.  When these reserved pages are ultimately used to populate a
  file/mapping, the code path goes through alloc_huge_page() where appropriate
  calls to the hugetlb controller are in place.

So, the bottom line is that surplus huge pages are not accounted for when
they are allocated as 'reserves'.  It is not until these reserves are actually
used that accounting limits are checked.  This 'seems' to align with general
allocation of huge pages within the pool.  No accounting is done until they
are actually allocated to a mapping/file.

-- 
Mike Kravetz
