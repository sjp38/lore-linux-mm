Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB01DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:07:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6356C21841
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:07:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6356C21841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03C026B0003; Fri, 22 Mar 2019 12:07:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2E406B0006; Fri, 22 Mar 2019 12:07:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF6B86B0007; Fri, 22 Mar 2019 12:07:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7846B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 12:07:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h27so1149091eda.8
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:07:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9piFUH47BOLmZUB3qpkWuFAe6ZS680XROOZksT1OeLs=;
        b=jSebCwZ6oTpmVFIulwNsZUdSRcb6iM3m0wZ2GYmP9QYLXOWR9YTgKbt6r3G2bO5Pqh
         GJ6TlFUCicKLHFhMoclCeNi0vqbDLoMq0u0laTPGwPfm/M1XrXhsOeiY/+gHjA5pC5J+
         85EGobXUAOxXUhrH+uTOvlHiKY63aehD3+sN5jb+MleSkBD/dAH+0VUOXW2ayikCeBhh
         J0zGcHIQlsCR+TjNQ0rCcZqdgd+sIsbwDR5ZSwPKMXYIoB8DyeEyIjM1UyH7MihT7I+g
         cnE3ykE0NQFDTlTJl5Fk79Zb/DZx9HDYEND+L2oj7mHnxirNBL3ep99MgbrnAezoszyY
         TYeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVgYMphlAVVwUkzHr8MqP5tlZxBniIcVhepshaZRVXl0yH75UR+
	3ZnU7FGcWS49cbD08rzj7S+ipTOAzG219moJZzmUyCPeTjxRIFqfzT5LW3VZ7qLWZc7Vczc2CR3
	0Ta6d6st3fy5W0FJ2evQPIljpAOmrttUeiCGIR+Gujeq9DIyjngthwjyIGqAacxD0/w==
X-Received: by 2002:a50:a49c:: with SMTP id w28mr7117231edb.151.1553270859137;
        Fri, 22 Mar 2019 09:07:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMBzesSIh9hRkkalOYro2N3ggg1vBrrNeDww5Zft2BLcwoLrEK00qodPfdOLn5X84TqhH+
X-Received: by 2002:a50:a49c:: with SMTP id w28mr7117192edb.151.1553270858370;
        Fri, 22 Mar 2019 09:07:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553270858; cv=none;
        d=google.com; s=arc-20160816;
        b=CT5Jg6RcV5rVWwwp8a4VXIcbuT2/TOyMRnp7zdZ0ypXUahCIE+ohIM0z8IFKNMKEL/
         WYXMp7KxsUKQtvP5eJkpca4C/xRwp4tFvMohTTK9T5GndnoRNfnO5OHj7PvC1ldvqYJu
         voAYMYDFBfW71bjQfhjgvJulO3phAmNx6Pm33WIIBKH5zS8qm3d5NMXdxlMaLrazwxs/
         2KHGw2PAyM8xx72cR078O97NSDKzCTsgkrN2srb9/pTfE5TFq8os7JdUa77SQUPOUGFc
         5+K8cb98dC5zKxUdS5tYEqWmkofddyWKR7DH4ZZygJff492/zv/woitynJRRjGdQspWQ
         dyXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9piFUH47BOLmZUB3qpkWuFAe6ZS680XROOZksT1OeLs=;
        b=O56W21oyf8h3uQ0hId3RRbQBeH4JjAB7ogjDk43cnZMdwnKT+WvfWFn2gpDljLQnkQ
         v5RYUp6at7zL8ZhXQqpxEzGlRVs+wBbJicLPa0Va1UdHOXaIBGEWWM992LvKGVwzCLG1
         kX2ZCx3T6+wDarZhLbTiFxKdpfYzZpkC2uG/KNsHS4H+2WYVO3UY3CY7aHdRu4351YLt
         P8WvEqp6aI9ToCRvkEpu8L2wnrXPAdqOedCv1grIAbvSoFHNyMgg6xuUbA5PtDH82s7c
         P0Zh3npfNa+r7a1shl7dcQSsPlDrpsFnKm8rbDkDUrnU0hjZYyt8b9fzPp7Gw4PFKWvE
         xKOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 65si2164813edj.98.2019.03.22.09.07.37
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 09:07:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2A446A78;
	Fri, 22 Mar 2019 09:07:37 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6A6A83F59C;
	Fri, 22 Mar 2019 09:07:29 -0700 (PDT)
Date: Fri, 22 Mar 2019 16:07:26 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	bpf@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 17/20] media/v4l2-core, arm64: untag user pointers in
 videobuf_dma_contig_user_get
Message-ID: <20190322160726.GV13384@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <ae6961bcdd82e529c76d0747abd310546f81e58e.1553093421.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ae6961bcdd82e529c76d0747abd310546f81e58e.1553093421.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:51:31PM +0100, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> videobuf_dma_contig_user_get() uses provided user pointers for vma
> lookups, which can only by done with untagged pointers.
> 
> Untag the pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  drivers/media/v4l2-core/videobuf-dma-contig.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
> index e1bf50df4c70..8a1ddd146b17 100644
> --- a/drivers/media/v4l2-core/videobuf-dma-contig.c
> +++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
> @@ -160,6 +160,7 @@ static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
>  static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
>  					struct videobuf_buffer *vb)
>  {
> +	unsigned long untagged_baddr = untagged_addr(vb->baddr);
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma;
>  	unsigned long prev_pfn, this_pfn;
> @@ -167,22 +168,22 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
>  	unsigned int offset;
>  	int ret;
>  
> -	offset = vb->baddr & ~PAGE_MASK;
> +	offset = untagged_baddr & ~PAGE_MASK;
>  	mem->size = PAGE_ALIGN(vb->size + offset);
>  	ret = -EINVAL;
>  
>  	down_read(&mm->mmap_sem);
>  
> -	vma = find_vma(mm, vb->baddr);
> +	vma = find_vma(mm, untagged_baddr);
>  	if (!vma)
>  		goto out_up;
>  
> -	if ((vb->baddr + mem->size) > vma->vm_end)
> +	if ((untagged_baddr + mem->size) > vma->vm_end)
>  		goto out_up;
>  
>  	pages_done = 0;
>  	prev_pfn = 0; /* kill warning */
> -	user_address = vb->baddr;
> +	user_address = untagged_baddr;
>  
>  	while (pages_done < (mem->size >> PAGE_SHIFT)) {
>  		ret = follow_pfn(vma, user_address, &this_pfn);

I don't think vb->baddr here is anonymous mmap() but worth checking the
call paths.

-- 
Catalin

