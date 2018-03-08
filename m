Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B896D6B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 18:53:43 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m78so216224wma.7
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 15:53:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v8si15982493wre.321.2018.03.08.15.53.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 15:53:42 -0800 (PST)
Date: Thu, 8 Mar 2018 15:53:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] hugetlbfs: check for pgoff value overflow
Message-Id: <20180308155339.de99d2ddde514e3980e3ef96@linux-foundation.org>
In-Reply-To: <a5e3c0c4-d41e-6ffd-935d-63cce2527d0f@oracle.com>
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
	<20180308210502.15952-1-mike.kravetz@oracle.com>
	<20180308141533.d16e43f5f559215089e522ae@linux-foundation.org>
	<a5e3c0c4-d41e-6ffd-935d-63cce2527d0f@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, stable@vger.kernel.org

On Thu, 8 Mar 2018 15:37:57 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Here are a couple options for computing the mask.  I changed the name
> you suggested to make it more obvious that the mask is being used to
> check for loff_t overflow.
> 
> If we want to explicitly comptue the mask as in code above.
> #define PGOFF_LOFFT_MAX \
> 	(((1UL << (PAGE_SHIFT + 1)) - 1) <<  (BITS_PER_LONG - (PAGE_SHIFT + 1)))
> 
> Or, we use PAGE_MASK
> #define PGOFF_LOFFT_MAX (PAGE_MASK << (BITS_PER_LONG - (2 * PAGE_SHIFT) - 1))

Sounds good.

> In either case, we need a big comment explaining the mask and
> how we have that extra bit +/- 1 because the offset will be converted
> to a signed value.

Yup.

> > Also, we later to
> > 
> > 	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> > 	/* check for overflow */
> > 	if (len < vma_len)
> > 		return -EINVAL;
> > 
> > which is ungainly: even if we passed the PGOFF_T_MAX test, there can
> > still be an overflow which we still must check for.  Is that avoidable?
> > Probably not...
> 
> Yes, it is required.  That check takes into account the length argument
> which is added to page offset.  So, yes you can pass the first check and
> fail this one.

Well I was sort of wondering if both checks could be done in a single
operation, but I guess not.
