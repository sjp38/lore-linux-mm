Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95B106B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 15:49:38 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 96so9922180wrk.7
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 12:49:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o10si11066354wro.291.2017.12.18.12.49.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 12:49:37 -0800 (PST)
Date: Mon, 18 Dec 2017 21:49:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/8] mm: De-indent struct page
Message-ID: <20171218204935.GU16951@dhcp22.suse.cz>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-3-willy@infradead.org>
 <20171218153652.GC3876@dhcp22.suse.cz>
 <20171218161902.GA688@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171218161902.GA688@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Mon 18-12-17 08:19:02, Matthew Wilcox wrote:
> On Mon, Dec 18, 2017 at 04:36:52PM +0100, Michal Hocko wrote:
> > On Sat 16-12-17 08:44:19, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > I found the struct { union { struct { union { struct { } } } } }
> > > layout rather confusing.  Fortunately, there is an easier way to write
> > > this.  The innermost union is of four things which are the size of an
> > > int, so the ones which are used by slab/slob/slub can be pulled up
> > > two levels to be in the outermost union with 'counters'.  That leaves
> > > us with struct { union { struct { atomic_t; atomic_t; } } } which
> > > has the same layout, but is easier to read.
> > 
> > This is where the pahole output would be really helpeful. The patch
> > looks OK, I will double check with a fresh brain tomorrow (with the rest
> > of the series), though.
> 
> I got Arnaldo to change the pahole output to make this easier.  Here's
> the result:
> 
> @@ -11,17 +11,15 @@
>  	};                                               /*    16     8 */
>  	union {
>  		long unsigned int  counters;             /*    24     8 */
> +		unsigned int       active;               /*    24     4 */
>  		struct {
> -			union {
> -				atomic_t _mapcount;      /*    24     4 */
> -				unsigned int active;     /*    24     4 */
> -				struct {
> -					unsigned int inuse:16; /*    24:16  4 */
> -					unsigned int objects:15; /*    24: 1  4 */
> -					unsigned int frozen:1; /*    24: 0  4 */
> -				};                       /*    24     4 */
> -				int units;               /*    24     4 */
> -			};                               /*    24     4 */
> +			unsigned int inuse:16;           /*    24:16  4 */
> +			unsigned int objects:15;         /*    24: 1  4 */
> +			unsigned int frozen:1;           /*    24: 0  4 */
> +		};                                       /*    24     4 */
> +		int                units;                /*    24     4 */
> +		struct {
> +			atomic_t   _mapcount;            /*    24     4 */
>  			atomic_t   _refcount;            /*    28     4 */
>  		};                                       /*    24     8 */
>  	};                                               /*    24     8 */
> 
> 
> It's even more dramatic if you use diff -uw (ignore whitespace):
> 
> @@ -11,9 +11,6 @@
>  	};                                               /*    16     8 */
>  	union {
>  		long unsigned int  counters;             /*    24     8 */
> -		struct {
> -			union {
> -				atomic_t _mapcount;      /*    24     4 */
>  				unsigned int active;     /*    24     4 */
>  				struct {
>  					unsigned int inuse:16; /*    24:16  4 */
> @@ -21,7 +18,8 @@
>  					unsigned int frozen:1; /*    24: 0  4 */
>  				};                       /*    24     4 */
>  				int units;               /*    24     4 */
> -			};                               /*    24     4 */
> +		struct {
> +			atomic_t   _mapcount;            /*    24     4 */
>  			atomic_t   _refcount;            /*    28     4 */
>  		};                                       /*    24     8 */
>  	};                                               /*    24     8 */
> 

Excelent! Could you add the later one to the changelog please? With
that
Acked-by: Michal Hocko <mhocko@suse.com>

I will go over the rest of the series tomorrow.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
