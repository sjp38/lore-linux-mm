Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id DC2D96B025A
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:20:22 -0500 (EST)
Received: by mail-oi0-f43.google.com with SMTP id y66so111461096oig.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 09:20:22 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id w84si23131291oif.98.2015.12.22.09.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 09:20:22 -0800 (PST)
Message-ID: <1450804798.10450.45.camel@hpe.com>
Subject: Re: [PATCH 2/2] x86/mm/pat: Change free_memtype() to free shrinking
 range
From: Toshi Kani <toshi.kani@hpe.com>
Date: Tue, 22 Dec 2015 10:19:58 -0700
In-Reply-To: <alpine.DEB.2.11.1512201025050.28591@nanos>
References: <1449678368-31793-1-git-send-email-toshi.kani@hpe.com>
	 <1449678368-31793-3-git-send-email-toshi.kani@hpe.com>
	 <alpine.DEB.2.11.1512201025050.28591@nanos>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: mingo@redhat.com, hpa@zytor.com, bp@alien8.de, stsp@list.ru, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>

On Sun, 2015-12-20 at 10:27 +0100, Thomas Gleixner wrote:
> Toshi,
> 
> On Wed, 9 Dec 2015, Toshi Kani wrote:
> > diff --git a/arch/x86/mm/pat_rbtree.c b/arch/x86/mm/pat_rbtree.c
> > index 6393108..d6faef8 100644
> > --- a/arch/x86/mm/pat_rbtree.c
> > +++ b/arch/x86/mm/pat_rbtree.c
> > @@ -107,7 +112,12 @@ static struct memtype
> > *memtype_rb_exact_match(struct rb_root *root,
> >  	while (match != NULL && match->start < end) {
> >  		struct rb_node *node;
> >  
> > -		if (match->start == start && match->end == end)
> > +		if ((match_type == MEMTYPE_EXACT_MATCH) &&
> > +		    (match->start == start) && (match->end == end))
> > +			return match;
> > +
> > +		if ((match_type == MEMTYPE_SHRINK_MATCH) &&
> > +		    (match->start < start) && (match->end == end))
> 
> Confused. If we shrink a mapping then I'd expect that the start of the
> mapping stays the same and the end changes. 

Yes, that is correct after this request is done.

> I certainly miss something here, but if the above is correct, then it 
> definitely needs a big fat comment explaining it.

This request specifies a range being "unmapped", not the remaining mapped
range.  So, when the mapping range is going to shrink from the end, the
unmapping range has a bigger 'start' value and the same 'end' value. 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
