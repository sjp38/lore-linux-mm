Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id C98A46B0002
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 20:05:22 -0400 (EDT)
Received: by mail-da0-f52.google.com with SMTP id f10so378915dak.39
        for <linux-mm@kvack.org>; Fri, 29 Mar 2013 17:05:21 -0700 (PDT)
Message-ID: <51562C3D.3060809@linaro.org>
Date: Fri, 29 Mar 2013 17:05:17 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
References: <1363073915-25000-1-git-send-email-minchan@kernel.org> <514A6282.8020406@linaro.org> <20130322060113.GA4802@blaptop> <514C8FB0.4060105@linaro.org> <20130325084217.GC2348@blaptop> <51523C9C.1010806@linaro.org> <20130327080328.GE13897@blaptop>
In-Reply-To: <20130327080328.GE13897@blaptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Minchan Kim <minchan.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 03/27/2013 01:03 AM, Minchan Kim wrote:
> On Tue, Mar 26, 2013 at 05:26:04PM -0700, John Stultz wrote:
>> Sorting out how to handle vrange() calls that cross both anonymous
>> and file vmas will be interesting, and may have some of the
>> drawbacks of the vma based approach, but I think it will still be
> Do you have any specific drawback examples?
> I'd like to solve it if it is critical and I believe we shouldn't
> do that for simpler implementation.

My current thought is that we manage volatile memory on both a per-mm 
(for anonymous memory) and per-address_space (for file memory) basis.

The down side, if we manage both file and anonymous volatile ranges with 
the same interface, we may have similar problems to the per-vma approach 
you were trying before. Specifically, if a single range covers both 
anonymous and file memory, we'll have to do a similar iterating over the 
different types of ranges, as we did with your earlier vma approach.

This adds some complexity since with the single interval tree method in 
your current patch, we know we only have to allocate one additional 
range per insert/remove. So we can do that right off the bat, and return 
any enomem errors without having made any state changes. This is a nice 
quality to have.

Where as if we're iterating over different types of ranges, with 
possibly multiple trees (ie: different mmapped files), we don't know how 
many new ranges we may have to allocate, so we could fail half way which 
causes ambiguous results on the marking ranges non-volatile (since 
returning the error leaves the range possibly half-unmarked).


I'm still thinking it through, but that's my concern.

Some ways we can avoid this:
1) Require that any vrange() call not cross different types of memory.
2) Provide a different vrange call (fvrange?)to be used with file backed 
memory.

Any other thoughts?


>> Anyway, that's my current thinkig. You can preview my current attempt here:
>> http://git.linaro.org/gitweb?p=people/jstultz/android-dev.git;a=shortlog;h=refs/heads/dev/vrange-minchan
>>
> I saw it roughly and it seems good to me.
> I will review it in detail if you send formal patch. :)
Ok. I'm still working on some changes (been slow this week), but hope to 
have more to send your way next week.

> As you know well, there are several trial to handle memory management
> in userspace. One of example is lowmemory notifier. Kernel just send
> signal and user can free pages. Frankly speaking, I don't like that idea.
> Because there are several factors to limit userspace daemon's bounded
> reaction and could have false-positive alarm if system has streaming data,
> mlocked pages or many dirty pages and so on.

True. However, I think that there are valid use cases lowmemory 
notification (Android's low-memory killer is one, where we're not just 
freeing pages, but killing processes), and I think both approaches have 
valid use.

> Anyway, my point is that I'd like to control page reclaiming in only
> kernel itself. For it, userspace can register their volatile or
> reclaimable memory ranges to kernel and define to the threshold.
> If kernel find memory is below threshold user defined, kernel can
> reclaim every pages in registered range freely.
>
> It means kernel has a ownership of page freeing. It makes system more
> deterministic and not out-of-control.
>
> So vrange system call's semantic is following as.
>
> 1. vrange for anonymous page -> Discard wthout swapout
> 2. vrange for file-backed page except shmem/tmpfs -> Discard without sync
> 3. vrange for shmem/tmpfs -> hole punching
I think on non-shmem file backed pages (case #2) hole punching will be 
required as well. Though I'm not totally convinced volatile ranges on 
non-tmpfs files actually makes sense (I still have yet to understand a 
use case).


Thanks again for your thoughts here.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
