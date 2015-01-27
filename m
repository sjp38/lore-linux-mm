Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id DBF326B0085
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 17:17:42 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id l6so14458919qcy.13
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 14:17:42 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id c6si3354929qan.67.2015.01.27.14.17.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jan 2015 14:17:42 -0800 (PST)
Message-ID: <1422396079.2493.62.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH 2/7] lib: Add huge I/O map capability interfaces
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 27 Jan 2015 15:01:19 -0700
In-Reply-To: <20150127133755.85fd18b4483d7554c083f99b@linux-foundation.org>
References: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
	 <1422314009-31667-3-git-send-email-toshi.kani@hp.com>
	 <20150126155456.a40df49e42b1b7f8077421f4@linux-foundation.org>
	 <1422320515.2493.53.camel@misato.fc.hp.com>
	 <20150127133755.85fd18b4483d7554c083f99b@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Tue, 2015-01-27 at 13:37 -0800, Andrew Morton wrote:
> On Mon, 26 Jan 2015 18:01:55 -0700 Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > > >  static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
> > > >  		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
> > > >  {
> > > > @@ -74,6 +112,12 @@ int ioremap_page_range(unsigned long addr,
> > > >  	unsigned long start;
> > > >  	unsigned long next;
> > > >  	int err;
> > > > +	static int ioremap_huge_init_done;
> > > > +
> > > > +	if (!ioremap_huge_init_done) {
> > > > +		ioremap_huge_init_done = 1;
> > > > +		ioremap_huge_init();
> > > > +	}
> > > 
> > > Looks hacky.  Why can't we just get the startup ordering correct?  It
> > > at least needs a comment which fully explains the situation.
> > 
> > How about calling it from mm_init() after vmalloc_init()?  
> > 
> > void __init mm_init(void)
> > 		:
> >         percpu_init_late();
> >         pgtable_init();
> >         vmalloc_init();
> > +       ioremap_huge_init();
> >  }
> 
> Sure, that would be better, assuming it can be made to work.

Yes, I verified that ioremap() works right after this point.

> Don't forget to mark ioremap_huge_init() as __init.

Right.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
