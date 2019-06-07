Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7488FC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:43:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06FBC208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:43:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="1S7ljWD5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06FBC208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 698586B0266; Fri,  7 Jun 2019 03:43:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64A5C6B0269; Fri,  7 Jun 2019 03:43:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50EC36B026F; Fri,  7 Jun 2019 03:43:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id F108B6B0266
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 03:43:48 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id d21so208940wmb.3
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 00:43:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JShvpN7WursRgWDXz41S2caRK10woHUgD4tuDRKgTsc=;
        b=jZEwGsUuaQK4qRZJJHz0fu2+X3qpXjtUe6ckf9wEVU+5ClHk6pLdwS7Y6m5fzx7vzN
         h7AcMDozbtInJjIEuHx6STUG3jCCwIO5cD3fTpk7fuV/TcjJqvAARKdHOFBfdqQcZ7Fj
         XjvN9/8Qy4U45ALIUZMmoBX27fhhqTXBmHW1AsbivcpPzOq3QFXd/+BpMqztfUfFX/z+
         dw+h+NOADk8qcr+vkkHAmFCBBavRoYn6aUubwTlH0R7o9l7L25q3kUJT9IZX/odcc83e
         Q6QVGS/w4uoO4sPrUnXP68BxxDFWx/ibm+Kh3bJnA+NzoomGPyd1BCMmwR6Gd36Lz49I
         yuRQ==
X-Gm-Message-State: APjAAAX3h02GEa3I7oWNLYHFQrC/Dc89wMd9g7T3+ppfPi2FaRhZvWbA
	iybalemWiCmfloBPA+2WNxBY2TKyNLzHb+lI+de0zW4II55mpfhgplvhvkwsDHLzz6FJl5q9b1T
	cnU6hy1C7tvBZ20doQhVMp8Z44Ykp9pUoCZtaGS75SIwsvzcvDduq/3yeiCR95RDcRA==
X-Received: by 2002:a5d:4a0b:: with SMTP id m11mr22966732wrq.251.1559893428290;
        Fri, 07 Jun 2019 00:43:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbl+O8+lU5okKYJu2M67Uct2t7bjH1kLV7HJiWg6+rpySK7vF6X0rxEKEVWfbisE9KvQE9
X-Received: by 2002:a5d:4a0b:: with SMTP id m11mr22966695wrq.251.1559893427591;
        Fri, 07 Jun 2019 00:43:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559893427; cv=none;
        d=google.com; s=arc-20160816;
        b=Szx4/6u8HC0G/qlEFKmuim9x7CvmM7nwWVFHjyzLA/IMzr5mEams0ehRZyvb1x+IMr
         9xD36ojrPS14LwKMBwDHw7xUwO2kisRgCr/nD51wcXIYri3aSLAo1cAoY1GScVTvIGxq
         /omgCz9tHFKx/syJhGeK2/zguM7kyq89+57IjXFYEw78+U5aCdT8Q4PYw5yX1SpvpnUD
         9ORTLaKnq/bZpyj+i0ANxqNUyz/fNWwhinOfQlfYwm+H0I/IFUg22wROWYLmVTJNnT/f
         DlGfc7YebnSMBc23Mk0G9giJrdRTUz/eKHJXAGfnkp6Ow1DlsLoqtXQBvTqIJ79NvC+s
         RGsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JShvpN7WursRgWDXz41S2caRK10woHUgD4tuDRKgTsc=;
        b=mWMTITXoEDnpNfX7xLl4owKSlKuGQhkaz2VbSaf+U3O1LUyNjVhOg1QWmbpbG7j3ss
         BsykPCF4iz1u/wULnSzY4sxuQKXraWAwMRUyI3+sSUbQi2m2wWbbH99rr4u37eARJz3l
         QkUjT1TMncQbx/8LPKR8jBjhGb664G9X7/d0L3noCHum0bm/KVD/+mZQTNLL7CLPBlD/
         AGf8xcdC/FhlmIwcs+Gnc36zS6PNJRjmyaLfRlhrnmYqSupuD0UyBrMRvYUaT2pq2WOf
         CWJ6pJHol3hwRUA0RJmeR4RD5f9tEpKzj0wEafISogG4SAkBCiC5/doz2IbVwQsddRnG
         RNvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=1S7ljWD5;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u7si850497wmj.70.2019.06.07.00.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 07 Jun 2019 00:43:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=1S7ljWD5;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=JShvpN7WursRgWDXz41S2caRK10woHUgD4tuDRKgTsc=; b=1S7ljWD5ClCiKXft78kkDXYzu
	BR5E9SvvKZIxdJe1mhQhdLj/GwLRgpPtPTkqFWmg9yqjwQNhVjrPRSIeL/OoZlxczwx//D68q1XJs
	FfByu9/q4FNFB5MXMSXJOJgnvL+2AJsWyK9lsq/Ah8896IEYsL9RTqGpSzTSuB3kfr8fec3EzuxQ/
	65SeGDN5iK4k08dfXCNFi4ombF+WbCqRMUKIS3vXBM5VM3WBfBI8n3Yv55ZdItHAuZ42Kr9bR+wpr
	j2D8T94McWzfsRBDWW4DzC7eThiUDI9XwBhKlICynz4wC6UJFeY7+mKw6hOTG2CA3XB8AR1FgneV1
	THzrvW5Mw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hZ9X3-0002X3-7w; Fri, 07 Jun 2019 07:43:25 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 394D5202CD6B2; Fri,  7 Jun 2019 09:43:22 +0200 (CEST)
Date: Fri, 7 Jun 2019 09:43:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v7 18/27] mm: Introduce do_mmap_locked()
Message-ID: <20190607074322.GP3419@hirez.programming.kicks-ass.net>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-19-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606200646.3951-19-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 01:06:37PM -0700, Yu-cheng Yu wrote:
> There are a few places that need do_mmap() with mm->mmap_sem held.
> Create an in-line function for that.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  include/linux/mm.h | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 398f1e1c35e5..7cf014604848 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2411,6 +2411,24 @@ static inline void mm_populate(unsigned long addr, unsigned long len)
>  static inline void mm_populate(unsigned long addr, unsigned long len) {}
>  #endif
>  
> +static inline unsigned long do_mmap_locked(unsigned long addr,
> +	unsigned long len, unsigned long prot, unsigned long flags,
> +	vm_flags_t vm_flags)
> +{
> +	struct mm_struct *mm = current->mm;
> +	unsigned long populate;
> +
> +	down_write(&mm->mmap_sem);
> +	addr = do_mmap(NULL, addr, len, prot, flags, vm_flags, 0,
> +		       &populate, NULL);

Funny thing how do_mmap() takes a file pointer as first argument and
this thing explicitly NULLs that. That more or less invalidates the name
do_mmap_locked().

> +	up_write(&mm->mmap_sem);
> +
> +	if (populate)
> +		mm_populate(addr, populate);
> +
> +	return addr;
> +}


