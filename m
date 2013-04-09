Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id EEE3A6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 22:18:05 -0400 (EDT)
Date: Tue, 9 Apr 2013 11:18:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 0/4] Support vranges on files
Message-ID: <20130409021801.GD3467@blaptop>
References: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
 <20130404065509.GE7675@blaptop>
 <515DBA70.8010606@linaro.org>
 <20130405075504.GA32126@blaptop>
 <20130408004638.GA6394@blaptop>
 <5163629A.4070202@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5163629A.4070202@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Apr 08, 2013 at 05:36:42PM -0700, John Stultz wrote:
> On 04/07/2013 05:46 PM, Minchan Kim wrote:
> >Hello John,
> >
> >As you know, userland people wanted to handle vrange with mmaped
> >pointer rather than fd-based and see the SIGBUS so I thought more
> >about semantic of vrange and want to make it very clear and easy.
> >So I suggest below semantic(Of course, it's not rock solid).
> >
> >         mvrange(start_addr, lengh, mode, behavior)
> >
> >It's same with that I suggested lately but different name, just
> >adding prefix "m". It's per-process model(ie, mm_struct vrange)
> >so if process is exited, "volatility" isn't valid any more.
> >It isn't a problem in anonymous but could be in file-vrange so let's
> >introduce fvrange for covering the problem.
> >
> >         fvrange(int fd, start_offset, length, mode, behavior)
> >
> >First of all, let's see mvrange with anonymous and file page POV.
> >
> >1) anon-mvrange
> >
> >The page in volaitle range will be purged only if all of processes
> >marked the range as volatile.
> >
> >If A process calls mvrange and is forked, vrange could be copied
> >from parent to child so not-yet-COWed pages could be purged
> >unless either one of both processes marks NO_VOLATILE explicitly.
> >
> >Of course, COWed page could be purged easily because there is no link
> >any more.
> 
> Ack. This seems reasonable.
> 
> 
> >2) file-mvrange
> >
> >A page in volatile range will be purged only if all of processes mapped
> >the page marked it as volatile AND there is no process mapped the page
> >as "private". IOW, all of the process mapped the page should map it
> >with "shared" for purging.
> >
> >So, all of processes should mark each address range in own process
> >context if they want to collaborate with shared mapped file and gaurantee
> >there is no process mapped the range with "private".
> >
> >Of course, volatility state will be terminated as the process is gone.
> 
> This case doesn't seem ideal to me, but is sort of how the current
> code works to avoid the complexity of dealing with memory volatile
> ranges that cross page types (file/anonymous). Although the current
> code just doesn't purge file pages marked with mvrange().

Personally, I don't think it's to avoid the complexity of implemenation.
I thought explict declaration volatility on range before using would be
more clear for userspace programmer.
Otherwise, he can encounter SIGBUS and got confused easily.

Frankly speaking, I don't like to remain volatility permanently although
relavant processes go away and it could make processs using the file
much error-prone and hard to debug it.

Anyway, do you agree my suggestion that "we should not purge any page if
a process are using now with non-shared(ie, private)"?

> 
> I'd much prefer file-mvrange calls to behave identically to fvrange calls.
> 
> The important point here is that the kernel doesn't *have* to purge
> anything ever. Its the kernel's discretion as to which volatile
> pages to purge when. So its easier for now to simply not purge file

Right.

> pages marked volatile via mvolatile.

NP but we should write down vague description. User try to use it
in file-backed pages and got disappointed, then is reluctant to use it
any more. :)

I'm not saying that let's write down description implementation specific
but want to say them at least new system call can affect anonymous or file
or both, at least from the beginning. Just hope.

> 
> There however is the inconsistency that file pages marked volatile
> via fvrange, then are marked non-volatile via mvrange() might still
> be purged. That is broken in my mind, and still needs to be
> addressed. The easiest out is probably just to return an error if
> any of the mvrange calls cover file pages. But I'd really like a

It needs vma enumeration and mmap_sem read-lock.
It could hurt anon-vrange performance severely.

> better fix.

Another idea is that we can move per-mm vrange element to address_space
when the process goes away if the element covers file-backd vma.
But I'm still very not sure whether we should keep it persistent.

> 
> 
> >3) fvrange
> >
> >It's same with 2) but volatility state could be persistent in address_space
> >until someone calls fvrange(NO_VOLATILE).
> >So it could remove the weakness of 2).
> >What do you think about above semantic?
> 
> 
> I'd still like mvrange() calls on shared mapped files to be stored
> on the address_space.
> 
> 
> >If you don't have any problem, we could implement it. I think 1) and 2) could
> >be handled with my base code for anon-vrange handling with tweaking
> >file-vrange and need your new patches in address_space for handling 3).
> 
> I think we can get it sorted out. It might just take a few iterations.

Sure!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
