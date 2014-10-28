Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7F3900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 12:08:18 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id le20so539953vcb.4
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 09:08:17 -0700 (PDT)
Received: from mail.mandriva.com.br (mail.mandriva.com.br. [177.220.134.171])
        by mx.google.com with ESMTP id az6si999774vdd.39.2014.10.28.09.08.16
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 09:08:16 -0700 (PDT)
Date: Tue, 28 Oct 2014 14:08:12 -0200
From: Marco A Benatto <marco.benatto@mandriva.com.br>
Subject: Re: UKSM: What's maintainers think about it?
Message-ID: <20141028160812.GB1445@sirus.conectiva>
References: <CAGqmi77uR2Nems6fE_XM1t3a06OwuqJP-0yOMOQh7KH13vzdzw@mail.gmail.com>
 <20141025213201.005762f9.akpm@linux-foundation.org>
 <20141028133131.GA1445@sirus.conectiva>
 <CAGqmi76b0oUMAsAvBt=PwaxF5JZXcckSdWe2=bL_pXaiUFFCXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGqmi76b0oUMAsAvBt=PwaxF5JZXcckSdWe2=bL_pXaiUFFCXQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Oct 28, 2014 at 04:59:45PM +0300, Timofey Titovets wrote:
> 2014-10-28 16:31 GMT+03:00 Marco A Benatto <marco.benatto@mandriva.com.br>:
> > Hi All,
> >
> > I'm not mantainer at all, but I've being using UKSM for a long time and remember
> > to port it to 3.16 family once.
> > UKSM seems good and stable and, at least for me, doesn't raised any errors.
> > AFAIK the only limitation I know (maybe I has been fixed already) it isn't able
> > to work together with zram stuff due to some race-conditions.
> >
> > Cheers,
> >
> > Marco A Benatto
> > Mandriva OEM Developer
> >
> 
> http://kerneldedup.org/forum/forum.php?mod=viewthread&tid=106
> As i did find, uksm not conflicting with zram (or zswap - on my system).

Interesting,

I've contacted the mantainers to send some patches in April and they said me this:

"The biggest problem between UKSM/KSM and zswap is that pages can be reclaimed so
fast by zswap before UKSM/KSM can have a chance to merge those can be merged.

So one of the ideas that make a direct solution is that:
1. sleep the processes who trigger the zswap
2. wake up the UKSM thread and adjust the scan parameters properly to make it
sample the whole memory in a limited time to judge if there are any VMAs need to
be worked on.
3. If there are those VMAs then merge them at full speed. if there not,
sleep UKSM.
4. Wake up the zswap code pathes and judge that if memory is enough to satisfy
the requests. If there is enough memory then return and redo the memory
allocation.
5. if there is not, then go on to do zswapping.

This is just an outline of ONE of the solutions. It need to be carefully
tweaked. Direct page reclaiming of zswap is a time sensitive code path
, we cannot add too much overhead by doing this,
otherwise it loses its meaning."
 
> ---
> Offtop:
> Why i open up question about UKSM?
> 
> May be we (as community, who want to help) can split out UKSM in
> "several patches" in independent git repo. For allowing maintainers to
> review this.
> 
> Is it morally correct?
> 
> UKSM code licensed under GPL and as i think we can feel free for port
> and adopt code (with indicating the author)
> 
> Please, fix me if i mistake or miss something.
> This is just stream of my thoughts %_%

If there's no problem in do this, and if you don't mind, you can help you
out on this.

Cheers,

> ---
> 
> > On Sat, Oct 25, 2014 at 09:32:01PM -0700, Andrew Morton wrote:
> >> On Sat, 25 Oct 2014 22:25:56 +0300 Timofey Titovets <nefelim4ag@gmail.com> wrote:
> >>
> >> > Good time of day, people.
> >> > I try to find 'mm' subsystem specific people and lists, but list
> >> > linux-mm looks dead and mail archive look like deprecated.
> >> > If i must to sent this message to another list or add CC people, let me know.
> >>
> >> linux-mm@kvack.org is alive and well.
> 
> So cool, thanks for adding 'mm' to CC.
> 
> >> > If questions are already asked (i can't find activity before), feel
> >> > free to kick me.
> >> >
> >> > The main questions:
> >> > 1. Somebody test it? I see many reviews about it.
> >> > I already port it to latest linux-next-git kernel and its work without issues.
> >> > http://pastebin.com/6FMuKagS
> >> > (if it matter, i can describe use cases and results, if somebody ask it)
> >> >
> >> > 2. Developers of UKSM already tried to merge it? Somebody talked with uksm devs?
> >> > offtop: now i try to communicate with dev's on kerneldedup.org forum,
> >> > but i have problems with email verification and wait admin
> >> > registration approval.
> >> > (i already sent questions to
> >> > http://kerneldedup.org/forum/home.php?mod=space&username=xianai ,
> >> > because him looks like team leader)
> >> >
> >> > 3. I just want collect feedbacks from linux maintainers team, if you
> >> > decide what UKSM not needed in kernel, all other comments (as i
> >> > understand) not matter.
> >> >
> >> > Like KSM, but better.
> >> > UKSM - Ultra Kernel Samepage Merging
> >> > http://kerneldedup.org/en/projects/uksm/introduction/
> >>
> >> It's the first I've heard of it.  No, as far as I know there has been
> >> no attempt to upstream UKSM.
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Have a nice day,
> Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
