Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41661C28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:54:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB40F208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:54:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UuIzSHZ9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB40F208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94DA36B000C; Fri,  7 Jun 2019 03:54:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FEA96B000E; Fri,  7 Jun 2019 03:54:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C6816B0266; Fri,  7 Jun 2019 03:54:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4669E6B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 03:54:37 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y5so928037pfb.20
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 00:54:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xvljMUbhfLfotrIrCrjLlY8mPPXR4L/80hig3F5dpFs=;
        b=m/tkCEWePO4a/vdDFOWfIL9yC36qQ8ANHfyrfn384OwhQgPTHStnMhp2Y+eI02NLnh
         yh7qLK7EOG3HW8b5MpuTGhwqJn7rq4ZpzKZvs3/CS6qquyu23LsiwpSunaDAU9GaB5sQ
         CtnlhyrtxvPYxHFA8625plRuUCoXuy6DX2snXxJdqTOyc0oxTcmU0WVylZ1YLcBVXOIy
         qWMrDiwzPrselM78U0YuK5+3N9nF4GpFjKhnaVSHZou+VbgjWW1aUzniPYJ3AofKcR+q
         gY7hO+IRUuKaXSEIiTY+/yWL7rnc2iDWPAsRUJVdkO+TAL3WjIBgWBzNEoMRw1JCvOQO
         sQ3g==
X-Gm-Message-State: APjAAAXo4z+YWCVK67Hq+xZfAWNEnhu5y+AgEC810+DSpZm9LkQenFPa
	+jXrSIg+Hz8k6LbDXGbFfGidQhUUAUW8Cacm3lKdfXJsYi9O/pkAykklmbGN0Dm2mDJnFaygOjN
	TyHts/xbaqoyz+h4/M/ccUtaZLY7TebeiM8bssphVr9j3/LACJQC21t97j9X6h1jK+A==
X-Received: by 2002:a65:5684:: with SMTP id v4mr1653853pgs.160.1559894076892;
        Fri, 07 Jun 2019 00:54:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyD6ZlHibT+R665bUh34UYTj6ZD0dXVPVifWWWsZ8p+1TztwQgMJJDlGhz7Ogy+3pZs5tfL
X-Received: by 2002:a65:5684:: with SMTP id v4mr1653818pgs.160.1559894076143;
        Fri, 07 Jun 2019 00:54:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559894076; cv=none;
        d=google.com; s=arc-20160816;
        b=CRkmMCny0TvTdKpRgk0i/rHrhMgixGCnc7eg2BGRcodY92Ull8Zfm+TUK4gjnOoikt
         C4dVAYO+lPz/8y2sJnPfT7y+KkICq0C8c9KvJOcBEssRP69HTyUJ/cZUR12lF4yk9q2J
         OsEqcaWvAMlS45oxgOeFWFcuiTiTTGa07FbMWgXlrNjkPeHTHYtmWNTUQTyYFWebpXLE
         B79irDbmMwe2nE8AYmgNzyBxx0jcrD4uF2TNxmNvZEpJzJVt5iXV8yaLiU7IrFvnt/MQ
         Zi5mvxf76y903lP/Cq4PW63PzGobUQkgMaZKf039nm817EMXHQtvAMPrhsVQ7Ui43Mgc
         xpog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xvljMUbhfLfotrIrCrjLlY8mPPXR4L/80hig3F5dpFs=;
        b=eaWdJ4SAqKEyYFtQPjXL8hhxo2AnX6l2N5Y0PF5ZjgXxdkl6Br7GFkiJS3AKLS7TY5
         WMyq2L5j68+AZrT3Uo1pK+bb/nnOBvKgIuUhswuP0j6PIb/5IjPoOf6qBJ8NYXaTe0wk
         i9fFhBRhcZ3isfL2AxqzSpjW8VQywklJEiYRB4H23+s5b+/nAjWdn8Ilvhv7AeQeAfCX
         UA8QHm5Mcq6CBuG0qgkEsrk+ziOn/bJKm2qOTvkIaLhN8WLd4h4V19j9GaChZEoZil3p
         WXA/3p5B8/HW399pS9Vzvklb8Fm4nl7bvpKdrjqz3XKYM6Gw7biaSdQbhrCQBB2olg5Z
         f5nA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UuIzSHZ9;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a90si1223799plc.15.2019.06.07.00.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 07 Jun 2019 00:54:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UuIzSHZ9;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=xvljMUbhfLfotrIrCrjLlY8mPPXR4L/80hig3F5dpFs=; b=UuIzSHZ9YwR97SKzqkrVCQI+v
	GffCOVEUdSut0lgJr1DyKcWI+cWHHzHrMXcEBJ2OpppuG/N80JVQSOEK+VzI712E7KCva3L3Oj+f0
	wHJc1XpVbUaW20zGOy62EuE8N+ZKgZisPSwfMvDlnRyAKYVLc9t6OeD58tvZxg7MCJ/s95lkMdrbb
	jWQGX9wKVnrA6sUspkFQIWtCU6de6Wab9dRrjqza83D+MCJoGEBn0S7xBdDsQTlGZuimzmU6t4rYQ
	OJgCbv6CW3/40aaEa3b8cdd0nZXt4jIAWjlMKAyoxsqKGKU+7jceUr/GN7egWsIPxqBBh2iFtOch4
	liJ2fFuFA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hZ9hl-0004MJ-Nx; Fri, 07 Jun 2019 07:54:29 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 37DA4205663B2; Fri,  7 Jun 2019 09:54:28 +0200 (CEST)
Date: Fri, 7 Jun 2019 09:54:28 +0200
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
Subject: Re: [PATCH v7 23/27] x86/cet/shstk: ELF header parsing of Shadow
 Stack
Message-ID: <20190607075428.GQ3419@hirez.programming.kicks-ass.net>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-24-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606200646.3951-24-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 01:06:42PM -0700, Yu-cheng Yu wrote:

> +#ifdef CONFIG_ARCH_USE_GNU_PROPERTY
> +int arch_setup_property(void *ehdr, void *phdr, struct file *f, bool inter)
> +{
> +	int r;
> +	uint32_t property;

Flip those two lines around.

> +
> +	r = get_gnu_property(ehdr, phdr, f, GNU_PROPERTY_X86_FEATURE_1_AND,
> +			     &property);
> +
> +	memset(&current->thread.cet, 0, sizeof(struct cet_status));

It seems to me that memset would be better placed before
get_gnu_property().

> +	if (r)
> +		return r;
> +
> +	if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {

	if (r || !cpu_feature_enabled())
		return r;

> +		if (property & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
> +			r = cet_setup_shstk();
> +		if (r < 0)
> +			return r;
> +	}
> +	return r;

and loose the indent.

> +}
> +#endif
> -- 
> 2.17.1
> 

