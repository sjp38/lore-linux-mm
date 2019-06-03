Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F04BC28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:38:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 249ED24075
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:38:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 249ED24075
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7B806B0275; Mon,  3 Jun 2019 13:38:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2BB46B0276; Mon,  3 Jun 2019 13:38:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F3B76B0278; Mon,  3 Jun 2019 13:38:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FECE6B0275
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:38:48 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b33so8438669edc.17
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:38:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=u8SsYFeE3hKeoKJSi9KrLYWzElpn5LoQahXQCpaXe/Q=;
        b=ZytWDx1SIv2DgQcPbP/TE/gU2tpY0CqMww+Ma50YenkF5rrjDm2W4HP/6aMnG0i0pZ
         vjL+Kj8TdOdmLlInVVVCUK8RlBWS/Wfd/vMVa8QGagjOO+wTAFlr/E7RJe1FYYC9sG9y
         5YPfi4MlHwXfqFqM9/ndO+TtKEwcRBXSPrVzVExgfDiFnxp19pbM9jI0PEvlVG9aalIp
         oZlwPiPGs9lvnLBPOyqGMwL8RRa7bnquo8etIAEwxuBGHvB7F39T26szjrri5ufSiNjp
         HwrIw78REp/KiePa+c8iRJIv9/wZvgjktXVEJAxHjzPqbLZmxSG6fFW9LV4h2beLeDnn
         M9qQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWXdjcJ+uZnlx1w9SKh72pAOIh9c6mJHq251ol8sc7/zM3NEZwl
	jrqJbBeE70q8ouZyUEdFRqlAURnQLRk0VVu5s5VGL1CW84LJwMOmAE8OC7vfVoOH5KxpckU/kCf
	7APXfAziMrtLfI6QHtMnoZ/CfINf02Cvs3HOxy5VcYL0ZkeNaax5K0YfsDDmxRfgSsQ==
X-Received: by 2002:a50:aef6:: with SMTP id f51mr29694233edd.225.1559583527892;
        Mon, 03 Jun 2019 10:38:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkmBT/6d20bl3KAAdmZ6L5JRQtYvm0ErmEi6jx1iLPOZtYlGwKKxao1Zoisxq5EDp30SW9
X-Received: by 2002:a50:aef6:: with SMTP id f51mr29694164edd.225.1559583527184;
        Mon, 03 Jun 2019 10:38:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559583527; cv=none;
        d=google.com; s=arc-20160816;
        b=b0d1CtQggGw2Tl6+4ltQFfrpPDD4pL11uNNpGe6oGIKArDeX6SRKjXUxVOn6sVjRau
         ueeklsdTafCVv5dtEHWTJ6oKpZ6xNhjI+0PQC/robGClXiZLdq99oQyoVKPjadb3lF62
         zL/WjcxuvRSjioxTVjZl9IvmpcBNJUkqmT+nADTydQFes85lNd/in/zKzCCSJ7+jlWI4
         kALGFBEkibOR5uv59Ok7t2hUoPFIl8e9+XrAfXkWbFMXn5jhaPskRuIW99a+ONo/zCi/
         6IrzKaD+B6fL3xZToBqFIN6EUL2FhSsom18U0Uyqjm5AEQ6PGJJPVPwYd4Y7H8J/lhEr
         EeYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=u8SsYFeE3hKeoKJSi9KrLYWzElpn5LoQahXQCpaXe/Q=;
        b=D3Fq8bSUZGm5BJq0IAxKCLkMK0elyEIQ+W8NDuHLTsjxcmOmMeC+2R5AtsWkKYJN60
         YU/xM2WrEmDEoS3awpKLGm93wXhuKj7ioPaXcCnY/itjn7HuyJWrFc0BNfKxl4DkRsgF
         VafwnzBEbw0lZw5m4k/HT+4y/Gb+ip0+QV+cUigTCt8zWFL2aFvxkpZjvQ8U2TpeM6sL
         XH3GxAlC6hs4jNSwHo3jQOywYKzo5Gb0vZxDdkoZbWcChclz2gCefF5RK+Se1DUh2H6E
         h3PmW5eEHNZ6q53+kLH1AG/pQa4RhFVC0AJWAVVZK3Gal9T+a1nlVIf0LtS6hswnoQmo
         gVzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p38si6023460edc.348.2019.06.03.10.38.46
        for <linux-mm@kvack.org>;
        Mon, 03 Jun 2019 10:38:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 49D1780D;
	Mon,  3 Jun 2019 10:38:45 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0FB323F5AF;
	Mon,  3 Jun 2019 10:38:41 -0700 (PDT)
Date: Mon, 3 Jun 2019 18:38:39 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 04/14] arm64, mm: Move generic mmap layout functions
 to mm
Message-ID: <20190603173839.GK63283@arrakis.emea.arm.com>
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-5-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526134746.9315-5-alex@ghiti.fr>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 09:47:36AM -0400, Alexandre Ghiti wrote:
> arm64 handles top-down mmap layout in a way that can be easily reused
> by other architectures, so make it available in mm.
> It then introduces a new config ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
> that can be set by other architectures to benefit from those functions.
> Note that this new config depends on MMU being enabled, if selected
> without MMU support, a warning will be thrown.
> 
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

