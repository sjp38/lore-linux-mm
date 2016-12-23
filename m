Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 803006B036C
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 17:46:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 5so55160010pgj.6
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 14:46:46 -0800 (PST)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id 12si35380827pfi.251.2016.12.23.14.46.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Dec 2016 14:46:45 -0800 (PST)
Received: by mail-pg0-x231.google.com with SMTP id y62so61310023pgy.1
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 14:46:45 -0800 (PST)
Date: Fri, 23 Dec 2016 14:46:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
In-Reply-To: <20161223111817.GC23109@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1612231428030.88276@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com> <20161222100009.GA6055@dhcp22.suse.cz> <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com> <20161223085150.GA23109@dhcp22.suse.cz> <alpine.DEB.2.10.1612230154450.88514@chino.kir.corp.google.com>
 <20161223111817.GC23109@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 23 Dec 2016, Michal Hocko wrote:

> > We have no way to compact memory for users who are not using 
> > MADV_HUGEPAGE,
> 
> yes we have. it is defrag=always. If you do not want direct compaction
> and the resulting allocation stalls then you have to rely on kcompactd
> which is something we should work longterm.
> 

No, the point of madvise(MADV_HUGEPAGE) is for applications to tell the 
kernel that they really want hugepages.  Really.  Everybody else either 
never did direct compaction or did a substantially watered down version of 
it.  Now, we have a situation where you can either do direct compaction 
for MADV_HUGEPAGE and nothing for anybody else, or direct compaction for 
everybody.  In our usecase, we want everybody to kick off background 
compaction because order=9 gfp_mask & __GFP_KSWAPD_RECLAIM is the only 
thing that is going to trigger background compaction but are unable to do 
so without still incurring lengthy pagefaults for non MADV_HUGEPAGE users.

> > which is some customers, others require MADV_HUGEPAGE for 
> > .text segment remap while loading their binary, without defrag=always or 
> > defrag=defer.  The problem is that we want to demand direct compact for 
> > MADV_HUGEPAGE: they _really_ want hugepages, it's the point of the 
> > madvise.
> 
> and that is the point of defrag=madvise to give them this direct
> compaction.
> 

Do you see the problem by first suggesting defrag=always at the top of 
your reply and then defrag=madvise now?  We cannot set both at once, it's 
the entire problem with the tristate and now quadstate setting.  We want a 
combination: EVERYBODY kicks off background compaction and applications 
that really want hugepages and are fine with incuring lengthy page fault, 
such as those (for the third time) remapping .text segment and doing 
madvise(MADV_HUGEPAGE) before fault, can use the madvise.

> > We have no setting, without this patch, to ask for background 
> > compaction for everybody so that their fault does not have long latency 
> > and for some customers to demand compaction.
> 
> that is true and what I am trying to say is that we should aim to give
> this background compaction for everybody via kcompactd because there are
> more users than THP who might benefit from low latency high order pages
> availability. 

My patch does that, we _defer_ for everybody unless you're using 
madvise(MADV_HUGEPAGE) and really want hugepages.  Forget defrag=never 
exists, it's not important in the discussion.  Forget defrag=always exists 
because all apps, like batch jobs, don't want lengthy pagefaults.  We have 
two options remaining:

 - defrag=defer: everybody kicks off background compaction, _nobody_ does
   direct compaction

 - defrag=madvise: madvise(MADV_HUGEPAGE) does direct compaction,
   everybody else does nothing

The point you're missing is that we _want_ defrag=defer.  We really do.  
We don't want to stall in the page allocator to get thp, but we want to 
try to make it available in the short term.  However, apps that do 
madvise(MADV_HUGEPAGE), like remapping your .text segment and wanting your 
text backed by hugepages and incurring the expense up front, or a 
database, or a vm, _want_ hugepages now and don't care about lengthy page 
faults.

The point is that I HAVE NO SETTING to get that behavior and 
defrag=madvise is _not_ a solution because it requires the presence of an 
app that is doing madvise(MADV_HUGEPAGE) AND faulting memory to get any 
order=9 compaction.

> > ?????? Why does the admin care if a user's page fault wants to reclaim to 
> > get high order memory?
> 
> Because the whole point of the defrag knob is to allow _administrator_
> control how much we try to fault in THP. And the primary motivation were
> latencies. The whole point of introducing defer option was to _never_
> stall in the page fault while it still allows to kick the background
> compaction. If you really want to tweak any option then madvise would be
> more appropriate IMHO because the semantic would be still clear. Use
> direct compaction for MADV_HUGEPAGE vmas and kick in kswapd/kcompactd
> for others.
> 

You want defrag=madvise to start doing background compaction for 
everybody, which was never done before for existing users of 
defrag=madvise?  That might be possible, I don't really care, I just think 
it's riskier because there are existing users of defrag=madvise who are 
opting in to new behavior because of the kernel change.  This patch 
changes defrag=defer because it's the new option and people setting the 
mode know what they are getting.

I disagree with your description of what the defrag setting is intended 
for.  The setting of thp defrag is to optimize for apps that truly want 
transparent behavior, i.e. they aren't doing madvise(MADV_HUGEPAGE).  Are 
they willing to incur lengthy pagefaults for thp when not doing any 
madvise(2)?  defrag=defer should not mean that users of 
madvise(MADV_HUGEPAGE) that have clearly specified their intent should not 
be allowed to try compacting memory themselves because they have indicated 
they are fine with such an expense by doing the madvise(2).

This is obviously fine for Kirill, and I have users who remap their .text 
segment and do madvise(MADV_DONTNEED) because they really want hugepages 
when they are exec'd, so I'd kindly ask you to consider the real-world use 
cases that require background compaction to make hugepages available for 
everybody but allow apps to opt-in to take the expense of compaction on 
themselves rather than your own theory of what users want.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
