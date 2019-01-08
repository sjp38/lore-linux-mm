Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7B68E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 14:56:23 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id p3so2727213plk.9
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 11:56:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p9si65444391pgc.448.2019.01.08.11.56.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 11:56:22 -0800 (PST)
Date: Tue, 8 Jan 2019 11:56:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V6 0/4] mm/kvm/vfio/ppc64: Migrate compound pages out of
 CMA region
Message-Id: <20190108115620.6ec22e7d60b86d5f609d5a87@linux-foundation.org>
In-Reply-To: <20190108045110.28597-1-aneesh.kumar@linux.ibm.com>
References: <20190108045110.28597-1-aneesh.kumar@linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue,  8 Jan 2019 10:21:06 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> ppc64 use CMA area for the allocation of guest page table (hash page table). We won't
> be able to start guest if we fail to allocate hash page table. We have observed
> hash table allocation failure because we failed to migrate pages out of CMA region
> because they were pinned. This happen when we are using VFIO. VFIO on ppc64 pins
> the entire guest RAM. If the guest RAM pages get allocated out of CMA region, we
> won't be able to migrate those pages. The pages are also pinned for the lifetime of the
> guest.
> 
> Currently we support migration of non-compound pages. With THP and with the addition of
>  hugetlb migration we can end up allocating compound pages from CMA region. This
> patch series add support for migrating compound pages. The first path adds the helper
> get_user_pages_cma_migrate() which pin the page making sure we migrate them out of
> CMA region before incrementing the reference count. 

Does this code do anything for architectures other than powerpc?  If
not, should we be adding the ifdefs to avoid burdening other
architectures with unused code?
