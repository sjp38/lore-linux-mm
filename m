Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0CFC56B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 12:06:20 -0400 (EDT)
Received: by pzk6 with SMTP id 6so709147pzk.1
        for <linux-mm@kvack.org>; Fri, 04 Jun 2010 09:06:13 -0700 (PDT)
Date: Sat, 5 Jun 2010 01:06:01 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH V2 3/7] Cleancache (was Transcendent Memory): VFS hooks
Message-ID: <20100604160601.GE1879@barrios-desktop>
References: <20100528173610.GA12270@ca-server1.us.oracle.com20100604132948.GC1879@barrios-desktop>
 <16b4dcd5-95d8-4cb0-885d-0189ef90c02b@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16b4dcd5-95d8-4cb0-885d-0189ef90c02b@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

On Fri, Jun 04, 2010 at 08:13:14AM -0700, Dan Magenheimer wrote:
> > 1)
> > You mentiond PFRA in you description and I understood cleancache has
> > a cold clean page which is evicted by reclaimer.
> > But __remove_from_page_cache can be called by other call sites.
> > 
> > For example, shmem_write page calls it for moving the page from page
> > cache
> > to swap cache. Although there isn't the page in page cache, it is in
> > swap cache.
> > So next read/write of shmem until swapout happens can be read/write in
> > swap cache.
> > 
> > I didn't looked into whole of callsites. But please review again them.
> 
> I think the "if (PageUptodate(page))" eliminates all the cases
> where bad things can happen.

I missed it. my fisrt concern has gone. :)

> 
> Note that there may be cases where some unnecessary puts/flushes
> occur.  The focus of the patch is on correctness first; it may
> be possible to increase performance (marginally) in the future by
> reducing unnecessary cases.

I think it wouldn't be marginally. It depends on implementation
of backend. 
I think frontend would be better to notify to backend in 
only exact place. As your descrption, we can call it in shrink_page_list
with some check or change __remove_mapping which adding a argument to tell
"this is calling of reclaim path". 

> 
> > 3) Please consider system memory pressure.
> > And I hope Nitin consider this, too.
> 
> This is definitely very important but remember that cleancache
> provides a great deal of flexibility:  Any page in cleancache
> can be thrown away at any time as every page is clean!  It
> can even accept a page and throw it away immediately.  Clearly
> the backend needs to do this intelligently so this will
> take some policy work.

I admit design goal of cleancache is to give a greate deal of flexibility. 
But I think system memory pressure(ie, direct reclaim and even OOM) is 
exceptional. Whenever we implement various backend, every backend(non-virtual
environemnt)have to implement policy which deal with system memory 
pressure emergency to prevent system hang, I think. 

And backend might need some hack to know the situation. It's horrible.
So I hope frontend gives little information to backend, at least. 

If some backend don't need it, it can just ignore. 
But if some backend need it, it can be a big deal. :)

> 
> Since I saw you sent a separate response to Nitin, I'll
> let him answer for his in-kernel page cache compression
> work.  The solution to the similar problem for Xen is
> described in the tmem internals document that I think
> I pointed to earlier here:
> http://oss.oracle.com/projects/tmem/documentation/internals/ 

I will read it when I have a time. 
Thanks for quick reply but I can't. 
It's time to sleep and weekend. 
See you soon and have a nice weekend. 

> 
> Thanks,
> Dan
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
