Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99DF3C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:24:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E01420673
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:24:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="V0EcI0Rt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E01420673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 134D96B027D; Mon, 27 May 2019 08:24:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E5456B027F; Mon, 27 May 2019 08:24:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA1286B0280; Mon, 27 May 2019 08:24:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 993006B027D
	for <linux-mm@kvack.org>; Mon, 27 May 2019 08:24:32 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id g1so8138277wrw.20
        for <linux-mm@kvack.org>; Mon, 27 May 2019 05:24:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XYW6Bv1LchMVefhh2WDoaK3VxoyotGe8j5acHUJ6YR8=;
        b=lP59vPKxafL/UuRj+VPk7Gyllm1qTNxNPLixDOyjgH/Jv1XRI517ldfmJyEn8ACdLC
         Mk1Kl/UX/DoctzyRh732/tTFDy6Z076fa2TJU5fTc3VwwxKatjnW10FVSVBd69qrxstS
         hBF6Z/YV551ZjMz1JQYgc2USeXeRozLkHSvry59gC7p2ZATvwtTu0lLNIucaU436AQfj
         Y1qGoyhCg9YIMxaNNfqa3FZOdt8FSJ8Y0J1+9UkL2uCIOOwBecgHeBtb9HhDJgAwViHL
         0wNm4XLuBLf8bhtaSS/+Wk5nINZ3zj8AtJ1M4Od+K1YCGSpH78uwsnpr1Y4VxNd143Nk
         QjSQ==
X-Gm-Message-State: APjAAAXUOTqLk4YnW9VrlGpqPkSlkY3DhZNu2YvjtDR3JUcX34ItKFJV
	p337j6OXwVrD7GNOM1SAfphFu5Fa0PZLT4PhVepwU96WIx/WNo/npgb5Bsgm3wFxpvgJ9MYGysH
	Jm97dS9ba3p+1nL7kydAV9Jk7WYLEdyI67GGwPdv0Ry0rFaLMfQB3YoTiGjK+Nb1KCA==
X-Received: by 2002:a5d:484f:: with SMTP id n15mr56695781wrs.314.1558959872070;
        Mon, 27 May 2019 05:24:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPlcrBoIEr9bRIph6ULRnyT4/nOrfX6ZwiQuH3bPx74LJ/nbvP11DQzaU2Vz6n6ZXHXRuS
X-Received: by 2002:a5d:484f:: with SMTP id n15mr56695753wrs.314.1558959871395;
        Mon, 27 May 2019 05:24:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558959871; cv=none;
        d=google.com; s=arc-20160816;
        b=hFs2zJx6+Fic7DJhBFpG/8EPfnu/LEfPZd3cSEVTh16hdueh0DvaxRDK2WYQv8lfuK
         ZfRTBd8wjXqkRlEQcknGKdDVT0qfK+Or4l/xJ/mkCBurV7RVu4qLAM82SgKi56stDAyT
         b6vF48CrWy62NDH1yDXqZiWhyLv29C0k+/znj2GOH0CIBLMHyKdYmpAeeGlADkpNFzRw
         krdzcXKpSyvilffT84qwGYDVJiKe+5G70YcHebHUxBpGnrU3ywNpX9w3A/hG3rkvfKs3
         tetKoY7WApQ7zltsBWwEjmYYZb0EvQoBBLL/WIueksQdvIMjfUu4cAoJekrbAfPNxRnz
         HKmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XYW6Bv1LchMVefhh2WDoaK3VxoyotGe8j5acHUJ6YR8=;
        b=DEGNCFvmf0ZsOlpWV0WOpH6+sa1PXouGaqA6NNACIRKDTzG76JQWyjMbtE67OcXOMA
         /XqmJ8kPYZD+vTGmhyRHgO77SKNQP9hM3HaasSGGfo+PWdXnr0+rZzKQk/xmEH46Awup
         j1w1gF6nj8ehSz+AyIpq7fpJJuLc1dmFuvQrt9MUctMJaHPnAM+kGSghQIur3xgq8Y31
         GsxB4UufroF7bjp9A4qShKzAr9KN5pZkag5nQzRTcDasmJQ4/C/JIq6JvZEseFDnd8+P
         J1PN5hG/SquzH6qlG3W91NIw1UnjZ07mDm7lH0vLbA1hT5Lkfnk0NEuVQLOdKjIoXhoQ
         0jxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=V0EcI0Rt;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id x15si6451941wrw.160.2019.05.27.05.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 May 2019 05:24:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=V0EcI0Rt;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=XYW6Bv1LchMVefhh2WDoaK3VxoyotGe8j5acHUJ6YR8=; b=V0EcI0RtOJJpB+YbYiMjW84SJ
	RaFIbLmIDNiEbmjmJ8DGCudJ/OzXkWaMgB0SjYCi3/DWNR2QKQXFekISwvHnRrlv5ysM4blDvEEmG
	G5aRvcIjzAgTxPtDCbcwcocVNHxH27LL5nKZXJivG+pmRc9tyjJwXcDD/Pcc5UsVHfX7AQCbzyOpL
	InUesZfcRGLTQYJNF4Z9nSHl2jVqcuKpE/0rdDCn8MTWBltA9on+6DqS1/CsIT9wi1+KgL5KqnfGD
	SEvP3cAO6zqGahEQ4X2aX/xTt3wDDdmYzmyxKfpTmfIE2ygIJ/f4lSZeEBBY3IrczBWHIHgKBbAGj
	JcOcmE+qw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hVEfy-00039G-Jg; Mon, 27 May 2019 12:24:26 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 368AA20254842; Mon, 27 May 2019 14:24:25 +0200 (CEST)
Date: Mon, 27 May 2019 14:24:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org, luto@kernel.org,
	dave.hansen@intel.com, namit@vmware.com,
	Meelis Roos <mroos@linux.ee>,
	"David S. Miller" <davem@davemloft.net>,
	Borislav Petkov <bp@alien8.de>, Ingo Molnar <mingo@redhat.com>
Subject: Re: [PATCH v4 2/2] vmalloc: Avoid rare case of flushing tlb with
 weird arguements
Message-ID: <20190527122425.GQ2606@hirez.programming.kicks-ass.net>
References: <20190521205137.22029-1-rick.p.edgecombe@intel.com>
 <20190521205137.22029-3-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521205137.22029-3-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:51:37PM -0700, Rick Edgecombe wrote:
> In a rare case, flush_tlb_kernel_range() could be called with a start
> higher than the end. Most architectures should be fine with with this, but
> some may not like it, so avoid doing this.
> 
> In vm_remove_mappings(), in case page_address() returns 0 for all pages,
> _vm_unmap_aliases() will be called with start = ULONG_MAX, end = 0 and
> flush = 1.
> 
> If at the same time, the vmalloc purge operation is triggered by something
> else while the current operation is between remove_vm_area() and
> _vm_unmap_aliases(), then the vm mapping just removed will be already
> purged. In this case the call of vm_unmap_aliases() may not find any other
> mappings to flush and so end up flushing start = ULONG_MAX, end = 0. So
> only set flush = true if we find something in the direct mapping that we
> need to flush, and this way this can't happen.
> 
> Fixes: 868b104d7379 ("mm/vmalloc: Add flag for freeing of special permsissions")
> Cc: Meelis Roos <mroos@linux.ee>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  mm/vmalloc.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 836888ae01f6..537d1134b40e 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2125,6 +2125,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
>  	unsigned long addr = (unsigned long)area->addr;
>  	unsigned long start = ULONG_MAX, end = 0;
>  	int flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
> +	int flush_dmap = 0;
>  	int i;
>  
>  	/*
> @@ -2163,6 +2164,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
>  		if (addr) {
>  			start = min(addr, start);
>  			end = max(addr + PAGE_SIZE, end);
> +			flush_dmap = 1;
>  		}
>  	}
>  
> @@ -2172,7 +2174,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
>  	 * reset the direct map permissions to the default.
>  	 */
>  	set_area_direct_map(area, set_direct_map_invalid_noflush);
> -	_vm_unmap_aliases(start, end, 1);
> +	_vm_unmap_aliases(start, end, flush_dmap);
>  	set_area_direct_map(area, set_direct_map_default_noflush);
>  }

Hurmph.. another clue that this range flushing is crap I feel. The phys
addrs of the page array can be scattered all over the place, a range
doesn't properly represent things.

But yes, this seems like a minimal fix in spirit with the existing code.

