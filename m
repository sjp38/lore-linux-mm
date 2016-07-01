Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id A03306B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 21:55:02 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id he1so178567463pac.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 18:55:02 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id g70si1054781pfb.119.2016.06.30.18.55.01
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 18:55:01 -0700 (PDT)
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
 <20160701001218.3D316260@viggo.jf.intel.com>
 <5A585093-4E0D-49BC-A9CA-0072BB83A71C@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5775CD73.2070809@sr71.net>
Date: Thu, 30 Jun 2016 18:54:59 -0700
MIME-Version: 1.0
In-Reply-To: <5A585093-4E0D-49BC-A9CA-0072BB83A71C@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, dave.hansen@linux.intel.com

On 06/30/2016 06:50 PM, Nadav Amit wrote:
> Dave Hansen <dave@sr71.net> wrote:
>> +pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
>> +		       pte_t *ptep)
>> +{
>> +	struct mm_struct *mm = vma->vm_mm;
>> +	pte_t pte;
>> +
>> +	pte = ptep_get_and_clear(mm, address, ptep);
>> +	if (pte_accessible(mm, pte)) {
>> +		flush_tlb_page(vma, address);
>> +		/*
>> +		 * Ensure that the compiler orders our set_pte()
>> +		 * after the flush_tlb_page() no matter what.
>> +		 */
>> +		barrier();
> 
> I dona??t think such a barrier (after remote TLB flush) is needed.
> Eventually, if a remote flush takes place, you get csd_lock_wait() to be
> called, and then smp_rmb() is called (which is essentially a barrier()
> call on x86).

Andi really wanted to make sure this got in here.  He said there was a
bug that bit him really badly once where a function got reordered.
Granted, a call _should_ be sufficient to keep the compiler from
reordering things, but this makes double sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
