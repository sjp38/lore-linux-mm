Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 056BE8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 15:05:50 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id f5-v6so1955419ljj.17
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:05:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s22sor7021637lfb.46.2018.12.21.12.05.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 12:05:48 -0800 (PST)
Date: Fri, 21 Dec 2018 23:05:46 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 01/12] x86_64: memset_user()
Message-ID: <20181221200546.GA8441@uranus>
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
 <20181221181423.20455-2-igor.stoppa@huawei.com>
 <20181221182515.GF10600@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221182515.GF10600@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Igor Stoppa <igor.stoppa@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 21, 2018 at 10:25:16AM -0800, Matthew Wilcox wrote:
> On Fri, Dec 21, 2018 at 08:14:12PM +0200, Igor Stoppa wrote:
> > +unsigned long __memset_user(void __user *addr, int c, unsigned long size)
> > +{
> > +	long __d0;
> > +	unsigned long  pattern = 0;
> > +	int i;
> > +
> > +	for (i = 0; i < 8; i++)
> > +		pattern = (pattern << 8) | (0xFF & c);
> 
> That's inefficient.
> 
> 	pattern = (unsigned char)c;
> 	pattern |= pattern << 8;
> 	pattern |= pattern << 16;
> 	pattern |= pattern << 32;

Won't

	pattern = 0x0101010101010101 * c;

do the same but faster?
