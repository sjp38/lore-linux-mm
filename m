Date: Wed, 9 Jan 2008 23:33:40 +0100
From: Jakob Oestergaard <jakob@unthought.net>
Subject: Re: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in msync()
Message-ID: <20080109223340.GH25527@unthought.net>
References: <1199728459.26463.11.camel@codedot> <20080109155015.4d2d4c1d@cuia.boston.redhat.com> <26932.1199912777@turing-police.cc.vt.edu> <20080109170633.292644dc@cuia.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080109170633.292644dc@cuia.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Valdis.Kletnieks@vt.edu, Anton Salikhmetov <salikhmetov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 09, 2008 at 05:06:33PM -0500, Rik van Riel wrote:
...
> > 
> > Lather, rinse, repeat....

Just verified this at one customer site; they had a db that was last backed up
in 2003 :/

> 
> On the other hand, updating the mtime and ctime whenever a page is dirtied
> also does not work right.  Apparently that can break mutt.
> 

Thinking back on the atime discussion, I bet there would be some performance
problems in updating the ctime/mtime that often too :)

> Calling msync() every once in a while with Anton's patch does not look like a
> fool proof method to me either, because the VM can write all the dirty pages
> to disk by itself, leaving nothing for msync() to detect.  (I think...)

Reading the man page:
"The st_ctime and st_mtime fields of a file that is mapped with MAP_SHARED and
PROT_WRITE will be marked for update at some point in the interval between a
write reference to the mapped region and the next call to  msync() with
MS_ASYNC or MS_SYNC for that portion of the file by any process. If there is no
such call, these fields may be marked for update at any time after a write
reference if the underlying file is modified as a result."

So, whenever someone writes in the region, this must cause us to update the
mtime/ctime no later than at the time of the next call to msync().

Could one do something like the lazy atime updates, coupled with a forced flush
at msync()?

> Can we get by with simply updating the ctime and mtime every time msync()
> is called, regardless of whether or not the mmaped pages were still dirty
> by the time we called msync() ?

The update must still happen, eventually, after a write to the mapped region
followed by an unmap/close even if no msync is ever called.

The msync only serves as a "no later than" deadline. The write to the region
triggers the need for the update.

At least this is how I read the standard - please feel free to correct me if I
am mistaken.

-- 

 / jakob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
