Date: Wed, 9 Jan 2008 17:06:33 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in
 msync()
Message-ID: <20080109170633.292644dc@cuia.boston.redhat.com>
In-Reply-To: <26932.1199912777@turing-police.cc.vt.edu>
References: <1199728459.26463.11.camel@codedot>
	<20080109155015.4d2d4c1d@cuia.boston.redhat.com>
	<26932.1199912777@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Anton Salikhmetov <salikhmetov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 09 Jan 2008 16:06:17 -0500
Valdis.Kletnieks@vt.edu wrote:
> On Wed, 09 Jan 2008 15:50:15 EST, Rik van Riel said:
> 
> > Could you explain (using short words and simple sentences) what the
> > exact problem is?
> 
> It's like this:
> 
> Monday  9:04AM:  System boots, database server starts up, mmaps file
> Monday  9:06AM:  Database server writes to mmap area, updates mtime/ctime
> Monday <many times> Database server writes to mmap area, no further update..
> Monday 11:45PM:  Backup sees "file modified 9:06AM, let's back it up"
> Tuesday 9:00AM-5:00PM: Database server touches it another 5,398 times, no mtime
> Tuesday 11:45PM: Backup sees "file modified back on Monday, we backed this up..
> Wed  9:00AM-5:00PM: More updates, more not touching the mtime
> Wed  11:45PM: *yawn* It hasn't been touched in 2 days, no sense in backing it up..
> 
> Lather, rinse, repeat....

On the other hand, updating the mtime and ctime whenever a page is dirtied
also does not work right.  Apparently that can break mutt.

Calling msync() every once in a while with Anton's patch does not look like a
fool proof method to me either, because the VM can write all the dirty pages
to disk by itself, leaving nothing for msync() to detect.  (I think...)

Can we get by with simply updating the ctime and mtime every time msync()
is called, regardless of whether or not the mmaped pages were still dirty
by the time we called msync() ?

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
