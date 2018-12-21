Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEC108E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:25:26 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id u17so5041939pgn.17
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:25:26 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g5si3976111plo.108.2018.12.21.10.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Dec 2018 10:25:25 -0800 (PST)
Date: Fri, 21 Dec 2018 10:25:16 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 01/12] x86_64: memset_user()
Message-ID: <20181221182515.GF10600@bombadil.infradead.org>
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
 <20181221181423.20455-2-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221181423.20455-2-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 21, 2018 at 08:14:12PM +0200, Igor Stoppa wrote:
> +unsigned long __memset_user(void __user *addr, int c, unsigned long size)
> +{
> +	long __d0;
> +	unsigned long  pattern = 0;
> +	int i;
> +
> +	for (i = 0; i < 8; i++)
> +		pattern = (pattern << 8) | (0xFF & c);

That's inefficient.

	pattern = (unsigned char)c;
	pattern |= pattern << 8;
	pattern |= pattern << 16;
	pattern |= pattern << 32;
