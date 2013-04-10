Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 7AEBF6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 22:48:52 -0400 (EDT)
Date: Wed, 10 Apr 2013 11:48:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 0/4] Support vranges on files
Message-ID: <20130410024848.GA21292@blaptop>
References: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
 <20130404065509.GE7675@blaptop>
 <515DBA70.8010606@linaro.org>
 <20130405075504.GA32126@blaptop>
 <20130408004638.GA6394@blaptop>
 <5163629A.4070202@linaro.org>
 <20130409021801.GD3467@blaptop>
 <51638AB6.6000803@linaro.org>
 <20130409050742.GB6836@blaptop>
 <516497E4.1000001@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <516497E4.1000001@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Apr 09, 2013 at 03:36:20PM -0700, John Stultz wrote:
> On 04/08/2013 10:07 PM, Minchan Kim wrote:
> >On Mon, Apr 08, 2013 at 08:27:50PM -0700, John Stultz wrote:
> >>marked volatile, it should remain volatile until someone who has the
> >>file open marks it as non-volatile.  The only time we clear the
> >>volatility is when the file is closed by all users.
> >Yes. We need it that clear volatile ranges when the file is closed
> >by ball users. That's what we need and blow my concern out.
> 
> Ok, sorry this wasn't more clear. In all the implementations I've
> pushed, the volatility only persists as long as someone holds the
> file open. Once its closed by all users, the volatility is cleared.

I now confirmed it with your implementation.
Sorry for the confusing without looking into your code in detail. :(

> 
> Hopefully that calms your worries here. :)

Yeb.

> 
> 
> 
> >>I think the concern about surprising an application that isn't
> >>expecting volatility is odd, since if an application jumped in and
> >>punched a hole in the data, that could surprise other applications
> >>as well.  If you're going to use a file that can be shared,
> >>applications have to deal with potential changes to that file by
> >>others.
> >True. My concern is delayed punching without any client of fd and
> >there is no interface to detect some range of file is volatile state or
> >not. It means anyone mapped a file with shared could encunter SIGBUS
> >although he try to best effort to check it with lsof before using.
> 
> I'll grant the SIGBUG semantics create the potential for stranger
> behavior then usual, but I think the use cases are still attractive
> enough to try to make it work.

Indeed.

> 
> 
> >>To me, the value in using volatile ranges on the file data is
> >>exactly because the file data can be shared. So it makes sense to me
> >>to have the volatility state be like the data in the file. I guess
> >>the only exception in my case is that if all the references to a
> >>file are closed, we can clear the volatility (since we don't have a
> >>sane way for the volatility to persist past that point).
> >Agree if you provide to clear out volatility when file are closed by
> >all stakeholder.
> 
> Agreed.
> 
> 
> >>One question that might help resolve this: Would having some sort of
> >>volatility checking interface be helpful in easing your concern
> >>about applications being surprised by volatility?
> >If we can provide above things, I think we don't need such interface
> >until someone want it with reasonable logic.
> 
> Sure, I just wanted to know if you saw a need right away. For now we
> can leave it be.
> 
> >>True. And performance needs to be good if this hinting interface is
> >>to be used easily. Although I worry about performance trumping sane
> >>semantics. So let me try to implement the desired behavior and we
> >>can measure the difference.
> >NP. But keep in mind that mmap_sem was really terrible for performance
> >when I took a expereiment(ie, concurrent page fault by many threads
> >while a thread calls mmap).
> >I guess primary reason is CONFIG_MUTEX_SPIN_ON_OWNER.
> >So at least, we should avoid it by introducing new mode like
> >VOLATILE_ANON|VOLATILE_FILE|VOLATILE_BOTH if we want to
> >support mvrange-file and mvragne interface was thing userland people
> >really want although ashmem have used fd-based model.
> 
> The VOLATILE_ANON|VOLATILE_FILE|VOLATILE_BOTH may be an interesting
> compromise.
> 
> Though, if one marks a VOLATILE_ANON range on an address that's an
> mmaped file, how do we detect this and provide a sane error value
> without checking the vmas?
> 

Should we check vma?
If there are conflict with existing vrange type, just return an -EINVAL?

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
