Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A855DC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:35:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B56F208CA
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:35:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fijeBxJq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B56F208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E35696B000A; Fri, 14 Jun 2019 07:35:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE6AB6B000D; Fri, 14 Jun 2019 07:35:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD4E46B000E; Fri, 14 Jun 2019 07:35:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 807E76B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:35:35 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id o127so543605wmo.0
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:35:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WWQ52tqaiCP0C1KYMNijF1HDqWlxTu5XvaRlCuBtZ3g=;
        b=XEW8JqplI7DBezsBB+xJ/iSb8sq9jEnzeDJWmNX1BZk2xDtXkTHFHGPMf/fg9rTK78
         bW85i74RjK/Ghm5oeDMlYtHYBOVaLgRbGNBRIfIcn8inQHAwf7THjSsITXqPagT1KweS
         HmEBhFpi/Uz7b8OX1t6XmPqd1RBTQ3MHQvFV3j7GR19cBz2I8Qu3C+7GVdpXMWEGVKYi
         TPX8iJqlsrqyuQYJy4Sl213xWlPkDvKeglbWLlLfXI2rix1+XEWA49YMPLbVcdft1mul
         WtipdjhqvGKJD7HaX3Ejk4cnKsttjJ3LdAh3a0HEBG5OjKsn+MRnKNGvzFzjNcZo7/m7
         hKSg==
X-Gm-Message-State: APjAAAXxVqGvmn6smMrH9jGUffc8swLNUkghL/xuLMepZA/R7K7Grs3E
	C/uDb04/CEjYMfnYEEW3JyNWVv+GUOK2oDka3jz0Lq6442TKhYoFHH3E4L1VcEj4K9cUFooQblr
	6kGJ5qKvlJWjfV4w2lCQ0Fy3l7fWYi2s5LhHfoe2Gb5l4hZc+xadCsLF94kN6wLjFYQ==
X-Received: by 2002:a5d:6b52:: with SMTP id x18mr40835155wrw.341.1560512134867;
        Fri, 14 Jun 2019 04:35:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNeCHoBQq87mw/Uw48KTfMwD1oG+ehpBc7Vh4NpAgB48VWzXHjb25l9zi+F12KxxNmKqMQ
X-Received: by 2002:a5d:6b52:: with SMTP id x18mr40835115wrw.341.1560512134119;
        Fri, 14 Jun 2019 04:35:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560512134; cv=none;
        d=google.com; s=arc-20160816;
        b=NMYv4DKu8AFL4fAsEUUlbx8cdq74Ioqw4IPR1jUNUJwHZwYOaEtcZRVpbmV9KCETyL
         xrgS3AojZrOAYeq45PRX6dU3G8VBtgOvDusqKDW8J89y7jofUzkJyrQlHSZnunZuCUg+
         Z/hikFhbiyjgc9fTvNd88orMIiQWEbaHwqWzHU4UZtaSZ+gJEpJPZ9axDwW3Htz5bl/Z
         qWtKmvOmcj+QEycLOVl5rhxEQ4TCY1F5BYidp4rI3Y68otRAz+DpgjICgnkqBoULftJp
         mKLjPUNhrKiSGNUupdNsudALJHDl6JRThtM/d2IgRJ2Ie6ffaiehQy5Ji4NjVLl5QY/Y
         Fm5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WWQ52tqaiCP0C1KYMNijF1HDqWlxTu5XvaRlCuBtZ3g=;
        b=a0z7fm6xvboedXaN3OdJ3FU6U9Okf590WYwUUvFeE+ZdmxYkmSo1y6ywl03edDTB5a
         YIBq3b1FVj8E2YI5c8ZJvpgLFYtVLSsNk+IrsqfQEs/+bAqfzeNuY+uk8CR//1gONoXq
         pl9O8gH3oepFJbAVM0WoVMoZgbQ3UZ21YK1AG7uq77ozXwHc+CRCZvu0AGA11QBqimDk
         WLf8F4cVkyNSevUXh+Nbm+VpMqzYVYPICJ3jWjAeNFos73kOszdBmc/DxFi3FWAmQ69V
         s4Xtm+Lz9UPiDwpZzaOA/auwZw0UDdyKsrr8Is2dizGuL1POgyO19oDRFHC8VSa/OjUT
         b+PQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=fijeBxJq;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id y9si2402719wrl.54.2019.06.14.04.35.33
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 04:35:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=fijeBxJq;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=WWQ52tqaiCP0C1KYMNijF1HDqWlxTu5XvaRlCuBtZ3g=; b=fijeBxJqngGRNGgiX1l6dheAA
	g0a+TA0qsbMnKPf3UF9mnTF+NJ8o2HHDxZGyQokqmbnkrBWxh2nwJAMMhedacfoexc3lD+yUgcstb
	b58/Ies68J3GZLFKZdMLki9pYdHx5s9bTGYQntRYkltMpfp80uHWFFwUnBfxeqzhumHdFR1jsim+Q
	Fcvnxn8kZXVv9SmjYvxD82ay1KdB3V7FWOTlZPdCFHVficpEuxVn3l5p4ZgEs+myHgUEcfUwux4Y/
	xrCDihiDGQ2n0gR2hsnJIoV+HwI5A4h+me8DTlf+jEwCC3bHxoTlS1/sjfQOuLkYYJyhSLIyuA12r
	fc9HqHw7w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbkUO-0007E2-VL; Fri, 14 Jun 2019 11:35:25 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 7156220A15636; Fri, 14 Jun 2019 13:35:23 +0200 (CEST)
Date: Fri, 14 Jun 2019 13:35:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 26/62] keys/mktme: Move the MKTME payload into a
 cache aligned structure
Message-ID: <20190614113523.GC3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-27-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-27-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:43:46PM +0300, Kirill A. Shutemov wrote:

> +/* Copy the payload to the HW programming structure and program this KeyID */
> +static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
> +{
> +	struct mktme_key_program *kprog = NULL;
> +	int ret;
> +
> +	kprog = kmem_cache_zalloc(mktme_prog_cache, GFP_ATOMIC);

Why GFP_ATOMIC, afaict neither of the usage is with a spinlock held.

> +	if (!kprog)
> +		return -ENOMEM;
> +
> +	/* Hardware programming requires cached aligned struct */
> +	kprog->keyid = keyid;
> +	kprog->keyid_ctrl = payload->keyid_ctrl;
> +	memcpy(kprog->key_field_1, payload->data_key, MKTME_AES_XTS_SIZE);
> +	memcpy(kprog->key_field_2, payload->tweak_key, MKTME_AES_XTS_SIZE);
> +
> +	ret = MKTME_PROG_SUCCESS;	/* Future programming call */
> +	kmem_cache_free(mktme_prog_cache, kprog);
> +	return ret;
> +}

