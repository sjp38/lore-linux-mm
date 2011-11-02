Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A41526B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 16:17:10 -0400 (EDT)
Date: Wed, 2 Nov 2011 21:17:07 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Latency writing to an mlocked ext4 mapping
Message-ID: <20111102201707.GD31575@quack.suse.cz>
References: <CALCETrU23vyCXPG6mJU9qaPeAGOWDQtur5C+LRT154V5FM=Ajg@mail.gmail.com>
 <CALCETrX=-CnNQ9+4tRbqMG4mfuy2FBPXXoJeBVDVPnEiRJYRFQ@mail.gmail.com>
 <CALCETrUcOKQAJTTmCSD3Q3wYS-zLqv6tBa4AdkK50bNobRhDUQ@mail.gmail.com>
 <20111025122618.GA8072@quack.suse.cz>
 <CALCETrWoZeFpznU5Nv=+PvL9QRkTnS4atiGXx0jqZP_E3TJPqw@mail.gmail.com>
 <20111031231031.GD10107@quack.suse.cz>
 <CALCETrViG6t1forOFtO-R=bGABvtLcECxJ8m8Tenv6rwxLg_ew@mail.gmail.com>
 <20111101230320.GH18701@quack.suse.cz>
 <CALCETrVKHyRtizmTs=4hZzOs+7JLnvv0WtkSLYLDmM0fs2ce-w@mail.gmail.com>
 <CALCETrWNCy0VN-rQM-xPksiJ50DW-KM+w2NBprNOPhvnizZW=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALCETrWNCy0VN-rQM-xPksiJ50DW-KM+w2NBprNOPhvnizZW=Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Jan Kara <jack@suse.cz>, Andreas Dilger <adilger@dilger.ca>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Tue 01-11-11 18:51:04, Andy Lutomirski wrote:
> On Tue, Nov 1, 2011 at 4:10 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> > On Tue, Nov 1, 2011 at 4:03 PM, Jan Kara <jack@suse.cz> wrote:
> >> Avoiding IO during a minor fault would be a decent thing which might be
> >> worth pursuing. As you properly noted "stable pages during writeback"
> >> requirement is one obstacle which won't be that trivial to avoid though...
> >
> > There's an easy solution that would be good enough for me: add a mount
> > option to turn off stable pages.
> >
> > Is the other problem just a race, perhaps?  __block_page_mkwrite calls
> > __block_write_begin (which calls get_block, which I think is where the
> > latency comes from) *before* wait_on_page_writeback, which means that
> > there might not be any space allocated yet.
> 
> I think I'm right (other than calling it a race).  If I change my code to do:
> 
> - map the file (with MCL_FUTURE set)
> - fallocate
> - dirty all pages
> - fsync
> - dirty all pages again
> 
> in the non-real-time thread, then a short test that was a mediocre
> reproducer seems to work.
> 
> This is annoying, though -- I'm not generating twice as much write I/O
> as I used to.  Is there any way to force the delalloc code to do its
> thing without triggering writeback?  I don't think fallocate has this
> effect.
  fallocate() will preallocate blocks on disk backing the mapped page. That
should get rid of latency in __block_write_begin(). Extents will still be
marked as uninitialized, but conversion from uninitialized to initialized
state happens during writeback / IO completion so you should not care much
about it.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
