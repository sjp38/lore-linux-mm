Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3CA7C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:53:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CCF32075A
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:53:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CCF32075A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E94C6B026A; Mon, 22 Apr 2019 15:53:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 098FA6B026B; Mon, 22 Apr 2019 15:53:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC9C86B026C; Mon, 22 Apr 2019 15:53:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C97D16B026A
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:53:11 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id s70so11331287qka.1
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:53:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=6a6jwxrm9aUZlpR4h3QrqJIo69jfmE1/Is/lLoFJC/Y=;
        b=VHE5mCeSxgZcFWoYxO1lBmNEMqorUjJRYmyT560OjcBordrlBcEoN0rOCUGgNC1WUb
         dZbcOHLdIfpKXLuHE9pVQCBdFfp+IaHt3O5eh34YFFfL+8RCuGCsyXZSwdVN54rDMfyR
         /m31WVujC1EV4Y33rNuhpef45xKgk9ZrCVQEpyRSOgG0WY36elXEAA2/OWlkTetQceg8
         u6B8ZRD1yPFTWFHXoYLtjEd/fW3T4cww5I24JREHtzidZsIPzeKowNMDITOZfcKqDHjE
         WBGAjK2LKj8El6hU55sbu2FQ7duuJAx9TBwdMCm2ilbJQFKmIq8ppPvdlV1FXOLKq9T0
         0yBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUScJpORC+BygYZVOKqv/GnuHt51ZDrH/If26s6/oRyo9xyP3/U
	/l/OmDYpnXDcCicPuE1W/qGwSo7rKu47RDE3FVgDgD05vvZRgUQ+sgGQYSHmBx7whGtDvIgtJ9u
	Ktkwn1vdHF4DgN75BCGHk5jj1gCBO6A/QP/ZowlL+X5ZIPatmtRyHkseg5n2S5LwypA==
X-Received: by 2002:a05:620a:15cb:: with SMTP id o11mr16226993qkm.270.1555962791612;
        Mon, 22 Apr 2019 12:53:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiqMxla/ZD8ahB3/APtzvpbYQ2bLJ8KNyj3QaT+IrFFMd5syDUNUulYRtN0xLkL2fRX8Wz
X-Received: by 2002:a05:620a:15cb:: with SMTP id o11mr16226956qkm.270.1555962790979;
        Mon, 22 Apr 2019 12:53:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555962790; cv=none;
        d=google.com; s=arc-20160816;
        b=ytk3mrak3kTojz1tgskI9swLT5KaNkJwKvE4ZbmiyavxpDBf6mo0Oa6F2/FVQGENKe
         +W7K96Cdxt8DD90APKDxXp0x95DFGgekFJqrAygf+w9NsYs8w/MfIEELFP2q0szM+rbH
         aZoL0By+Nvp1vZUaRwnoA0gyTzlkP7RXnN7sac1GeyIQ0cdWXpx1C5kY2As+uS0eCDM5
         7Mam9jakgpAempnSgnhUcB5QuxorLdy79QlTqk0wS56OtyfvMSTBONBHWFIqDQpWq//M
         CqrKNcY0PTKwh9Ov3iXLYdWxZNLHcfx5xwIw+9KLb2X77I+6oOt3/d6Jj258IvOBBW3U
         nwVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=6a6jwxrm9aUZlpR4h3QrqJIo69jfmE1/Is/lLoFJC/Y=;
        b=nosKPhNiRmEjPsIbpnDLkqmGXQshX/wWljJetUb3Esv/swKHGyaq/2WISDL2RXl6V4
         YRFRo/8jNDN0AAdWnsngOJr2NHlkCm97lq/DnFjKHI6gERAr+R2WB2m+6fPPilSAmoqm
         Remg0kNIbuecIBBnMb1L7BxpDV8/zECK7UmAONwHkjYERWxiHUSFmC+o/1kByhFfUM3C
         Pq8HKTPJNeNEeUWemX9GDRtE526QbInWMbkSp/pQ2yxdx0e3WAq1R4VhAMW7CbcWi8/p
         RNivkeieTWQTij+TeAJGq6hkLV5F7gmpXbHZZGNRY74ycPME2UOUqzGyQFNdzCknMF+d
         5MXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e19si2453317qvf.126.2019.04.22.12.53.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 12:53:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 669C7CA1DF;
	Mon, 22 Apr 2019 19:53:09 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BA92F10816BC;
	Mon, 22 Apr 2019 19:53:05 +0000 (UTC)
Date: Mon, 22 Apr 2019 15:53:04 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 12/31] mm: protect SPF handler against anon_vma
 changes
Message-ID: <20190422195303.GC14666@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-13-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-13-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 22 Apr 2019 19:53:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:03PM +0200, Laurent Dufour wrote:
> The speculative page fault handler must be protected against anon_vma
> changes. This is because page_add_new_anon_rmap() is called during the
> speculative path.
> 
> In addition, don't try speculative page fault if the VMA don't have an
> anon_vma structure allocated because its allocation should be
> protected by the mmap_sem.
> 
> In __vma_adjust() when importer->anon_vma is set, there is no need to
> protect against speculative page faults since speculative page fault
> is aborted if the vma->anon_vma is not set.
> 
> When calling page_add_new_anon_rmap() vma->anon_vma is necessarily
> valid since we checked for it when locking the pte and the anon_vma is
> removed once the pte is unlocked. So even if the speculative page
> fault handler is running concurrently with do_unmap(), as the pte is
> locked in unmap_region() - through unmap_vmas() - and the anon_vma
> unlinked later, because we check for the vma sequence counter which is
> updated in unmap_page_range() before locking the pte, and then in
> free_pgtables() so when locking the pte the change will be detected.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  mm/memory.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 423fa8ea0569..2cf7b6185daa 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -377,7 +377,9 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		 * Hide vma from rmap and truncate_pagecache before freeing
>  		 * pgtables
>  		 */
> +		vm_write_begin(vma);
>  		unlink_anon_vmas(vma);
> +		vm_write_end(vma);
>  		unlink_file_vma(vma);
>  
>  		if (is_vm_hugetlb_page(vma)) {
> @@ -391,7 +393,9 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  			       && !is_vm_hugetlb_page(next)) {
>  				vma = next;
>  				next = vma->vm_next;
> +				vm_write_begin(vma);
>  				unlink_anon_vmas(vma);
> +				vm_write_end(vma);
>  				unlink_file_vma(vma);
>  			}
>  			free_pgd_range(tlb, addr, vma->vm_end,
> -- 
> 2.21.0
> 

