Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE314C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 18:09:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88DDC215EA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 18:09:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ge2Xh48K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88DDC215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05DE86B0003; Mon, 29 Apr 2019 14:09:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00DEE6B0005; Mon, 29 Apr 2019 14:09:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E19996B0007; Mon, 29 Apr 2019 14:09:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB6296B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:09:20 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e128so7651510pfc.22
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 11:09:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=u+NYGiwuPC6g5QE3tb8UD5Z4Dmm9mmFpCh2Hh2ryqNY=;
        b=JcXnnGzcs/6sUDO1WqU5HCkiauOp9NDG8mGh7a12ppzA/xyBLOPoCr9cWNtTjoUuRm
         VBHz0JEfOLUEwSFwwDdW1VsVKcRgVTb1gvAY6CCMJzzvc0S/wkQ3Z4/eZWjoyAboxGgA
         1J4AdO31Upk3xtLcT9976i3MkP2IGk6eaZvZbwjhBs86Gl8JPyb5PuIy+z2b1EhNfDW6
         ZQPU/eFeQwGfq/va8vPsgB0NAbnF8arEpgdqAIFdkWC7MopP30edx8793OxRF88wVzAZ
         xuiH33l1cisOGVZsD9xOLUkb5ZBXjONkuNtMFSYCsjKagislR7IeuVpUxaAQhBMCvbBV
         ZuGg==
X-Gm-Message-State: APjAAAXTAUVg4ou/axrQs2FtPIsI2popltgEPPW/c2tK1iyQrzQyjbvx
	MUBsI1Kmbp/PtyIdrBGr9Qjkopg48AOSuYoUm0Fw4lpm/Nr9AoR67sJY5yQUukIwv2d0HXv0Ky9
	fdH6s/hJ5z+T3/woGQ9WDa/XN+5rAPdSwYAf3feiniVbU81Ps90lIFxdB/PfNInAj/w==
X-Received: by 2002:a65:608a:: with SMTP id t10mr3866300pgu.125.1556561360165;
        Mon, 29 Apr 2019 11:09:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNOfHDho8EXXzZJ51K42fMu5mcxHVteFbhmArWRKUTcb3oqsJIqNfbhXe1QoRHtc3LuFvt
X-Received: by 2002:a65:608a:: with SMTP id t10mr3866210pgu.125.1556561359332;
        Mon, 29 Apr 2019 11:09:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556561359; cv=none;
        d=google.com; s=arc-20160816;
        b=cK6sxabojoNFMzQNxWcHbbZi45hY/7fiYuoa4TozQh85MMR/VlTnzeu6LA8jxpULNr
         ScRBWtMhfI9BmyJQfGfwTvyRLso11RjloDlByc+ISCIjqosMrw8RfJIWAG/wyHGumepp
         8RK7A28qO2Ydl4prsgxSlQoJaMEO5t9aXY6pHoazmv/mX3BRtITOVUyR9memlZzAVriV
         1Dm/kJlCrKzUkPM33GYka4lz2B3okOHioVVjGa2roBAPtsR/R4MGBKqLhJWg5mCK7XAH
         OlbZxVQZhz5Q7M+br+Zb/SKqXIzDE9MN7gmPZ35j0RAWKLJtPF8oyGutATNWArClaF9b
         OZeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=u+NYGiwuPC6g5QE3tb8UD5Z4Dmm9mmFpCh2Hh2ryqNY=;
        b=osbX4JYWSa2doHZAE5lfSJleo8Z19c2divj/2Df/roumP7CTYr3+fq4y0i9Nnm4QHR
         D3F+gAAMZwSvWfVLxhMiIMXgU4ouiyliQGCBOKcSIG2Sehpm9tU9D/lVw+c52dR/sNqB
         YmNw+NtyVvcM40Snjmcfq6VFhF2rbE0ZVtCXOlEUDsO8hkuFNiojce+H3Y6AbgplusX7
         cfY1ilty8QKcPhWMjIHWZ1mD+wZZAzBUKyRlwC//zyNlivQFf72lp1az9KyX8yPTIkC3
         SUzEHBYxW2zDu06s5F0A565bypccKW8PnVRASNwH48W9N9DCQnX6OfOBjvXQNouLA8Vf
         xyLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ge2Xh48K;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q3si3720166plb.266.2019.04.29.11.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 11:09:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ge2Xh48K;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [77.138.135.184])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E3D052075E;
	Mon, 29 Apr 2019 18:09:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556561358;
	bh=knicNTsLDrTdl+nHm891iiyJBuFucBVCVsfE5y1OjKA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ge2Xh48Kxd01IgsiBFU25hZghQd5+q+im+ydLjo+mtYyaia6ADTbFZySvV4VePK5z
	 r9VgnUNtmtNLtHScdqenLcHKoRSORje+QwLH/4jbbGGpP42++KPfd7FJiEuipu3BCH
	 v3xZt3Ostbqtxa5SRNMYMZ/s38Q+uTDDuPnoB/D4=
Date: Mon, 29 Apr 2019 21:09:15 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
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
	Christian K??nig <christian.koenig@amd.com>,
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
Subject: Re: [PATCH v13 16/20] IB/mlx4, arm64: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <20190429180915.GZ6705@mtr-leonro.mtl.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <1e2824fd77e8eeb351c6c6246f384d0d89fd2d58.1553093421.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1e2824fd77e8eeb351c6c6246f384d0d89fd2d58.1553093421.git.andreyknvl@google.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:51:30PM +0100, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
>
> mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> only by done with untagged pointers.
>
> Untag user pointers in this function.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
> index 395379a480cb..9a35ed2c6a6f 100644
> --- a/drivers/infiniband/hw/mlx4/mr.c
> +++ b/drivers/infiniband/hw/mlx4/mr.c
> @@ -378,6 +378,7 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
>  	 * again
>  	 */
>  	if (!ib_access_writable(access_flags)) {
> +		unsigned long untagged_start = untagged_addr(start);
>  		struct vm_area_struct *vma;
>
>  		down_read(&current->mm->mmap_sem);
> @@ -386,9 +387,9 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
>  		 * cover the memory, but for now it requires a single vma to
>  		 * entirely cover the MR to support RO mappings.
>  		 */
> -		vma = find_vma(current->mm, start);
> -		if (vma && vma->vm_end >= start + length &&
> -		    vma->vm_start <= start) {
> +		vma = find_vma(current->mm, untagged_start);
> +		if (vma && vma->vm_end >= untagged_start + length &&
> +		    vma->vm_start <= untagged_start) {
>  			if (vma->vm_flags & VM_WRITE)
>  				access_flags |= IB_ACCESS_LOCAL_WRITE;
>  		} else {
> --

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

Interesting, the followup question is why mlx4 is only one driver in IB which
needs such code in umem_mr. I'll take a look on it.

Thanks

