Date: Thu, 1 Feb 2001 15:54:44 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] vma limited swapin readahead
In-Reply-To: <20010201182021.N1173@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.21.0102011552180.1321-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, David Gould <dg@suse.com>, "Eric W. Biederman" <ebiederm@xmission.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Feb 2001, Ingo Oeser wrote:
> On Thu, Feb 01, 2001 at 02:45:04PM -0200, Rik van Riel wrote:
> > One solution could be to put (most of) the swapin readahead
> > pages on the inactive_dirty list, so pressure by readahead
> > on the resident pages is smaller and the not used readahead
> > pages are reclaimed faster.
> 
> Shouldn't they be on inactive_clean anyway?

No, the inactive_clean pages are reclaimed before the
other inactive pages, and we want to give all pages
an equal chance to be used when we put them on the
inactive list.

This is especially true for freshly read in swap cache
pages, because we _expect_ that some of them will be
used.

> Or do I still not get the new linux mm design? ;-(

Read mm/swap.c::deactivate_page_nolock(), my decision to
put all clean inactive pages directly on inactive_clean
lead to the fact that dirty pages would stick around
forever and page reclaim could be quite unfair towards
clean pages. This was changed later to put all inactive
pages on the inactive_dirty list first and have them
more fairly reclaimed in page_launder.

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
