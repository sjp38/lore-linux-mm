Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id B70BB6B0261
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 05:30:30 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so104396830wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 02:30:30 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id fi8si6799670wib.24.2015.09.24.02.30.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 02:30:29 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so243296435wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 02:30:29 -0700 (PDT)
Date: Thu, 24 Sep 2015 11:30:26 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
Message-ID: <20150924093026.GA29699@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
 <20150924092320.GA26876@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150924092320.GA26876@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Ingo Molnar <mingo@kernel.org> wrote:

> > --- a/include/uapi/asm-generic/siginfo.h~pkeys-09-siginfo	2015-09-16 10:48:15.584161859 -0700
> > +++ b/include/uapi/asm-generic/siginfo.h	2015-09-16 10:48:15.592162222 -0700
> > @@ -95,6 +95,13 @@ typedef struct siginfo {
> >  				void __user *_lower;
> >  				void __user *_upper;
> >  			} _addr_bnd;
> > +			int _pkey; /* FIXME: protection key value??
> > +				    * Do we really need this in here?
> > +				    * userspace can get the PKRU value in
> > +				    * the signal handler, but they do not
> > +				    * easily have access to the PKEY value
> > +				    * from the PTE.
> > +				    */
> >  		} _sigfault;
> 
> A couple of comments:
> 
> 1)
> 
> Please use our ABI types - this one should be 'u32' I think.
> 
> We could use 'u8' as well here, and mark another 3 bytes next to it as reserved 
> for future flags. Right now protection keys use 4 bits, but do you really think 
> they'll ever grow beyond 8 bits? PTE bits are a scarce resource in general.
> 
> 2)
> 
> To answer your question in the comment: it looks useful to have some sort of 
> 'extended page fault error code' information here, which shows why the page fault 
> happened. With the regular error_code it's easy - with protection keys there's 16 
> separate keys possible and user-space might not know the actual key value in the 
> pte.

Btw., alternatively we could also say that user-space should know what protection 
key it used when it created the mapping - there's no need to recover it for every 
page fault.

OTOH, as long as we don't do a separate find_vma(), it looks cheap enough to look 
up the pkey value of that address and give it to user-space in the signal frame.

Btw., how does pkey support interact with hugepages?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
