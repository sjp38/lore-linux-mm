Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0F26F6B01AF
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 12:39:02 -0400 (EDT)
Received: by pwj5 with SMTP id 5so61426pwj.14
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 09:39:00 -0700 (PDT)
Date: Thu, 3 Jun 2010 01:38:52 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
Message-ID: <20100602163827.GA5450@barrios-desktop>
References: <20100528173510.GA12166@ca-server1.us.oracle.comAANLkTilV-4_QaNq5O0WSplDx1Oq7JvkgVrEiR1rgf1up@mail.gmail.com>
 <1d88619a-bb1e-493f-ad96-bf204b60938d@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1d88619a-bb1e-493f-ad96-bf204b60938d@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

Hi, Dan. 

On Wed, Jun 02, 2010 at 08:27:48AM -0700, Dan Magenheimer wrote:
> Hi Minchan --
> 
> > I think cleancache approach is cool. :)
> > I have some suggestions and questions.
> 
> Thanks for your interest!
> 
> > > If a get_page is successful on a non-shared pool, the page is flushed
> > (thus
> > > making cleancache an "exclusive" cache).  On a shared pool, the page
> > 
> > Do you have any reason about force "exclusive" on a non-shared pool?
> > To free memory on pesudo-RAM?
> > I want to make it "inclusive" by some reason but unfortunately I can't
> > say why I want it now.
> 
> The main reason is to free up memory in pseudo-RAM and to
> avoid unnecessary cleancache_flush calls.  If you want
> inclusive, the page can be put immediately following
> the get.  If put-after-get for inclusive becomes common,
> the interface could easily be extended to add a "get_no_flush"
> call.

Sounds good to me. 

>  
> > While you mentioned it's "exclusive", cleancache_get_page doesn't
> > flush the page at below code.
> > Is it a role of user who implement cleancache_ops->get_page?
> 
> Yes, the flush is done by the cleancache implementation.
> 
> > If backed device is ram(ie), Could we _move_ the pages from page cache
> > to cleancache?
> > I mean I don't want to copy page when get/put operation. we can just
> > move page in case of backed device "ram". Is it possible?
> 
> By "move", do you mean changing the virtual mappings?  Yes,
> this could be done as long as the source and destination are
> both directly addressable (that is, true physical RAM), but
> requires TLB manipulation and has some complicated corner
> cases.  The copy semantics simplifies the implementation on
> both the "frontend" and the "backend" and also allows the
> backend to do fancy things on-the-fly like page compression
> and page deduplication.

Agree. But I don't mean it. 
If I use brd as backend, i want to do it follwing as. 

put_page :

remove_from_page_cache(page);
brd_insert_page(page);

get_page :

brd_lookup_page(page);
add_to_page_cache(page);

Of course, I know it's impossible without new metadata and modification of 
page cache handling and it makes front and backend's good layered design. 

What I want is to remove copy overhead when backend is ram and it's also
part of main memory(ie, we have page descriptor). 

Do you have an idea?

> 
> > You send the patches which is core of cleancache but I don't see any
> > use case.
> > Could you send use case patches with this series?
> > It could help understand cleancache's benefit.
> 
> Do you mean the Xen Transcendent Memory ("tmem") implementation?
> If so, this is four files in the Xen source tree (common/tmem.c,
> common/tmem_xen.c, include/xen/tmem.h, include/xen/tmem_xen.h).
> There is also an html document in the Xen source tree, which can
> be viewed here:
> http://oss.oracle.com/projects/tmem/dist/documentation/internals/xen4-internals-v01.html 
> 
> Or did you mean a cleancache_ops "backend"?  For tmem, there
> is one file linux/drivers/xen/tmem.c and it interfaces between
> the cleancache_ops calls and Xen hypercalls.  It should be in
> a Xenlinux pv_ops tree soon, or I can email it sooner.

I mean "backend". :) 

> 
> I am also eagerly awaiting Nitin Gupta's cleancache backend
> and implementation to do in-kernel page cache compression.

Do Nitin say he will make backend of cleancache for
page cache compression? 

It would be good feature. 
I have a interest, too. :)

Thanks, Dan. 

> 
> Thanks,
> Dan

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
