Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 914F0C32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:37:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50723214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:37:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50723214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0C316B0007; Fri,  9 Aug 2019 08:37:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBC3E6B0008; Fri,  9 Aug 2019 08:37:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D36E36B000A; Fri,  9 Aug 2019 08:37:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8213C6B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 08:37:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d27so60224894eda.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 05:37:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XdCTuKRi/cDaELo87hK/o8ea88inhbHFfAajS7lpSSY=;
        b=V2snIs9lD8k6odDpfejL250QCOBZbieYWXkYIZhQbceeE4SdvtqUN+XMFkFDG3mU7s
         J0C9m8W2VGrXQnDQ1U9RS/I9xW69ipuXiQ+eMZQiG1u3dTJ9HIsJwrbTe//2KRkHsjhB
         pUAgMUo6z6cmZ1MZHwUi0rXuZR/rVUZeo3Q+cEwBHgOOEFFhDBycqSboV/2UQjWqvvbd
         rxI2h8SKRUHNFYtEWtMOh2BDVYXzWu2ROU9aNbG6520H+nUe0nzMPMCf3Pv8EU3RpKog
         iqRUc24ZR+ok1ie+du8nadf8byzzWO1exqp3k3W4M9MRMUmXykJGabSG+ftlGm0WDKqj
         ve4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAUI+zGXdEOWqCSX5dx9/6ux4Yre38G/ThfuMODhJ6HxdRZJ+iCA
	vEIS/siPVWZOITcxezLFItTjgU7tPkUR33MefUGcKLfbq0bYacnM2ZPG6o26xcTuqrAN3kJxZT7
	7Z5lnch11aSlnhx+0SmJMIetraALnwpUo/j1itlrobbJKFGsYNyGYfwqpzM2XRGUPLA==
X-Received: by 2002:a17:906:2510:: with SMTP id i16mr18197944ejb.130.1565354271094;
        Fri, 09 Aug 2019 05:37:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxm/DpxEllCvdYBA3cxZDYfPe6knnljiL+/TiSDy/14FOGinukuosrBSfSGMUGn78spEZet
X-Received: by 2002:a17:906:2510:: with SMTP id i16mr18197893ejb.130.1565354270256;
        Fri, 09 Aug 2019 05:37:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565354270; cv=none;
        d=google.com; s=arc-20160816;
        b=fRhjBCiV1TuTVzdgtUnY0w58pgWAbk6FuGPHEdveDuxrfM6MOfapOKws8CJ2AxGgNB
         aMJ1VS0kpGU7Kym2XQ9lOgTfAhWIp9iu/hxibbnyvXRvhnTQtO3UGjBgYujh7cyv60qk
         lb6If8sZS2lsq7QF090lNNwP1ncVLxhQnpZ54H/c+ehRvPTo9cWmpOY3O8nQnQKljg+a
         jU4CrN+MDAMR74MIzcmqm4bZu+DSN9/YpqJ2lJzfYdSQSgypZatQOIrXH+wWHqoZSIaD
         PhGbQmUdVpTqCZBBYdM0uVNeZXE+d8dpHIG5mASvdFBs/JTjk7D0i0RndWm8nGwN+P+J
         ru6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XdCTuKRi/cDaELo87hK/o8ea88inhbHFfAajS7lpSSY=;
        b=b1NgN3eA0PDGv9NhFrgGGb21OyziAuRslwxfKzEPtKgq3zd3W++21CFYBgdcHN+2vI
         VcMWD22M4kNsYRR6TSih9X0swu2FnjHV0e6vDUb6frQwhtysGvH+pC4jLhRXROtrhSGy
         gsflhyfMDbtm/jXME80FQe0Cvi+gGVVMPEM/pjhsBQljkx17iFgUZJXbld9FlwmbT7zG
         117FrzEoQM3dIsXndKlgpScJerPR1T8amKKaiINxn21sAhTD1WiZLP1Z0ZjB78eqRywe
         SpMyqqzYqHy3u2tDAb24VI2w4eTwWEr+yL6QquWqaLNHuUyXUX0a2qZoKPoBEWnmHu5c
         Hm0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id h2si29033942ejj.0.2019.08.09.05.37.49
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 05:37:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6739D1596;
	Fri,  9 Aug 2019 05:37:49 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2EBDE3F706;
	Fri,  9 Aug 2019 05:37:48 -0700 (PDT)
Date: Fri, 9 Aug 2019 13:37:46 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Daniel Axtens <dja@axtens.net>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org,
	aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org,
	linux-kernel@vger.kernel.org, dvyukov@google.com
Subject: Re: [PATCH v3 1/3] kasan: support backing vmalloc space with real
 shadow memory
Message-ID: <20190809123745.GG48423@lakrids.cambridge.arm.com>
References: <20190731071550.31814-1-dja@axtens.net>
 <20190731071550.31814-2-dja@axtens.net>
 <20190808135037.GA47131@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808135037.GA47131@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 02:50:37PM +0100, Mark Rutland wrote:
> From looking at this for a while, there are a few more things we should
> sort out:
 
> * We can use the split pmd locks (used by both x86 and arm64) to
>   minimize contention on the init_mm ptl. As apply_to_page_range()
>   doesn't pass the corresponding pmd in, we'll have to re-walk the table
>   in the callback, but I suspect that's better than having all vmalloc
>   operations contend on the same ptl.

Just to point out: I was wrong about this. We don't initialise the split
pmd locks for the kernel page tables, so we have to use the init_mm ptl.

I've fixed that up in my kasan/vmalloc branch as below, which works for
me on arm64 (with another patch to prevent arm64 from using early shadow
for the vmalloc area).

Thanks,
Mark.

----

static int kasan_populate_vmalloc_pte(pte_t *ptep, unsigned long addr, void *unused)
{
	unsigned long page;
	pte_t pte;

	if (likely(!pte_none(*ptep)))
		return 0;

	page = __get_free_page(GFP_KERNEL);
	if (!page)
		return -ENOMEM;

	memset((void *)page, KASAN_VMALLOC_INVALID, PAGE_SIZE);
	pte = pfn_pte(PFN_DOWN(__pa(page)), PAGE_KERNEL);

	/*
	 * Ensure poisoning is visible before the shadow is made visible
	 * to other CPUs.
	 */
	smp_wmb();

	spin_lock(&init_mm.page_table_lock);
	if (likely(pte_none(*ptep))) {
		set_pte_at(&init_mm, addr, ptep, pte);
		page = 0;
	}
	spin_unlock(&init_mm.page_table_lock);
	if (page)
		free_page(page);
	return 0;
}

int kasan_populate_vmalloc(unsigned long requested_size, struct vm_struct *area)
{
	unsigned long shadow_start, shadow_end;
	int ret;

	shadow_start = (unsigned long)kasan_mem_to_shadow(area->addr);
	shadow_start = ALIGN_DOWN(shadow_start, PAGE_SIZE);
	shadow_end = (unsigned long)kasan_mem_to_shadow(area->addr + area->size),
	shadow_end = ALIGN(shadow_end, PAGE_SIZE);

	ret = apply_to_page_range(&init_mm, shadow_start,
				  shadow_end - shadow_start,
				  kasan_populate_vmalloc_pte, NULL);
	if (ret)
		return ret;

	kasan_unpoison_shadow(area->addr, requested_size);

	/*
	 * We have to poison the remainder of the allocation each time, not
	 * just when the shadow page is first allocated, because vmalloc may
	 * reuse addresses, and an early large allocation would cause us to
	 * miss OOBs in future smaller allocations.
	 *
	 * The alternative is to poison the shadow on vfree()/vunmap(). We
	 * don't because the unmapping the virtual addresses should be
	 * sufficient to find most UAFs.
	 */
	requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
	kasan_poison_shadow(area->addr + requested_size,
			    area->size - requested_size,
			    KASAN_VMALLOC_INVALID);

	return 0;
}

