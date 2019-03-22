Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F59CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:00:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BC3621900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:00:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BC3621900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D61F76B0003; Fri, 22 Mar 2019 12:00:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE8E26B0006; Fri, 22 Mar 2019 12:00:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8A936B0007; Fri, 22 Mar 2019 12:00:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64EED6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 12:00:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l19so1139763edr.12
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:00:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=L+7vbqv/vYYbQSi5OAbJf+UfpvaXib6plNTlGaAQ3BM=;
        b=PqR75iTsgBu/6pUFiPYlP5v0TENJVmnJaGwdQz/+r64/fTI4U2XAg65pr/08A9Mwdi
         +0fISLhSbmn6UecaXrR1m4DTAcnDH/DwJDStJQThxk4MLzpNjTV0N88/FWFFUQhvaxkk
         PiOrX+vuz+U025F7Phc4bZuR3A9STjRM5WZf2T447+glFL6gMorh57S30NvXeU6bICTQ
         lr9cv1i3KoLgGWv7DgH1RmSac6X5CQNGD2rOH90GYrL6tdc2TAwab5C+sSDfnizhH2D+
         1RuCxqwHg6aa6X8MJQs4P9RIy3MDab4Bkg+xtjGBmFYNBdUI2Q4hbTlr5QXM0th5M7Ht
         LZfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAX/Xl+95gAvnDW1Pch+bnHJc9UqHqaoSMXiPYmk59x2jMiOnTVt
	hcbVWpdSxbn3WPQc12pKCTW1xqx4snK60HPaO09hZ5KyZfFggBbZ9uKq9yetX+WL/ah78TMzVPe
	oXNKwuIxVY+C1JUaVvt2gbsDF3YvfWOU7JhC56SvgPp8lum4pgIOZuVMqbNUaswdIrg==
X-Received: by 2002:a50:b1fa:: with SMTP id n55mr6963250edd.34.1553270407985;
        Fri, 22 Mar 2019 09:00:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4s0B0qzPVDR/9V1HB+903Sfoh9y5qV4McaGCK1mxy5UYetyHQfhC0BNvAykqlzgxW8SKi
X-Received: by 2002:a50:b1fa:: with SMTP id n55mr6963207edd.34.1553270407255;
        Fri, 22 Mar 2019 09:00:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553270407; cv=none;
        d=google.com; s=arc-20160816;
        b=AWEyFuGZR5Efl/rV2/FncQ6AA4xRcfEyOgywt1+3G08HiXOLoqh1h/5iL4CzIhGfTF
         8qlfLRTj1tW/zKSAiCnTTjL9x8hNyiojRqK5CUSRgMkXvFs6RQMVWRXChhdppgAuUqRl
         ATvEw31/AcHRwubJWeAjDuXzMdXiS71fil7QwtcIpoWVeuN0Q4UVk5n9xCg2BpRcbhpj
         h788PPfYZn7prlT7ujbXTgceHx2goSGfYu4E6rLNbXTaDW9nDq08rAYnll8JEgaK0uBk
         lm4PXH/vPrysdbe/TkONGBpf6uikqEWAnG4pJANS5FNj4ZS36NFSuDUHq5lOHlM7nlf2
         wOIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=L+7vbqv/vYYbQSi5OAbJf+UfpvaXib6plNTlGaAQ3BM=;
        b=NJNrsOWJ50Jhvz9DpXsIWGVzmqPU3BZjGiQ3F4hCEwcDNpFeX7I3Sx8b/CRe5XdBoP
         aYxjDsCqslC5JPvVEw2kbeBzMIcfpWArUuE9FVwaKz/J2mjGSE8ExGOcx2Iah76cbq6R
         JvvEsZfvoHxVoqfFX6qKdnhIduj+5SJoB2sK0UaeTCAghrvkKDj+4KICP01fyq5O6kK4
         ZBcMFBj7VuIrS/2r0KpT6isGAeOy7Tc6Ah1pZAFhZ+EPU8yUrLsypCGyEJiDU71SBeQp
         p//cEGb/YvqxO+q1pBUETm7mIuvE+u223Wiu4i8rYYogkswnkbuFKv7RJ9+cny6wyHhV
         WvCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y22si679954edm.291.2019.03.22.09.00.06
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 09:00:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BDC7CA78;
	Fri, 22 Mar 2019 09:00:05 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DBB853F59C;
	Fri, 22 Mar 2019 08:59:57 -0700 (PDT)
Date: Fri, 22 Mar 2019 15:59:55 +0000
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
Subject: Re: [PATCH v13 14/20] drm/amdgpu, arm64: untag user pointers in
 amdgpu_ttm_tt_get_user_pages
Message-ID: <20190322155955.GT13384@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <017804b2198a906463d634f84777b6087c9b4a40.1553093421.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <017804b2198a906463d634f84777b6087c9b4a40.1553093421.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:51:28PM +0100, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> amdgpu_ttm_tt_get_user_pages() uses provided user pointers for vma
> lookups, which can only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> index 73e71e61dc99..891b027fa33b 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> @@ -751,10 +751,11 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
>  		 * check that we only use anonymous memory to prevent problems
>  		 * with writeback
>  		 */
> -		unsigned long end = gtt->userptr + ttm->num_pages * PAGE_SIZE;
> +		unsigned long userptr = untagged_addr(gtt->userptr);
> +		unsigned long end = userptr + ttm->num_pages * PAGE_SIZE;
>  		struct vm_area_struct *vma;
>  
> -		vma = find_vma(mm, gtt->userptr);
> +		vma = find_vma(mm, userptr);
>  		if (!vma || vma->vm_file || vma->vm_end < end) {
>  			up_read(&mm->mmap_sem);
>  			return -EPERM;

I tried to track this down but I failed to see whether user could
provide an tagged pointer here (under the restrictions as per Vincenzo's
ABI document).

-- 
Catalin

