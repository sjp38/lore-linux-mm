Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id B1F196B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 09:27:30 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id i50so2103000qgf.14
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 06:27:30 -0700 (PDT)
Received: from mail-qa0-x233.google.com (mail-qa0-x233.google.com [2607:f8b0:400d:c00::233])
        by mx.google.com with ESMTPS id x6si6548060qas.31.2014.06.19.06.27.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 06:27:30 -0700 (PDT)
Received: by mail-qa0-f51.google.com with SMTP id j7so1965951qaq.10
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 06:27:30 -0700 (PDT)
Date: Thu, 19 Jun 2014 09:27:27 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: percpu: micro-optimize round-to-even
Message-ID: <20140619132727.GG11042@htj.dyndns.org>
References: <1403172149-25353-1-git-send-email-linux@rasmusvillemoes.dk>
 <20140619132536.GF11042@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140619132536.GF11042@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 19, 2014 at 09:25:36AM -0400, Tejun Heo wrote:
> On Thu, Jun 19, 2014 at 12:02:29PM +0200, Rasmus Villemoes wrote:
> > This change shaves a few bytes off the generated code.
> > 
> > Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> > ---
> >  mm/percpu.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/mm/percpu.c b/mm/percpu.c
> > index 2ddf9a9..978097f 100644
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -720,8 +720,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
> >  	if (unlikely(align < 2))
> >  		align = 2;
> >  
> > -	if (unlikely(size & 1))
> > -		size++;
> > +	size += size & 1;
> 
> I'm not gonna apply this.  This isn't that hot a path.  It's not
> worthwhile to micro optimize code like this.

Another thing is that it isn't even clear whether the micro
optimization is even actually better given that predicted branches are
extremely cheap and this one is extremely predictable.  So, again,
let's please leave it to the compiler.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
