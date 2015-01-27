Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 888A66B0082
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 16:37:57 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id y10so21252395pdj.7
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 13:37:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gt6si3024495pac.204.2015.01.27.13.37.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jan 2015 13:37:56 -0800 (PST)
Date: Tue, 27 Jan 2015 13:37:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 2/7] lib: Add huge I/O map capability interfaces
Message-Id: <20150127133755.85fd18b4483d7554c083f99b@linux-foundation.org>
In-Reply-To: <1422320515.2493.53.camel@misato.fc.hp.com>
References: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
	<1422314009-31667-3-git-send-email-toshi.kani@hp.com>
	<20150126155456.a40df49e42b1b7f8077421f4@linux-foundation.org>
	<1422320515.2493.53.camel@misato.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon, 26 Jan 2015 18:01:55 -0700 Toshi Kani <toshi.kani@hp.com> wrote:

> > >  static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
> > >  		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
> > >  {
> > > @@ -74,6 +112,12 @@ int ioremap_page_range(unsigned long addr,
> > >  	unsigned long start;
> > >  	unsigned long next;
> > >  	int err;
> > > +	static int ioremap_huge_init_done;
> > > +
> > > +	if (!ioremap_huge_init_done) {
> > > +		ioremap_huge_init_done = 1;
> > > +		ioremap_huge_init();
> > > +	}
> > 
> > Looks hacky.  Why can't we just get the startup ordering correct?  It
> > at least needs a comment which fully explains the situation.
> 
> How about calling it from mm_init() after vmalloc_init()?  
> 
> void __init mm_init(void)
> 		:
>         percpu_init_late();
>         pgtable_init();
>         vmalloc_init();
> +       ioremap_huge_init();
>  }

Sure, that would be better, assuming it can be made to work.  Don't
forget to mark ioremap_huge_init() as __init.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
