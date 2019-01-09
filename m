Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8408E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 20:54:05 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id b16so5172378qtc.22
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 17:54:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 95si1462753qvc.202.2019.01.08.17.54.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 17:54:04 -0800 (PST)
Date: Tue, 8 Jan 2019 20:53:59 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH V6 3/4] powerpc/mm/iommu: Allow migration of cma
 allocated pages during mm_iommu_get
Message-ID: <20190109015359.GE20586@redhat.com>
References: <20190108045110.28597-1-aneesh.kumar@linux.ibm.com>
 <20190108045110.28597-4-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190108045110.28597-4-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Hello,

On Tue, Jan 08, 2019 at 10:21:09AM +0530, Aneesh Kumar K.V wrote:
> @@ -187,41 +149,25 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
>  		goto unlock_exit;
>  	}
>  
> +	ret = get_user_pages_cma_migrate(ua, entries, 1, mem->hpages);

In terms of gup APIs, I've been wondering if this shall become
get_user_pages_longerm(FOLL_CMA_MIGRATE). So basically moving this
CMA migrate logic inside get_user_pages_longerm.

It depends if powerpc will ever need to bail on dax and/or if other
non-powerpc vfio drivers which are already bailing on dax may also
later optionally need to avoid interfering with CMA.

Aside from the API detail above, this CMA page migration logic seems a
good solution for the problem.

Thanks,
Andrea
