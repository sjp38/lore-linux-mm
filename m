Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E84F6B0011
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 06:21:30 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id t31so6335417qtc.12
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 03:21:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n3si773295qtd.360.2018.02.09.03.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 03:21:26 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w19BKfF1074227
	for <linux-mm@kvack.org>; Fri, 9 Feb 2018 06:21:25 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g17d31j06-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Feb 2018 06:21:23 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 9 Feb 2018 11:11:11 -0000
Date: Fri, 9 Feb 2018 13:11:03 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] zsmalloc: introduce zs_huge_object() function
References: <20180207092919.19696-1-sergey.senozhatsky@gmail.com>
 <20180207092919.19696-2-sergey.senozhatsky@gmail.com>
 <20180208163006.GB17354@rapoport-lnx>
 <20180209025520.GA3423@jagdpanzerIV>
 <20180209041046.GB23828@bombadil.infradead.org>
 <20180209053630.GC689@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180209053630.GC689@jagdpanzerIV>
Message-Id: <20180209111102.GB2044@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, Feb 09, 2018 at 02:36:30PM +0900, Sergey Senozhatsky wrote:
> On (02/08/18 20:10), Matthew Wilcox wrote:
> [..]
> > Examples::
> > 
> >   * Context: Any context.
> >   * Context: Any context. Takes and releases the RCU lock.
> >   * Context: Any context. Expects <lock> to be held by caller.
> >   * Context: Process context. May sleep if @gfp flags permit.
> >   * Context: Process context. Takes and releases <mutex>.
> >   * Context: Softirq or process context. Takes and releases <lock>, BH-safe.
> >   * Context: Interrupt context.
> 
> I assume that  <mutex>  spelling serves as a placeholder and should be
> replaced with a lock name in a real comment. E.g.
> 
> 	Takes and releases audit_cmd_mutex.
> 
> or should it actually be
> 
> 	Takes and releases <audit_cmd_mutex>.
> 
> 
> 
> 
> So below is zs_huge_object() documentation I came up with:
>
> ---
> 
> +/**
> + * zs_huge_object() - Test if a compressed object's size is too big for normal
> + *                    zspool classes and it will be stored in a huge class.

Maybe "it should be stored ..."?

> + * @sz: Size in bytes of the compressed object.
> + *
> + * The functions checks if the object's size falls into huge_class area.
> + * We must take ZS_HANDLE_SIZE into account and test the actual size we

                ^ %ZS_HANDLE_SIZE

> + * are going to use up, because zs_malloc() unconditionally adds the

I think 's/use up/use/' here

> + * handle size before it performs size_class lookup.

                                   ^ &size_class
> + *
> + * Context: Any context.
> + *
> + * Return:
> + * * true  - The object's size is too big, it will be stored in a huge class.
> + * * false - The object will be store in normal zspool classes.
> + */
> ---
> 
> looks OK?
> 
> 	-ss
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
