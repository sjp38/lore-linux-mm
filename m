Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id C98FD6B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 05:18:40 -0400 (EDT)
Date: Wed, 2 May 2012 11:18:37 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned
 buffers
Message-ID: <20120502091837.GC16976@quack.suse.cz>
References: <1335778207-6511-1-git-send-email-jack@suse.cz>
 <CAHGf_=qdE3yNw=htuRssfav2pECO1Q0+gWMRTuNROd_3tVrd6Q@mail.gmail.com>
 <CAHGf_=ojhwPUWJR0r+jVgjNd5h_sRrppzJntSpHzxyv+OuBueg@mail.gmail.com>
 <x49ehr4lyw1.fsf@segfault.boston.devel.redhat.com>
 <CAHGf_=rzcfo3OnwT-YsW2iZLchHs3eBKncobvbhTm7B5PE=L-w@mail.gmail.com>
 <x491un3nc7a.fsf@segfault.boston.devel.redhat.com>
 <CAPa8GCCgLUt1EDAy7-O-mo0qir6Bf5Pi3Va1EsQ3ZW5UU=+37g@mail.gmail.com>
 <20120502081705.GB16976@quack.suse.cz>
 <CAPa8GCCnvvaj0Do7sdrdfsvbcAf0zBe3ssXn45gMfDKCcvJWxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPa8GCCnvvaj0Do7sdrdfsvbcAf0zBe3ssXn45gMfDKCcvJWxA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Jeff Moyer <jmoyer@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Andrea Arcangeli <aarcange@redhat.com>, Woodman <lwoodman@redhat.com>

On Wed 02-05-12 19:09:54, Nick Piggin wrote:
> On 2 May 2012 18:17, Jan Kara <jack@suse.cz> wrote:
> > On Wed 02-05-12 01:50:46, Nick Piggin wrote:
> 
> >> KOSAKI-san is correct, I think.
> >>
> >> The race is something like this:
> >>
> >> DIO-read
> >>     page = get_user_pages()
> >>                                                         fork()
> >>                                                             COW(page)
> >>                                                          touch(page)
> >>     DMA(page)
> >>     page_cache_release(page);
> >>
> >> So whether parent or child touches the page, determines who gets the
> >> actual DMA target, and who gets the copy.
> >  OK, this is roughly what I understood from original threads as well. So
> > if our buffer is page aligned and its size is page aligned, you would hit
> > the corruption only if you do modify the buffer while IO to / from that buffer
> > is in progress. And that would seem like a really bad programming practice
> > anyway. So I still believe that having everything page size aligned will
> > effectively remove the problem although I agree it does not aim at the core
> > of it.
> 
> I see what you mean.
> 
> I'm not sure, though. For most apps it's bad practice I think. If you get into
> realm of sophisticated, performance critical IO/storage managers, it would
> not surprise me if such concurrent buffer modifications could be allowed.
> We allow exactly such a thing in our pagecache layer. Although probably
> those would be using shared mmaps for their buffer cache.
> 
> I think it is safest to make a default policy of asking for IOs against private
> cow-able mappings to be quiesced before fork, so there are no surprises
> or reliance on COW details in the mm. Do you think?
  Yes, I agree that (and MADV_DONTFORK) is probably the best thing to have
in documentation. Otherwise it's a bit too hairy...

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
