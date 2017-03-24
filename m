Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5D06B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 06:38:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d66so10090211wmi.2
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 03:38:42 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 32si2610944wrc.11.2017.03.24.03.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 03:37:12 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id x124so2380474wmf.3
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 03:37:11 -0700 (PDT)
Date: Fri, 24 Mar 2017 13:37:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 0/2] Add hstate parameter to huge_pte_offset()
Message-ID: <20170324103709.253qw6pyjaq5wrgb@node.shutemov.name>
References: <20170323125823.429-1-punit.agrawal@arm.com>
 <bde0d8a5-f361-ef4e-5cb3-1615bc2a98b0@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bde0d8a5-f361-ef4e-5cb3-1615bc2a98b0@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tyler Baicar <tbaicar@codeaurora.org>

On Thu, Mar 23, 2017 at 01:55:27PM -0700, Mike Kravetz wrote:
> On 03/23/2017 05:58 AM, Punit Agrawal wrote:
> > On architectures that support hugepages composed of contiguous pte as
> > well as block entries at the same level in the page table,
> > huge_pte_offset() is not able to determine the right offset to return
> > when it encounters a swap entry (which is used to mark poisoned as
> > well as migrated pages in the page table).
> > 
> > huge_pte_offset() needs to know the size of the hugepage at the
> > requested address to determine the offset to return - the current
> > entry or the first entry of a set of contiguous hugepages. This came
> > up while enabling support for memory failure handling on arm64[0].
> > 
> > Patch 1 adds a hstate parameter to huge_pte_offset() to provide
> > additional information about the target address. It also updates the
> > signatures (and usage) of huge_pte_offset() for architectures that
> > override the generic implementation. This patch has been compile
> > tested on ia64 and x86.
> 
> I haven't looked at the performance implications of making huge_pte_offset
> just a little slower.  But, I think you can get hstate from the parameters
> passed today.
> 
> vma = find_vma(mm, addr);
> h = hstate_vma(vma);

It's better to avoid find_vma() in fast(?) path if possible. So passing it
down is probably better.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
