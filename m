Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 34F0D6B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 14:14:45 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id c16so9043620pgv.8
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 11:14:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n27si12525339pfg.102.2018.03.06.11.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Mar 2018 11:14:42 -0800 (PST)
Date: Tue, 6 Mar 2018 11:14:39 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 05/25] slab: make create_boot_cache() work with 32-bit
 sizes
Message-ID: <20180306191439.GB11216@bombadil.infradead.org>
References: <20180305200730.15812-1-adobriyan@gmail.com>
 <20180305200730.15812-5-adobriyan@gmail.com>
 <alpine.DEB.2.20.1803061232190.29393@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803061232190.29393@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Tue, Mar 06, 2018 at 12:34:05PM -0600, Christopher Lameter wrote:
> On Mon, 5 Mar 2018, Alexey Dobriyan wrote:
> 
> > struct kmem_cache::size has always been "int", all those
> > "size_t size" are fake.
> 
> They are useful since you typically pass sizeof( < whatever > ) as a
> parameter to kmem_cache_create(). Passing those values onto other
> functions internal to slab could use int.

Sure, but:

struct foo {
	int n;
	char *p;
};
int f(unsigned int x);

int g(void)
{
	return f(sizeof(struct foo));
}

gives:

   0:   bf 10 00 00 00          mov    $0x10,%edi
   5:   e9 00 00 00 00          jmpq   a <g+0xa>

Changing the prototype to "int f(unsigned long x)" produces _exactly the
same assembly_.  Why?  Because mov to %edi will zero out the upper 32-bits
of %rdi.  I consider it one of the flaws in the x86 instruction set that
mov %di doesn't zero out the upper 16 bits of %edi (and correspondingly
the upper 48 bits of %rdi), as it'd save an awful lot of bytes in the
instruction stream by replacing 32-bit constants with 16-bit constants.

There's just no difference between these two.  Unless you want to talk
about a structure exceeding 4GB in size, and then I'm afraid we have
bigger problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
