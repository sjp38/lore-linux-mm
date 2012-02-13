Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 3966F6B13F0
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 13:00:34 -0500 (EST)
Date: Mon, 13 Feb 2012 19:00:26 +0100
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v5 3/3] fadvise: implement POSIX_FADV_NOREUSE
Message-ID: <20120213180026.GA12111@thinkpad>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
 <1329006098-5454-4-git-send-email-andrea@betterlinux.com>
 <CAHGf_=qs8-nE6y6EzNYUzgjGo0sMP5zvCc3=GNZmHct6mPecqg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHGf_=qs8-nE6y6EzNYUzgjGo0sMP5zvCc3=GNZmHct6mPecqg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?iso-8859-1?Q?P=E1draig?= Brady <P@draigbrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Feb 13, 2012 at 11:22:26AM -0500, KOSAKI Motohiro wrote:
> > @@ -1181,8 +1258,22 @@ page_ok:
> >                 * When a sequential read accesses a page several times,
> >                 * only mark it as accessed the first time.
> >                 */
> > -               if (prev_index != index || offset != prev_offset)
> > -                       mark_page_accessed(page);
> > +               if (prev_index != index || offset != prev_offset) {
> > +                       int mode;
> > +
> > +                       mode = filemap_get_cache(mapping, index);
> > +                       switch (mode) {
> > +                       case FILEMAP_CACHE_NORMAL:
> > +                               mark_page_accessed(page);
> > +                               break;
> > +                       case FILEMAP_CACHE_ONCE:
> > +                               mark_page_usedonce(page);
> > +                               break;
> > +                       default:
> > +                               WARN_ON_ONCE(1);
> > +                               break;
> 
> Here is generic_file_read, right? Why don't you care write and page fault?

That's correct. I focused in my read test case and have not consider
write and page fault at all yet. There's also another missing piece
probably: readahead.

About generic_file_read the behavior that we may want to provide looks
quite clear to me. Instead, I don't know which is the best behavior for
the NOREUSE writes... should we just avoid active lru list eligibility,
or also drop the pages after the write if they weren't present in page
cache before the write? In the former NOREUSE pages can still trash
pages in the inactive lru list, in the latter writes will be slow
because we need to wait for the writeback. Ideas/suggestions?

About readahead pages I think we shouldn't touch anything. IIUC, when
readahead pages are loaded in page cache for the first time they are
added to the inactive lru list and not marked as referenced.

If the readahead pages are also referenced by the application and
they're inside a NOREUSE range they won't be marked as referenced and
will continue to live in the inactive list (and dropped when the
inactive list is shrunk). If readahead pages are not inside a NOREUSE
range they will be treated as usual (marked as referenced, and moved to
the active list if they're accessed more than once).

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
