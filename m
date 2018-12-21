Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2A68E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 15:30:00 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g12so4817887pll.22
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:30:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 27si21787961pgu.421.2018.12.21.12.29.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Dec 2018 12:29:59 -0800 (PST)
Date: Fri, 21 Dec 2018 12:29:46 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 01/12] x86_64: memset_user()
Message-ID: <20181221202946.GJ10600@bombadil.infradead.org>
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
 <20181221181423.20455-2-igor.stoppa@huawei.com>
 <20181221182515.GF10600@bombadil.infradead.org>
 <20181221200546.GA8441@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221200546.GA8441@uranus>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Igor Stoppa <igor.stoppa@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 21, 2018 at 11:05:46PM +0300, Cyrill Gorcunov wrote:
> On Fri, Dec 21, 2018 at 10:25:16AM -0800, Matthew Wilcox wrote:
> > On Fri, Dec 21, 2018 at 08:14:12PM +0200, Igor Stoppa wrote:
> > > +unsigned long __memset_user(void __user *addr, int c, unsigned long size)
> > > +{
> > > +	long __d0;
> > > +	unsigned long  pattern = 0;
> > > +	int i;
> > > +
> > > +	for (i = 0; i < 8; i++)
> > > +		pattern = (pattern << 8) | (0xFF & c);
> > 
> > That's inefficient.
> > 
> > 	pattern = (unsigned char)c;
> > 	pattern |= pattern << 8;
> > 	pattern |= pattern << 16;
> > 	pattern |= pattern << 32;
> 
> Won't
> 
> 	pattern = 0x0101010101010101 * c;
> 
> do the same but faster?

Depends on your CPU.  Some yes, some no.

(Also you need to cast 'c' to unsigned char to avoid someone passing in
0x1234 and getting 0x4646464646464634 instead of 0x3434343434343434)
