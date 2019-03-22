Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C047EC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:52:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C566218D4
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:52:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C566218D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21AE46B0003; Fri, 22 Mar 2019 11:52:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CB656B0006; Fri, 22 Mar 2019 11:52:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0939C6B0007; Fri, 22 Mar 2019 11:52:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A23246B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:52:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x98so1122393ede.18
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:52:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=44Lk7/XAV/cA+wYYlUAPAkCTF4YFrsk2oNtHUYWdZIw=;
        b=khsQH+lFgDkp+i40UHkq6Wh0DTEchDHeIVQowvFAfqx1+RpEJ/DCQ74lC+roGyfUSj
         E8a9ltxPhHa9y5Qk3WieAtJgc56fiATKgm/iFlLKvGmwgSIGI6LdxtkHak1vcdaTbqc3
         Xok70hW/Y+e8+ZJU2OhoIexz/bQx3AqWeqCupzV/aqCT79rc4D2vbUgtpM88CA8fAfcK
         rCH80LofxWHpGj1ZtFmulF7IDGEN0DyL5IDmkfpTKDUYuXtpVuF1IUzxjJ6kGckrEyNF
         Jv7aoaLipyQ0UibFZdSRkyLYMdiAAGtA+43bWoe72I4mq50/AGPInWfahJ2eLMBIRg4y
         miOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXxRLRJAmzBJwGCZMW5RWVvGvTrvW+sUGrjglB9JVOvfCnfGL2+
	psG3bvZz6cv9APX1GTJd86AUBLxuxnb5cncOtr7B3/7HX6Eee/LNr84ZBaATMXqtKY6I9pbSu6C
	PPOwZqlw0+pUNH+xiDuhhUyUbFWpUwigdHB+bEU2sku0IU6TWuIaYbQe3DjgI0JTJmg==
X-Received: by 2002:a17:906:4342:: with SMTP id z2mr5914550ejm.172.1553269960205;
        Fri, 22 Mar 2019 08:52:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwI8VC9A8ciWWaJAWx1COUJNsAl5ekLOSW4XEQDAEq3Hd7TC86tWfl+d0A+2gWgmvHdOKLr
X-Received: by 2002:a17:906:4342:: with SMTP id z2mr5914506ejm.172.1553269959167;
        Fri, 22 Mar 2019 08:52:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553269959; cv=none;
        d=google.com; s=arc-20160816;
        b=HhSPlmHBHg73hS5Avn3OmCw+538mV6xx19OZ8eTatIapvUY1WtdV7NoIGfAlZao2rj
         jK//yribXtQe1pw1JuFEDVIPRoFLlVHkttct2ps/nx9UKtlzFFttIpatmDkfXxlxgAvH
         mfEXdaE+FozLXStZxoprZFUFfufPyvSWSk+BxehjNMUfAWr4w+ffKpvcc9Oy3Sy/CfVO
         IsNyXNXSsAylASuzvIFDSo9px8Lirp8/FSrVpGIZ+vZjD8hKQXORQDi9bs5ohCuXbl46
         LMFpDRPc1esiefAV47c5w+fyYaiITC7Y73y3arJZJV+j4W1mICMw9U/wVyETjwdyQYaP
         g4dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=44Lk7/XAV/cA+wYYlUAPAkCTF4YFrsk2oNtHUYWdZIw=;
        b=dLWtgXwxD9GS2t8yCo6/qx+kudu4dlN9S41ksRCq3Q21XUiGRUPyxLIWzePgB28GCE
         Wwvs3VfT1bRNO4hxywiadO7D2tq8BndaLrPTM4yA+i0zihUKAkUbEVfRC5N7e4OVKw1+
         6/zvbMwM6Grk5ibK+4igxC7HsDQBkBhaD/ym/rYmZIwpcW76g/kJaoFBdq7semnp7/tL
         o5pZjkWbwI3FlQfYynyL3FzcaGq0cqZdEdW9Z1N5BIIO3k7hdj9m8IB17j/MXoxIYZ1u
         1yikBJYMWwsMZ/rcKnpnIts13ESeTrzTuca/u95zqjZ/U5n1ITERv3rrN2R4mlxVvlNf
         l03w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id gr21si721835ejb.81.2019.03.22.08.52.38
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 08:52:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D22BEA78;
	Fri, 22 Mar 2019 08:52:37 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 211443F59C;
	Fri, 22 Mar 2019 08:52:29 -0700 (PDT)
Date: Fri, 22 Mar 2019 15:52:27 +0000
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
Subject: Re: [PATCH v13 13/20] bpf, arm64: untag user pointers in
 stack_map_get_build_id_offset
Message-ID: <20190322155227.GS13384@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <09d6b8e5c8275de85c7aba716578fbcb3cbce924.1553093421.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <09d6b8e5c8275de85c7aba716578fbcb3cbce924.1553093421.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:51:27PM +0100, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> stack_map_get_build_id_offset() uses provided user pointers for vma
> lookups, which can only by done with untagged pointers.
> 
> Untag user pointers in this function for doing the lookup and
> calculating the offset, but save as is in the bpf_stack_build_id
> struct.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  kernel/bpf/stackmap.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
> index 950ab2f28922..bb89341d3faf 100644
> --- a/kernel/bpf/stackmap.c
> +++ b/kernel/bpf/stackmap.c
> @@ -320,7 +320,9 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
>  	}
>  
>  	for (i = 0; i < trace_nr; i++) {
> -		vma = find_vma(current->mm, ips[i]);
> +		u64 untagged_ip = untagged_addr(ips[i]);
> +
> +		vma = find_vma(current->mm, untagged_ip);
>  		if (!vma || stack_map_get_build_id(vma, id_offs[i].build_id)) {
>  			/* per entry fall back to ips */
>  			id_offs[i].status = BPF_STACK_BUILD_ID_IP;
> @@ -328,7 +330,7 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
>  			memset(id_offs[i].build_id, 0, BPF_BUILD_ID_SIZE);
>  			continue;
>  		}
> -		id_offs[i].offset = (vma->vm_pgoff << PAGE_SHIFT) + ips[i]
> +		id_offs[i].offset = (vma->vm_pgoff << PAGE_SHIFT) + untagged_ip
>  			- vma->vm_start;
>  		id_offs[i].status = BPF_STACK_BUILD_ID_VALID;
>  	}

Can the ips[*] here ever be tagged?

-- 
Catalin

