Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D92C68D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 12:02:57 -0500 (EST)
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
From: "Ricardo M. Correia" <ricardo.correia@oracle.com>
In-Reply-To: <20101111142511.c98c3808.akpm@linux-foundation.org>
References: <1289421759.11149.59.camel@oralap>
	 <20101111120643.22dcda5b.akpm@linux-foundation.org>
	 <1289512924.428.112.camel@oralap>
	 <20101111142511.c98c3808.akpm@linux-foundation.org>
Content-Type: multipart/mixed; boundary="=-fPygR0hXtWKoZOc1864v"
Date: Mon, 15 Nov 2010 18:01:40 +0100
Message-ID: <1289840500.13446.65.camel@oralap>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>


--=-fPygR0hXtWKoZOc1864v
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi Andrew,

On Thu, 2010-11-11 at 14:25 -0800, Andrew Morton wrote:
> > So do you think we should change all that?
> 
> Oh God, what have you done :(
> 
> No, I don't think we want to add a gfp_t to all of that code to fix one
> stupid bug in vmalloc().
> 
> > Or do you prefer the per-task mask? Or maybe even both? :-)
> 
> Right now I'm thinking that the thing to do is to do the
> pass-gfp_t-via-task_struct thing.

I have attached my first attempt to fix this in the easiest way I could
think of.

Please note that the code is untested at the moment (I didn't even try
to compile it yet) :-)
I would like to test it, but I would also like to get your feedback
first to make sure that I'm going in the right direction, at least.

I'm not sure if at this point in time we want to do what we discussed
before, e.g., making sure that the entire kernel uses this per-thread
mask whenever it switches context, or whenever it crosses into the mm
code boundary.

For now, and at least for us, I think my patch would suffice to fix the
vmalloc problem and additionally, we can also use the new per-thread
gfp_mask API to have a much better guarantee that our I/O threads never
allocate memory with __GFP_IO.

Please let me know what you think.

Thanks,
Ricardo


--=-fPygR0hXtWKoZOc1864v
Content-Disposition: attachment; filename*0=0001-Fix-__vmalloc-to-always-respect-the-gfp-flags-that-t.pat; filename*1=ch
Content-Type: text/x-patch; name="0001-Fix-__vmalloc-to-always-respect-the-gfp-flags-that-t.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit


--=-fPygR0hXtWKoZOc1864v--
