Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B39BC04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:46:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBE672168B
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:46:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mImlR6Is"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBE672168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 580B96B027D; Mon, 13 May 2019 11:46:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 532926B027E; Mon, 13 May 2019 11:46:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4210A6B027F; Mon, 13 May 2019 11:46:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7546B027D
	for <linux-mm@kvack.org>; Mon, 13 May 2019 11:46:37 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i123so9840306pfb.19
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:46:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CX+WwNrHxbi6+vKJH849ujFTw6wRLqJatbYNgyEeksI=;
        b=L9uktc4FAi0DyVeETt2YtxvkU4Ya2zMt0TaVim1Y1ci8GY4QBw1DplCgvCKd6vWTIH
         +VcVi2vgn9FpneXfUgEORoP1gsCHUEm/gksY8BKGW73SDwZ6O5e4tCklhbtsQvcTBgVt
         aLkhAlTBqBOmp3qqHGETwXe+eJBmMG3LqAEiqjkJgjqh3nsIR0p+S5tD2vjyDntcd6WY
         KtCE/vSyzehIoGlPzX57izHEw3AxaCWRWz9L156asliR24taKwOLBwPUcLUPyD/Np+Uf
         V9cGe8b61lK/UM3ad77v4GpmeaxFdXMfViR0NJ4GyD4podWohc73qliIAJSPa9qfG1pz
         A2Sg==
X-Gm-Message-State: APjAAAXDbF0a2AY80ri7yysFV2/pXIox38ARpEu4nrJFqN+fbm8Xjhf3
	Gak46IvkI1q4ZobCCxCA0yC7a02mndx7TRl9FsLmJT0wD/oBWjHZYAIiKfnsglVphEbcUY9Bv0m
	5iXf3uA+c85x6tug+EEv371j/rKzbv9CQRs4XNLS/0WE9qpqDjegsE1YNja+H4XC6iQ==
X-Received: by 2002:a63:ef53:: with SMTP id c19mr32990059pgk.120.1557762396664;
        Mon, 13 May 2019 08:46:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkgDzRumeKEyDV+NIe+F8FwDj5e7zTeD5vZnDg/sTFEcaXvA/rPe8JywABGiifEAfJF2bq
X-Received: by 2002:a63:ef53:: with SMTP id c19mr32989985pgk.120.1557762396048;
        Mon, 13 May 2019 08:46:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557762396; cv=none;
        d=google.com; s=arc-20160816;
        b=jBzVLIBnYmADqJMPqjB/ocp6tsHD73/M0LyOeFwPBlYp7Nxeo8bdXJ8w5XONbVamJF
         X2rBbC9napOTtcV8oXh5re7URrrmW20jCh5fNxHPQLhrziZ37ifSnzdlBB5XN8GShYWi
         flSLucYJQSsypj59E+GWR0Yml4vy9/S/YqDtn+tZxXMcNpqMYS+8SRNVe5iL5POZwnrc
         SfStawyYRqG8kXtMLq6r/a2KRuioWGsqKc0XCAF9dUBnwUkQaRMFmc25Y9WC7e/mnGpk
         8ce4QOvZufy1HkBWlRDKZ3U8HTiYzsmm4mxU8oRNxTUqk8ptTi2W+7w5h+4pOdq50o4G
         5ilg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CX+WwNrHxbi6+vKJH849ujFTw6wRLqJatbYNgyEeksI=;
        b=DD2nlDBpJ5P55wmh8wmqwcjyeA+xFUgkI+WewpmlfYIWj/fhZ3HL7RzWIb3yhQ5ii4
         /sXqEJoAnC+KQx9kTEalIzUgc8d4w9kgpO+91sJvF3t1a3oSjp2Xgg/zF29pVsxzTDe4
         qytS8uRshXjxVy6BqB63m37co9tIfqPtTMGqATy10vqAKMyFX1GqjXRZ+T+g98nd/M44
         ATjsr0E7A68gbllrnVAMaS71qU9KHa+9aG7fdSZB5Y5/fpFKnOCJm0ZHjSkNv/RpcwxT
         Cw4fJ9SgFdVf4HQSFJd/vw+EnvbJzZ1yyytMmIn4CqFgt7L1+itRe0lqyrKALvRdCt59
         WHYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mImlR6Is;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r127si18525303pfr.78.2019.05.13.08.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 08:46:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mImlR6Is;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f50.google.com (mail-wm1-f50.google.com [209.85.128.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 76D8721473
	for <linux-mm@kvack.org>; Mon, 13 May 2019 15:46:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557762395;
	bh=OcS05eqt08syOJc9XJ+Dq4To3jKF7QcT29fpWx88obU=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=mImlR6Is3TMf8fni+IDHdVAZsE7/1M0GTnfOaMuLRGfn1j1/BDu3RGxid6M+0vEiu
	 TFTwQ6jlT+YHrBRxipQ8awjHA/fJy38yEvFDnls8nlN4k82xHuQ7q8V28aXBH0UBQe
	 sppUfQgNAihbuliOSVH+T+E061V8MR3QzVezRa2w=
Received: by mail-wm1-f50.google.com with SMTP id j187so14224316wmj.1
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:46:35 -0700 (PDT)
X-Received: by 2002:a1c:eb18:: with SMTP id j24mr16973110wmh.32.1557762394127;
 Mon, 13 May 2019 08:46:34 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com> <1557758315-12667-3-git-send-email-alexandre.chartre@oracle.com>
In-Reply-To: <1557758315-12667-3-git-send-email-alexandre.chartre@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 08:46:22 -0700
X-Gmail-Original-Message-ID: <CALCETrUjLRgKH3XbZ+=pLCzPiFOV7DAvAYUvNLA7SMNkaNLEqQ@mail.gmail.com>
Message-ID: <CALCETrUjLRgKH3XbZ+=pLCzPiFOV7DAvAYUvNLA7SMNkaNLEqQ@mail.gmail.com>
Subject: Re: [RFC KVM 02/27] KVM: x86: Introduce address_space_isolation
 module parameter
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Andrew Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, kvm list <kvm@vger.kernel.org>, 
	X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Liran Alon <liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
<alexandre.chartre@oracle.com> wrote:
>
> From: Liran Alon <liran.alon@oracle.com>
>
> Add the address_space_isolation parameter to the kvm module.
>
> When set to true, KVM #VMExit handlers run in isolated address space
> which maps only KVM required code and per-VM information instead of
> entire kernel address space.

Does the *entry* also get isolated?  If not, it seems less useful for
side-channel mitigation.

