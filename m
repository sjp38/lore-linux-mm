Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4897C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:04:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BFDF214C6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:04:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BFDF214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEB446B0005; Thu, 18 Apr 2019 18:04:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B98CD6B0006; Thu, 18 Apr 2019 18:04:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A60A56B0007; Thu, 18 Apr 2019 18:04:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 803306B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:04:23 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id w124so2861821qkb.12
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:04:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=tyEzvmi1ltlh+d4J9zZ5afQKA5IBdDefFfiK4M/glPQ=;
        b=OQUDGGIM/heyEHW9PNPhWps5H+MhscLdTqbNK9mmV2WpxzwTQ1cWnJ8CAUqXDWJRvq
         qyZnumAgwFmI29+pxGVhPTKyvpS+jKV1lPgfiB6NoCqJHPX1KFVkp7SHweJEeqNe73UW
         IucxwjrTGtHPkpAGeSX0mcc/8RRM6HIFZkeI2/h6lPWEBXIw82RuVAVtanuPCZr9VWrP
         qqzZSyodwtn+MCax+EGS3YesJTg4uNo/I7HYBlcOvgbUnt+Xmh0KAB6vN+7Pco02Vdwr
         a7c9m2S9hKB9MOXtUM6vJnlA0RejkDg/V70pi7bdOLyAsDHNs+t8vyJVlDEeOywkx7wF
         TZWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUA7ef8+idjtpMOkSAIzUpUROMsrifeSRtCoYtvAlyT8k5W9VUv
	jWD66ac55NLi05OmfvcfK44pD1Hqsqmp1sj73g0GXZ89gdYO8nuNrl7RgOO/IcPEp2pXdBxBLqB
	aMv+8E6vfzGXxQbFkg5Fbq9CRQu5rVW8EYXpa2bVg9CpJTit2N32BQdmgxRJAfcNSPQ==
X-Received: by 2002:a05:620a:1352:: with SMTP id c18mr337682qkl.303.1555625063306;
        Thu, 18 Apr 2019 15:04:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzfoBC4u0u/UvXEyPjKT2jo8OuskPsYDpUny2mGFHGfLU+gxUAQJn32cKWOo2yUaJc08rZ
X-Received: by 2002:a05:620a:1352:: with SMTP id c18mr337630qkl.303.1555625062596;
        Thu, 18 Apr 2019 15:04:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555625062; cv=none;
        d=google.com; s=arc-20160816;
        b=OSoAbefUvBoFLve2Lx2ez0HBShKPE/iE8QIjXrgtH+NNKCkEZHjYIEk3+OlB+KJvOj
         Sy2i2qTyiU13h3q7RE57HEAKxMGquvO2C3IJcm5QPdm6C7Eez362D3dGNS+I8Era5bm2
         PJnOGxvX6baFvSZRf3fSbv8yDi7hBDnJ3fbXBBhxjgtApfCUkIUjYGQRFbxm5NhOHSSK
         mQN44hUkppDb+iOPGQs7uONoHrjvl9pRF2JGh2R4p4i8SOG3rPPfwDWig008SHJDctXf
         9cxtkQ9a3A5bZN+TOl29i7ZWvxIF+eJNIAtUrxkLNqdJyta9SgcJxMM4eznIE4JWaShE
         DP8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=tyEzvmi1ltlh+d4J9zZ5afQKA5IBdDefFfiK4M/glPQ=;
        b=DmPZJUx2pGqxfaThqdlHh8mBNY6/JU/3p1mymZEYyz8I2l2LR2izkxYXQq4e19M2cp
         7bhybUomkN9fZnTWN+9vE6o5HQoSzIN2Y3UaSsuTUter5AMXQLa+P1d+4wlSq/PCt5Rg
         yWpWJhGQTMqVtAo3/oH82m4Iwd554wkdKswjmef2PSatAZxFY+iCwcJkDRtE5MF3Ed6Q
         Iv9cJIVOz988ZdUnK0YZb0G+ZwTKulrGNXnL/TBzBHEGLW97LiCWrk7MWubTG3azcGs7
         FkD5ppL0niCMeR4HysDMJj6GUCesMLZmeMlilYgkKcYnvcejMGiSFOAiNHSDaR0cKjgL
         671w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k22si1267440qvg.31.2019.04.18.15.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 15:04:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F159830832D8;
	Thu, 18 Apr 2019 22:04:20 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1648D60851;
	Thu, 18 Apr 2019 22:04:17 +0000 (UTC)
Date: Thu, 18 Apr 2019 18:04:15 -0400
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
Subject: Re: [PATCH v12 05/31] mm: prepare for FAULT_FLAG_SPECULATIVE
Message-ID: <20190418220415.GE11645@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-6-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-6-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 18 Apr 2019 22:04:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:44:56PM +0200, Laurent Dufour wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> When speculating faults (without holding mmap_sem) we need to validate
> that the vma against which we loaded pages is still valid when we're
> ready to install the new PTE.
> 
> Therefore, replace the pte_offset_map_lock() calls that (re)take the
> PTL with pte_map_lock() which can fail in case we find the VMA changed
> since we started the fault.
> 
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> 
> [Port to 4.12 kernel]
> [Remove the comment about the fault_env structure which has been
>  implemented as the vm_fault structure in the kernel]
> [move pte_map_lock()'s definition upper in the file]
> [move the define of FAULT_FLAG_SPECULATIVE later in the series]
> [review error path in do_swap_page(), do_anonymous_page() and
>  wp_page_copy()]
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  mm/memory.c | 87 +++++++++++++++++++++++++++++++++++------------------
>  1 file changed, 58 insertions(+), 29 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index c6ddadd9d2b7..fc3698d13cb5 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2073,6 +2073,13 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>  }
>  EXPORT_SYMBOL_GPL(apply_to_page_range);
>  
> +static inline bool pte_map_lock(struct vm_fault *vmf)

I am not fan of the name maybe pte_offset_map_lock_if_valid() ? But
that just a taste thing. So feel free to ignore this comment.


> +{
> +	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
> +				       vmf->address, &vmf->ptl);
> +	return true;
> +}
> +
>  /*
>   * handle_pte_fault chooses page fault handler according to an entry which was
>   * read non-atomically.  Before making any commitment, on those architectures

