Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80F6EC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:04:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D14D2083E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:04:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="HyhogeWZ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="xjTLQQUD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D14D2083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81B016B027A; Mon,  8 Apr 2019 01:04:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C99F6B027C; Mon,  8 Apr 2019 01:04:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 692476B027D; Mon,  8 Apr 2019 01:04:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 476C96B027A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 01:04:26 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 54so11699694qtn.15
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 22:04:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hE/ilqrmaBWBrc9SZREc/D/cYwcvR1SyLzOeCz+R+CA=;
        b=te8CtGloOoLMooJTxjMIALpal2QKuZNZnbx7C/+aa29GGW7PqRj3nxj433EnZ5VeLV
         hJrSGXFt3q4XFn4tloE24MJ8kvk3Xs26bJUO37uLcriWDPiWXZpbKpLmpw0wL+64VOHK
         KzFfjWqUj0jmdTBqSuMBef8dGLPhcy6xF1VFFD69liHgaaTLfXVUlYU+3E9yOiRfp6ys
         Hr4JsmxuqtCqTfSPYdBB+AFKnpsoNl4IDW48DAnaUx0lktWeUaoklWyYgfeg1OtKMiWG
         xIvjClV9cF9I3OWEhEMg78wpLOg2CmsEZsn9utQ/VFqPVvubGN7Rv5CWnpef52Qhl5Pb
         1wWw==
X-Gm-Message-State: APjAAAWrBuRe01YQFYrw3K62z4AOE5145zPIzCsFVEXRq5hmgifLWMxV
	De01cZp0fmYn6d/MM8rPhI/nBtyXntYIM1KLbNE4U/QsF0gC752FSK6XtsWEowZnocxrqvor9mE
	2AIHPmIi1roC5znTEQqGYjuhJpcNV4EPHFQQRR0Uh8o9voKEOiqTyHhN2Zl7yYyevzA==
X-Received: by 2002:ac8:3812:: with SMTP id q18mr22001915qtb.17.1554699865978;
        Sun, 07 Apr 2019 22:04:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNh1M46z8O6fu4Ahgj6nGfOOs1U+XUx2/YAWfp3ZzldyVFheE+E16PU4XZ26XPODepN8lZ
X-Received: by 2002:ac8:3812:: with SMTP id q18mr22001887qtb.17.1554699865303;
        Sun, 07 Apr 2019 22:04:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554699865; cv=none;
        d=google.com; s=arc-20160816;
        b=UAi9mV9mi64+NXFd5lGHz643ZtcgkKOq0/C46UkkxTJKWWdvgG6J+Uhr+FHIUOaruz
         OPiAyPqiUtQR8BAyC6KluIogHwsWx0gswu+hFwChZ12+nBldMPlWCo0QClu7xGK+sPVM
         JJE4AiT/jRbpxxKYFZzgV/RtqQvaYDMMxPlnJ8qAgsjMt1IdqJM3IK8CVTDBMDSdft6B
         H+BBhaLrq7Ab7UHXTxAmLcFgvT1ElmhUkN7676SSdmHujlqkUnIIIDGccxoNqQSb2mYU
         Or4Pm6HAKxppAlEuOyL/zCsyqpyMKfGVZ7pBdmoJdNPGM8/I3AloH6xKgqpFP3g7C0fR
         fMLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=hE/ilqrmaBWBrc9SZREc/D/cYwcvR1SyLzOeCz+R+CA=;
        b=qYGFJZd52OfZg/zdBPB+t9Xm4CUTUZWvIvscyHIvEOBj2yOv8TZGqOSbUXas6JSmxy
         D9dkK/DFp5eMEaFSgs3vbehnnekTdGdaPoZNuG3rp84moXyOq/UZIHQLjcScR23MT2Bp
         ejTn7gJ67cRV+mYZAcYESOMV20xcacZ5c8n9UgFl2Q9Cyw93tgRJ/gs/nowKFYBAfKJA
         NyHZp0qq5x8CvCgwoK8OMeCMF28LaU6E8a9n8tf6EHSlurAqWfOhcBg/39VJROo8BjJw
         Z5oZyv5Obf15/ZtY7iM8TowOFjUUuC806MCI+fHBlhIhVLPn0TUyFS2wyGxjCz+PS199
         z3zw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=HyhogeWZ;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=xjTLQQUD;
       spf=neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id h50si231827qvd.87.2019.04.07.22.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 22:04:25 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=HyhogeWZ;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=xjTLQQUD;
       spf=neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 8414D21BF4;
	Mon,  8 Apr 2019 01:04:24 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Mon, 08 Apr 2019 01:04:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=hE/ilqrmaBWBrc9SZREc/D/cYwc
	vR1SyLzOeCz+R+CA=; b=HyhogeWZnD8yWEIQknvyT1SZOB03vFgHKf0YM4TEvKB
	ow4G6H2/eZ7U3U3FNtqrcxUlaRhND4Ww/6yWCXXOX5Gts49b+TL4c+jSvT8c5JM8
	e7jUZaZkCiRHQgqf/Fo+NC2VlK0lpPw87Zfa6UicQ/ztfazPe9BO5lAb5ePZ5lZL
	B2eFZEsfHaJ2NeCE6BrTfhc8HjbGadVAr3ckqvXK6mlx05mMNRwaiMrkxemc+fsn
	Mt+bTsM6Yf0ArfrIoXFypKmUw7JWwNp99xs8LPeoalfYJQUetTifBgyhTzbMdKSs
	gxgaTiwJr+FDLjr8Ij+ZqbEmwIwtyJCJI9VMEKph8Qw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=hE/ilq
	rmaBWBrc9SZREc/D/cYwcvR1SyLzOeCz+R+CA=; b=xjTLQQUDJ69DcUCKDOYLB/
	ZNqQToz4JG5wXILgejFTmOnPuGr6O6x9kweZxzao2qr8eZGlO4N4NOKyGyqW+J/s
	DqE+Kg0Nw8QpUN0IbRb3wINS1LbxtPK695ulSW7yRtZp3ljT3CeSxkdvvIpAAbW6
	m0gQVXk+D7xpRw8AFWO2gcQuWxJ76xxSXDOnL3gke2eJPoLOG+FBLHG2AQUc7heZ
	bzhtMw7/gBBtiHpr7ug11ZQwGBIu9Ej6OhW0AuH2XO72KAcbo/UOXKv2uCUOBC16
	LgqGnZL3PWsjCKXaDFaeTb5Rp/ybgOIXt/oa+31Od7TM6nkXcpKF0J+gMoJZFlAA
	==
X-ME-Sender: <xms:VtaqXHQrl2Rnm3zZ9_DnRhtf5LNc7F4A2po8z70IBvEpc84NSOtUiw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddvgdelvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecufghrlhcuvffnffculddvtddmnecujfgurhepfffhvf
    fukfhfgggtuggjofgfsehttdertdforedvnecuhfhrohhmpedfvfhosghinhcuvedrucfj
    rghrughinhhgfdcuoehmvgesthhosghinhdrtggtqeenucfkphepuddvgedrudeiledrud
    ehvddrvddvleenucfrrghrrghmpehmrghilhhfrhhomhepmhgvsehtohgsihhnrdgttgen
    ucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:VtaqXFM55y-Lsvx9BfNr-Jd_qUDbfDVeqsbqBQutxhqk5m8vt3nfQA>
    <xmx:VtaqXEFFVgAswZvjh2f7zizTGf0Fmijw_DixNW3IknTr3QYTvL0_JQ>
    <xmx:VtaqXNj-NJrq2bOcUmicHU0C3RK17vHZS3kvisD6cQqpuCPudp9rsw>
    <xmx:WNaqXOxY7Aimmz5vAghteFC5XVtiYBCokC2ennYuK6mvdCNcHove3g>
Received: from localhost (124-169-152-229.dyn.iinet.net.au [124.169.152.229])
	by mail.messagingengine.com (Postfix) with ESMTPA id AED3CE460B;
	Mon,  8 Apr 2019 01:04:21 -0400 (EDT)
Date: Mon, 8 Apr 2019 15:03:52 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com, tj@kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] slab: fix a crash by reading /proc/slab_allocators
Message-ID: <20190408050352.GA8889@eros.localdomain>
References: <20190406225901.35465-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190406225901.35465-1-cai@lca.pw>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 06, 2019 at 06:59:01PM -0400, Qian Cai wrote:
> The commit 510ded33e075 ("slab: implement slab_root_caches list")
> changes the name of the list node within "struct kmem_cache" from
> "list" to "root_caches_node", but leaks_show() still use the "list"
> which causes a crash when reading /proc/slab_allocators.
> 
> BUG: unable to handle kernel NULL pointer dereference at
> 00000000000000aa
> PGD 0 P4D 0
> Oops: 0000 [#1] SMP DEBUG_PAGEALLOC PTI
> CPU: 3 PID: 5925 Comm: ldd Not tainted 5.1.0-rc3-mm1+ #6
> RIP: 0010:__lock_acquire.isra.14+0x4b4/0xa50
> Call Trace:
>  <IRQ>
>  lock_acquire+0xa3/0x180
>  _raw_spin_lock+0x2f/0x40
>  do_drain+0x61/0xc0
>  flush_smp_call_function_queue+0x3a/0x110
>  generic_smp_call_function_single_interrupt+0x13/0x2b
>  smp_call_function_interrupt+0x66/0x1a0
>  call_function_interrupt+0xf/0x20
>  </IRQ>
> RIP: 0010:__tlb_remove_page_size+0x8c/0xe0
>  zap_pte_range+0x39f/0xc80
>  unmap_page_range+0x38a/0x550
>  unmap_single_vma+0x7d/0xe0
>  unmap_vmas+0xae/0xd0
>  exit_mmap+0xae/0x190
>  mmput+0x7a/0x150
>  do_exit+0x2d9/0xd40
>  do_group_exit+0x41/0xd0
>  __x64_sys_exit_group+0x18/0x20
>  do_syscall_64+0x68/0x381
>  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> 
> Fixes: 510ded33e075 ("slab: implement slab_root_caches list")
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/slab.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 46a6e084222b..9142ee992493 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4307,7 +4307,8 @@ static void show_symbol(struct seq_file *m, unsigned long address)
>  
>  static int leaks_show(struct seq_file *m, void *p)
>  {
> -	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
> +	struct kmem_cache *cachep = list_entry(p, struct kmem_cache,
> +					       root_caches_node);
>  	struct page *page;
>  	struct kmem_cache_node *n;
>  	const char *name;
> -- 
> 2.17.2 (Apple Git-113)
> 

For what its worth

Reviewed-by: Tobin C. Harding <tobin@kernel.org>

thanks,
Tobin.

