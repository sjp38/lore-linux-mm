Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EADCC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:22:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B84BF218FC
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:22:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B84BF218FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 514876B0003; Fri, 22 Mar 2019 12:22:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EA796B0006; Fri, 22 Mar 2019 12:22:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B3A36B0007; Fri, 22 Mar 2019 12:22:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E283E6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 12:22:36 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l19so1167162edr.12
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:22:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=U3avf4nu9NHLhK4SC+AqgteIOgyhj8iQFTaEXfqMpE4=;
        b=sEKS2z4yD4KJs4lUbv42kMgv8JJ5oXOSAZGAZpJECqQSSlCWJ8aZ79IH6/dk2Hez2T
         EUJ/Bii8Sv8tyk4IpCIJII9qJvkuK2yMjlWmTOhhSU7JxS7Mucdbwmy5rDqn5+jU0qRd
         a1YAQsV/8NtVC0/MG57mLMY6JszyW6bkgrxM7akVlnPVZBdSg7bXytPUWeyfRmIlv3si
         6Dl8fV/hg491bXhe6ouHc2zDxHkpGYh2es1KjIvN5/7boVkj8/IRd+QmNOxqf+T/0ZA8
         CPNJS8So3p2H4O13LQIVIvunWMJuFjSKyGr3fFIE0eq/cddEjVZpxJNUKLVzUCyn1F8J
         VNyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAX9o03kfsFGdbF3eHo8VLqUR7y4SBaWxMBtrOrkmUP0u2yPdfos
	2DB6PW00pB4C1cjphLMwkiFkIYD9F7T9OuJ44r2F6ZRQRvGLHqMJenH9xu5Sa16bXb7Lfri+699
	SSA/VPCW2wYoEcKdRQ65TKbQXIY7lxM212bGZGKdBGyVYo0n/uSB9wnG3OJVt8foSzg==
X-Received: by 2002:a50:b646:: with SMTP id c6mr7070979ede.149.1553271756479;
        Fri, 22 Mar 2019 09:22:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXLHa6Taq81iL0jrVaZ++TnhFfZfmMQwGhN35i+F6TFE7pF/68gNAS1lBvcT07OJHY4mzA
X-Received: by 2002:a50:b646:: with SMTP id c6mr7070938ede.149.1553271755585;
        Fri, 22 Mar 2019 09:22:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553271755; cv=none;
        d=google.com; s=arc-20160816;
        b=X0IEeMt13RsoPBICsOIn6cs/5ri9guqvJ8F528TuK7K/dammjPMtIyMUOd4NzjZYTo
         rMbeHu0cdjgTaAcTi9q+E2P1AI4G6RWqn9L+5IK6qnnd9N8zo/ps0sOxgaOnbfwwvwIF
         6i7rgfFDizJ47L4I4BDO1X/OJG27QI/+0ZpV2nNgKHTZSqlspfW6Xo+JP2AtBPdZxTPs
         arJiGA/ID3MsPTKVRDPcizTZZi9/k+yExwf+lWcmRAbENMq+uDSUzUalMGHDZuJd9+nR
         jzLahrSynpZlfKGYv+mc157074FqyCf0MI0t/ldG8YoL6uqiEeikHEgktrAgPei0iJiC
         kxWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=U3avf4nu9NHLhK4SC+AqgteIOgyhj8iQFTaEXfqMpE4=;
        b=xaZvLh1+CiHmJZr6L6Kn0c8FS+bN4PyoqStEmweSir5FnDsToLHMviyCQDp78RQ8v8
         Mqer3SIXJG0NJm9Bz2XytYrJCtnSjxGBfCnQwZLJ3r9l1ZlxTDBPkoO/XmUd2ld4de0B
         p0fVI9pMxIcyod0rMtQN9Y5QMUIVYQiRMBVfyiwhvxW5bIiFWhIMqDRLHmMTZXIZEE6T
         xACmMn3lrkcmHlKxoGFVFoLIl8ZWJErzGbX81ncPqdOOG96Di5yL3GIByJJr5c9KXnJ+
         if2dqyXR+bqwt59wWi7NUq4Pw7XXjMdT9/4+JDh4/mwmoA058iE8U1i66kVuBxKpHCqC
         Y8ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a48si441054edd.336.2019.03.22.09.22.35
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 09:22:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 43FBC165C;
	Fri, 22 Mar 2019 09:22:34 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 622FE3F73D;
	Fri, 22 Mar 2019 09:22:26 -0700 (PDT)
Date: Fri, 22 Mar 2019 16:22:23 +0000
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
Subject: Re: [PATCH v13 18/20] tee/optee, arm64: untag user pointers in
 check_mem_type
Message-ID: <20190322162223.GW13384@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <665632a911273ab537ded9acb78f4bafd91cbc19.1553093421.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <665632a911273ab537ded9acb78f4bafd91cbc19.1553093421.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:51:32PM +0100, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> check_mem_type() uses provided user pointers for vma lookups (via
> __check_mem_type()), which can only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  drivers/tee/optee/call.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/tee/optee/call.c b/drivers/tee/optee/call.c
> index a5afbe6dee68..e3be20264092 100644
> --- a/drivers/tee/optee/call.c
> +++ b/drivers/tee/optee/call.c
> @@ -563,6 +563,7 @@ static int check_mem_type(unsigned long start, size_t num_pages)
>  	int rc;
>  
>  	down_read(&mm->mmap_sem);
> +	start = untagged_addr(start);
>  	rc = __check_mem_type(find_vma(mm, start),
>  			      start + num_pages * PAGE_SIZE);
>  	up_read(&mm->mmap_sem);

I guess we could just untag this in tee_shm_register(). The tag is not
relevant to a TEE implementation (firmware) anyway.

-- 
Catalin

