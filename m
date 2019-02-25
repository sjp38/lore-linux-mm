Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0644C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:23:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 884E820842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:23:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 884E820842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FF348E000F; Mon, 25 Feb 2019 10:23:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AEF68E000B; Mon, 25 Feb 2019 10:23:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDEB98E000F; Mon, 25 Feb 2019 10:23:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id BBCCC8E000B
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:23:40 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id c8so6611091ywa.0
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 07:23:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aceOQhsR7Q7buD/56Nry5wu+S4gTAyrPWonUPvKLu3s=;
        b=EYaiviURSayi/hQOJ5jNr1fAnPGcwGfqBCQoacBL3Q1hAR7jSjSYXAayBHuC5Dh7dC
         HlBg+4CMsmc6jy6XDPTlP6h7RcrGjuNg9b4WnZUnmMa9RK9PIppD1qs0DFayI6gK/Nx2
         a5N0YApoxSgbrskpzKSTKbnAjrOEYb3R/j6fNqE1sAI7ArqnVe9XqLVGtH0M5W+iEUhU
         Iq14ifE0ieBfUX++UsjjOaCwX5vQUUYzqdsJhkzbOJB96XNWHY/HVllVDS+L8gbwHRB5
         MTqArMdyHYbeLq00EgbRiAbPWziZL4bIncqAVrdj9AEKWYDPEtt0T3EH6LKTxZOjm8JK
         wcsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZ5R0yHYrg+VWIlT1ID0lQkiBw0ylU2g0c5sBU5kAofcdKMFZ+1
	c52gUzAMFf+DE0IUOOiQ8VJDfCqgframIWhWVYIT+NHf8mk/XjxGbwmUjF5jawBjoS6YLVD5N7f
	oNuElGb463mvqztki17BeDbLVmqPP82kPWYlHhn1Pr0au2mUol5xyqE1dwPntgRFMpXJRfiPnbu
	T/PKHHA0JQntOwrBHqmwx3N6VMDTDsHCfbaIe3GAe/MUGJPjUSiV/7X8Uhsg7ZlIgrnIcOrWOp1
	gY+9tDanupggziPfPNy/e2+JEOrSgPkkPXwv8GlnMdqwOAVLU6y5AZvGmn+J4tzP/Y7aaX/PJ0M
	Oi7gUHK/MjlWOUkeE2ni15QiFbRup4hCnUITA44sRbZeEOW+yKQ8PbDuqbgGG9eAHiP5XZqRXQ=
	=
X-Received: by 2002:a81:4b0d:: with SMTP id y13mr14015626ywa.47.1551108220493;
        Mon, 25 Feb 2019 07:23:40 -0800 (PST)
X-Received: by 2002:a81:4b0d:: with SMTP id y13mr14015568ywa.47.1551108219584;
        Mon, 25 Feb 2019 07:23:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551108219; cv=none;
        d=google.com; s=arc-20160816;
        b=ZMi/RB3ocHnVLWkDgnGlRqhnYngHlsBJUJZBSbIaxNPGxKvZ1Et7ebUsdW9XLJ85BY
         WxPPb9blolwhsTGZc7H/9nnnryLygysygbjvzXlbNI2GJcq/PO+ZDQjOBW/XxPqrCL+e
         Lpl8UVMagyhzAknuNzA22mFkNHDrcyj9KQFDw/ubNaEARhgPduEJlbXxUBrReo6impUU
         d5MlyKOrD9MRPC/yKax0HdnVc7KuaTH2c3wNAXzHQdLuqJomGj6W+PCgjPPvZw7N4sXk
         J5Dpcag/y13tfYetH78334Q0dak56vdhsScUdq7z6dpd6wYf8uj+XQ9neuX1QtyyCabX
         ZRoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aceOQhsR7Q7buD/56Nry5wu+S4gTAyrPWonUPvKLu3s=;
        b=wqdwXwA3haQgx8Ehqw4o3rfvYGzNyd6GQycTXSA+van9EqIysU+ULPqRD66neqnMUS
         SIHV0UZIj0agGRYVP2ozoVkqGRDP9y9G0JyBJsl4LdtWUWa46BPz7O7ThWrvpSr9BGTh
         PRB1zhQ7KAvH3nEGv2g/AxgtzJT6b9j792P7s+W+X7NjPBnU2SILw+CWgZelF3jV4F+a
         5MFM58jKPPySdX6UvwoOQ3nfQ81YAb+lMmLN6KJzwDF/o/OhXRf4F8xAjWgDot7lSmGO
         fCRhZeV3DFj9RLchiw3pvyqY4O5cd3nILEN+WBai5sRz/mNPqvO0zFSPzx51G6RlY/dx
         5LiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 205sor1830727ywy.218.2019.02.25.07.23.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 07:23:39 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3Ib6GTB+XQ49xYR/2VSEmHU0P9cRyTShmN0tAnKdZHjxiFb314bAixYFQzQ1pQStm7Gpg+Z6LA==
X-Received: by 2002:a81:2fc1:: with SMTP id v184mr14231584ywv.129.1551108219233;
        Mon, 25 Feb 2019 07:23:39 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::1:8bb9])
        by smtp.gmail.com with ESMTPSA id v6sm3665012ywc.107.2019.02.25.07.23.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 07:23:38 -0800 (PST)
Date: Mon, 25 Feb 2019 10:23:36 -0500
From: "dennis@kernel.org" <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: "tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [RFC] percpu: decrease pcpu_nr_slots by 1
Message-ID: <20190225152336.GC49611@dennisz-mbp.dhcp.thefacebook.com>
References: <20190224092838.3417-1-peng.fan@nxp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190224092838.3417-1-peng.fan@nxp.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 24, 2019 at 09:17:08AM +0000, Peng Fan wrote:
> Entry pcpu_slot[pcpu_nr_slots - 2] is wasted with current code logic.
> pcpu_nr_slots is calculated with `__pcpu_size_to_slot(size) + 2`.
> Take pcpu_unit_size as 1024 for example, __pcpu_size_to_slot will
> return max(11 - PCPU_SLOT_BASE_SHIFT + 2, 1), it is 8, so the
> pcpu_nr_slots will be 10.
> 
> The chunk with free_bytes 1024 will be linked into pcpu_slot[9].
> However free_bytes in range [512,1024) will be linked into
> pcpu_slot[7], because `fls(512) - PCPU_SLOT_BASE_SHIFT + 2` is 7.
> So pcpu_slot[8] is has no chance to be used.
> 
> According comments of PCPU_SLOT_BASE_SHIFT, 1~31 bytes share the same slot
> and PCPU_SLOT_BASE_SHIFT is defined as 5. But actually 1~15 share the
> same slot 1 if we not take PCPU_MIN_ALLOC_SIZE into consideration, 16~31
> share slot 2. Calculation as below:
> highbit = fls(16) -> highbit = 5
> max(5 - PCPU_SLOT_BASE_SHIFT + 2, 1) equals 2, not 1.
> 
> This patch by decreasing pcpu_nr_slots to avoid waste one slot and
> let [PCPU_MIN_ALLOC_SIZE, 31) really share the same slot.
> 
> Signed-off-by: Peng Fan <peng.fan@nxp.com>
> ---
> 
> V1:
>  Not very sure about whether it is intended to leave the slot there.
> 
>  mm/percpu.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 8d9933db6162..12a9ba38f0b5 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -219,7 +219,7 @@ static bool pcpu_addr_in_chunk(struct pcpu_chunk *chunk, void *addr)
>  static int __pcpu_size_to_slot(int size)
>  {
>  	int highbit = fls(size);	/* size is in bytes */
> -	return max(highbit - PCPU_SLOT_BASE_SHIFT + 2, 1);
> +	return max(highbit - PCPU_SLOT_BASE_SHIFT + 1, 1);
>  }

Honestly, it may be better to just have [1-16) [16-31) be separate. I'm
working on a change to this area, so I may change what's going on here.

>  
>  static int pcpu_size_to_slot(int size)
> @@ -2145,7 +2145,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
>  	 * Allocate chunk slots.  The additional last slot is for
>  	 * empty chunks.
>  	 */
> -	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
> +	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 1;
>  	pcpu_slot = memblock_alloc(pcpu_nr_slots * sizeof(pcpu_slot[0]),
>  				   SMP_CACHE_BYTES);
>  	for (i = 0; i < pcpu_nr_slots; i++)
> -- 
> 2.16.4
> 

This is a tricky change. The nice thing about keeping the additional
slot around is that it ensures a distinction between a completely empty
chunk and a nearly empty chunk. It happens to be that the logic creates
power of 2 chunks which ends up being an additional slot anyway. So,
given that this logic is tricky and architecture dependent, I don't feel
comfortable making this change as the risk greatly outweighs the
benefit.

Thanks,
Dennis

