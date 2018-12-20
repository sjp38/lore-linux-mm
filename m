Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1908E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:28:03 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 143so2344656pgc.3
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:28:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u34si3336631pgk.24.2018.12.20.11.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 20 Dec 2018 11:28:02 -0800 (PST)
Date: Thu, 20 Dec 2018 11:27:53 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 04/12] __wr_after_init: x86_64: __wr_op
Message-ID: <20181220192753.GZ10600@bombadil.infradead.org>
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
 <20181219213338.26619-5-igor.stoppa@huawei.com>
 <20181220184917.GY10600@bombadil.infradead.org>
 <d5e8523a-3afd-d992-1af3-b329985c5ed5@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d5e8523a-3afd-d992-1af3-b329985c5ed5@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2018 at 09:19:15PM +0200, Igor Stoppa wrote:
> On 20/12/2018 20:49, Matthew Wilcox wrote:
> > I think you're causing yourself more headaches by implementing this "op"
> > function.
> 
> I probably misinterpreted the initial criticism on my first patchset, about
> duplication. Somehow, I'm still thinking to the endgame of having
> higher-level functions, like list management.
> 
> > Here's some generic code:
> 
> thank you, I have one question, below
> 
> > void *wr_memcpy(void *dst, void *src, unsigned int len)
> > {
> > 	wr_state_t wr_state;
> > 	void *wr_poking_addr = __wr_addr(dst);
> > 
> > 	local_irq_disable();
> > 	wr_enable(&wr_state);
> > 	__wr_memcpy(wr_poking_addr, src, len);
> 
> Is __wraddr() invoked inside wm_memcpy() instead of being invoked privately
> within __wr_memcpy() because the code is generic, or is there some other
> reason?

I was assuming that __wr_addr() might be costly, and we were trying to
minimise the number of instructions executed while write-rare was enabled.
