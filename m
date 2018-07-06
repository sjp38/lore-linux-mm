Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA246B0008
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 17:54:39 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o7-v6so5425485pll.13
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 14:54:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id v2-v6si8604635pgq.142.2018.07.06.14.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 14:54:38 -0700 (PDT)
Date: Fri, 6 Jul 2018 15:54:37 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] mm/sparse.c: fix error path in sparse_add_one_section
Message-ID: <20180706215437.GB21639@linux.intel.com>
References: <CAOxpaSVkLh23jN_=0GpZ77EhKdAYaiWKkppnxWwf_MRa5FvopA@mail.gmail.com>
 <20180706190658.6873-1-ross.zwisler@linux.intel.com>
 <20180706212327.GA10824@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180706212327.GA10824@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, pasha.tatashin@oracle.com, linux-nvdimm@lists.01.org, bhe@redhat.com, Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, osalvador@suse.de

On Fri, Jul 06, 2018 at 11:23:27PM +0200, Oscar Salvador wrote:
> On Fri, Jul 06, 2018 at 01:06:58PM -0600, Ross Zwisler wrote:
> > The following commit in -next:
> > 
> > commit 054620849110 ("mm/sparse.c: make sparse_init_one_section void and
> > remove check")
> > 
> > changed how the error handling in sparse_add_one_section() works.
> > 
> > Previously sparse_index_init() could return -EEXIST, and the function would
> > continue on happily.  'ret' would get unconditionally overwritten by the
> > result from sparse_init_one_section() and the error code after the 'out:'
> > label wouldn't be triggered.
> 
> My bad, I missed that.
> 
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 9574113fc745..d254bd2d3289 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -753,8 +753,12 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
> >  	 * plus, it does a kmalloc
> >  	 */
> >  	ret = sparse_index_init(section_nr, pgdat->node_id);
> > -	if (ret < 0 && ret != -EEXIST)
> > -		return ret;
> > +	if (ret < 0) {
> > +		if (ret == -EEXIST)
> > +			ret = 0;
> > +		else
> > +			return ret;
> > +	}
> 
> sparse_index_init() can return:
> 
> -ENOMEM, -EEXIST or 0.
> 
> So what about this?:
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index f55e79fda03e..eb188eb6b82d 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -770,6 +770,7 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
>         ret = sparse_index_init(section_nr, pgdat->node_id);
>         if (ret < 0 && ret != -EEXIST)
>                 return ret;
> +       ret = 0;
> 
> Does this look more clean?

Sure, that's probably better.

Andrew, what's the easiest way forward?  I can send out a v2, you can fold
this into his previous patch, or something else?
