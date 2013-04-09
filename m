Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 81CF66B0036
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 01:07:45 -0400 (EDT)
Date: Tue, 9 Apr 2013 14:07:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 0/4] Support vranges on files
Message-ID: <20130409050742.GB6836@blaptop>
References: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
 <20130404065509.GE7675@blaptop>
 <515DBA70.8010606@linaro.org>
 <20130405075504.GA32126@blaptop>
 <20130408004638.GA6394@blaptop>
 <5163629A.4070202@linaro.org>
 <20130409021801.GD3467@blaptop>
 <51638AB6.6000803@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <51638AB6.6000803@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Apr 08, 2013 at 08:27:50PM -0700, John Stultz wrote:
> On 04/08/2013 07:18 PM, Minchan Kim wrote:
> >On Mon, Apr 08, 2013 at 05:36:42PM -0700, John Stultz wrote:
> >>On 04/07/2013 05:46 PM, Minchan Kim wrote:
> >>>Hello John,
> >>>
> >>>As you know, userland people wanted to handle vrange with mmaped
> >>>pointer rather than fd-based and see the SIGBUS so I thought more
> >>>about semantic of vrange and want to make it very clear and easy.
> >>>So I suggest below semantic(Of course, it's not rock solid).
> >>>
> >>>         mvrange(start_addr, lengh, mode, behavior)
> >>>
> >>>It's same with that I suggested lately but different name, just
> >>>adding prefix "m". It's per-process model(ie, mm_struct vrange)
> >>>so if process is exited, "volatility" isn't valid any more.
> >>>It isn't a problem in anonymous but could be in file-vrange so let's
> >>>introduce fvrange for covering the problem.
> >>>
> >>>         fvrange(int fd, start_offset, length, mode, behavior)
> >>>
> >>>First of all, let's see mvrange with anonymous and file page POV.
> >>>
> >>>1) anon-mvrange
> >>>
> >>>The page in volaitle range will be purged only if all of processes
> >>>marked the range as volatile.
> >>>
> >>>If A process calls mvrange and is forked, vrange could be copied
> >>>from parent to child so not-yet-COWed pages could be purged
> >>>unless either one of both processes marks NO_VOLATILE explicitly.
> >>>
> >>>Of course, COWed page could be purged easily because there is no link
> >>>any more.
> >>Ack. This seems reasonable.
> >>
> >>
> >>>2) file-mvrange
> >>>
> >>>A page in volatile range will be purged only if all of processes mapped
> >>>the page marked it as volatile AND there is no process mapped the page
> >>>as "private". IOW, all of the process mapped the page should map it
> >>>with "shared" for purging.
> >>>
> >>>So, all of processes should mark each address range in own process
> >>>context if they want to collaborate with shared mapped file and gaurantee
> >>>there is no process mapped the range with "private".
> >>>
> >>>Of course, volatility state will be terminated as the process is gone.
> >>This case doesn't seem ideal to me, but is sort of how the current
> >>code works to avoid the complexity of dealing with memory volatile
> >>ranges that cross page types (file/anonymous). Although the current
> >>code just doesn't purge file pages marked with mvrange().
> >Personally, I don't think it's to avoid the complexity of implemenation.
> >I thought explict declaration volatility on range before using would be
> >more clear for userspace programmer.
> >Otherwise, he can encounter SIGBUS and got confused easily.
> >
> >Frankly speaking, I don't like to remain volatility permanently although
> >relavant processes go away and it could make processs using the file
> >much error-prone and hard to debug it.
> 
> So this is maybe is a contentious point we'll have to work out.
> 
> Maybe could you describe some use cases you envision where someone
> would want to mark pages volatile on a file that could be
> accidentally shared? Or how you think the per-mm sense of volatility
> would be beneficial in those use-cases?

My concern point is that following as

1. Process A calls mvrange for file F.
2. Process A is killed by someone or own BUG
3. Process B maps F with shared in his address space
4. Memory pressure happens
5. Process B is killed by SIGBUS but Process B really can't know why he
   was killed because he can't know anyone who open F except himself.
> 
> The use cases I envision where volatility would be used are when any
> sharing would be coordinated between processes.
> Again, that producer/consumer example from before where the empty
> portion of a very large circular buffer could be made volatile,
> scaling the actual memory usage to the actual need.
> 
> And really the same concern would likely apply in the common case
> when multiple applications mmap (shared) a file, but use fvrange()
> to mark the data as volatile. This is exactly the use case the
> Android ashmem interface works for. In that case, once the data is

I don't know Android ashmem interface well but if it works as I
mentioned early, I think it's not good interface.

> marked volatile, it should remain volatile until someone who has the
> file open marks it as non-volatile.  The only time we clear the
> volatility is when the file is closed by all users.

Yes. We need it that clear volatile ranges when the file is closed
by ball users. That's what we need and blow my concern out.

> 
> I think the concern about surprising an application that isn't
> expecting volatility is odd, since if an application jumped in and
> punched a hole in the data, that could surprise other applications
> as well.  If you're going to use a file that can be shared,
> applications have to deal with potential changes to that file by
> others.

True. My concern is delayed punching without any client of fd and
there is no interface to detect some range of file is volatile state or
not. It means anyone mapped a file with shared could encunter SIGBUS
although he try to best effort to check it with lsof before using.

> 
> To me, the value in using volatile ranges on the file data is
> exactly because the file data can be shared. So it makes sense to me
> to have the volatility state be like the data in the file. I guess
> the only exception in my case is that if all the references to a
> file are closed, we can clear the volatility (since we don't have a
> sane way for the volatility to persist past that point).

Agree if you provide to clear out volatility when file are closed by
all stakeholder.

> 
> One question that might help resolve this: Would having some sort of
> volatility checking interface be helpful in easing your concern
> about applications being surprised by volatility?

If we can provide above things, I think we don't need such interface
until someone want it with reasonable logic.

> 
> 
> >Anyway, do you agree my suggestion that "we should not purge any page if
> >a process are using now with non-shared(ie, private)"?
> 
> Yes, or if we do purge any pages, they should not affect the private
> mapped pages (in other words, the COW link should be broken - as the
> backing page has in-effect been written to by purging).
> 
> 
> >>I'd much prefer file-mvrange calls to behave identically to fvrange calls.
> >>
> >>The important point here is that the kernel doesn't *have* to purge
> >>anything ever. Its the kernel's discretion as to which volatile
> >>pages to purge when. So its easier for now to simply not purge file
> >Right.
> >
> >>pages marked volatile via mvolatile.
> >NP but we should write down vague description. User try to use it
> >in file-backed pages and got disappointed, then is reluctant to use it
> >any more. :)
> >
> >I'm not saying that let's write down description implementation specific
> >but want to say them at least new system call can affect anonymous or file
> >or both, at least from the beginning. Just hope.
> 
> I'd like to make it generic enough that we have some flexibility to
> modify the puring rules if we find its more optimal. But I agree,
> the desired semantics of what could occur should be clear.
> 
> 
> >>There however is the inconsistency that file pages marked volatile
> >>via fvrange, then are marked non-volatile via mvrange() might still
> >>be purged. That is broken in my mind, and still needs to be
> >>addressed. The easiest out is probably just to return an error if
> >>any of the mvrange calls cover file pages. But I'd really like a
> >It needs vma enumeration and mmap_sem read-lock.
> >It could hurt anon-vrange performance severely.
> 
> True. And performance needs to be good if this hinting interface is
> to be used easily. Although I worry about performance trumping sane
> semantics. So let me try to implement the desired behavior and we
> can measure the difference.

NP. But keep in mind that mmap_sem was really terrible for performance
when I took a expereiment(ie, concurrent page fault by many threads
while a thread calls mmap).
I guess primary reason is CONFIG_MUTEX_SPIN_ON_OWNER.
So at least, we should avoid it by introducing new mode like
VOLATILE_ANON|VOLATILE_FILE|VOLATILE_BOTH if we want to
support mvrange-file and mvragne interface was thing userland people
really want although ashmem have used fd-based model.

Thanks.

> 
> 
> >>better fix.
> >Another idea is that we can move per-mm vrange element to address_space
> >when the process goes away if the element covers file-backd vma.
> >But I'm still very not sure whether we should keep it persistent.
> 
> I really think the persistence of file-backed volatile ranges (as
> long as someone has the file open or a mapping to it) is important.
> Again, I think of the volatility really being a state of the page,
> but since a page-based approach is too costly, we're optimizing it
> into mm_struct state or address_space state.
> 
> thanks
> -john
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
