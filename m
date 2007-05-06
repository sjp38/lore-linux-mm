Received: by wr-out-0506.google.com with SMTP id 57so1234763wri
        for <linux-mm@kvack.org>; Sun, 06 May 2007 12:46:43 -0700 (PDT)
Message-ID: <a781481a0705061246y10568c25h8d82233dbc43ce5c@mail.gmail.com>
Date: Mon, 7 May 2007 01:16:42 +0530
From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [RFC 1/3] SLUB: slab_ops instead of constructors / destructors
In-Reply-To: <463E2A37.2030400@informatik.uni-halle.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070504221555.642061626@sgi.com>
	 <20070504221708.363027097@sgi.com>
	 <463E2A37.2030400@informatik.uni-halle.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bert Wesarg <wesarg@informatik.uni-halle.de>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On 5/7/07, Bert Wesarg <wesarg@informatik.uni-halle.de> wrote:
> clameter@sgi.com wrote:
> > +     if (ctor || dtor) {
> > +             so = kzalloc(sizeof(struct slab_ops), GFP_KERNEL);
> > +             so->ctor = ctor;
> > +             so->dtor = dtor;
> > +     }
> > +     return  __kmem_cache_create(s, size, align, flags, so);
> Is this a memory leak?

Yes, but see:

On 5/5/07, clameter@sgi.com <clameter@sgi.com> wrote:
> If constructor or destructor are specified then we will allocate a slab_ops
> structure and populate it with the values specified. Note that this will
> cause a memory leak if the slab is disposed of later. If you need disposable
> slabs then the new API must be used.

BTW:

> > +     if (ctor || dtor) {
> > +             so = kzalloc(sizeof(struct slab_ops), GFP_KERNEL);
> > +             so->ctor = ctor;

It's also a potential oops, actually. kzalloc's return must be checked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
