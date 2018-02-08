Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE656B0006
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 23:06:57 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id k78so1486651pfk.12
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 20:06:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g2si1864996pgq.416.2018.02.07.20.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Feb 2018 20:06:56 -0800 (PST)
Date: Wed, 7 Feb 2018 20:06:55 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] Warn the user when they could overflow mapcount
Message-ID: <20180208040655.GD14918@bombadil.infradead.org>
References: <20180208021112.GB14918@bombadil.infradead.org>
 <20180208031804.GD3304@eros>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180208031804.GD3304@eros>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Feb 08, 2018 at 02:18:04PM +1100, Tobin C. Harding wrote:
> > +++ b/Documentation/sysctl/vm.txt
> > @@ -379,7 +379,8 @@ While most applications need less than a thousand maps, certain
> >  programs, particularly malloc debuggers, may consume lots of them,
> >  e.g., up to one or two maps per allocation.
> >  
> > -The default value is 65536.
> > +The default value is 65530.  Increasing this value without decreasing
> > +pid_max may allow a hostile user to corrupt kernel memory.
> 
> Just checking - did you mean the final '0' on this value?

That's what my laptop emits ...

mm/mmap.c:int max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
include/linux/mm.h:#define DEFAULT_MAX_MAP_COUNT        (USHRT_MAX - MAPCOUNT_ELF_CORE_MARGIN)
include/linux/mm.h:#define MAPCOUNT_ELF_CORE_MARGIN     (5)

should be the same value for everybody.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
