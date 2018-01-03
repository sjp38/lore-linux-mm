Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB8D6B02F3
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 00:48:51 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e26so268876pgv.16
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 21:48:51 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id a24si214563pgd.261.2018.01.02.21.48.48
        for <linux-mm@kvack.org>;
        Tue, 02 Jan 2018 21:48:49 -0800 (PST)
Subject: Re: About the try to remove cross-release feature entirely by Ingo
References: <20171229014736.GA10341@X58A-UD3R>
 <20171229035146.GA11757@thunk.org> <20171229072851.GA12235@X58A-UD3R>
 <20171230061624.GA27959@bombadil.infradead.org>
 <20171230154041.GB3366@thunk.org>
 <20171230204417.GF27959@bombadil.infradead.org>
 <20171230224028.GC3366@thunk.org> <20171230230057.GB12995@thunk.org>
 <20180101101855.GA23567@bombadil.infradead.org>
 <06e73e69-9c78-07bc-3d06-a51accb2645b@lge.com>
 <20180103025808.GD30682@dastard>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <eb57e8b8-bdf4-9c84-98e1-4a21e77bc069@lge.com>
Date: Wed, 3 Jan 2018 14:48:45 +0900
MIME-Version: 1.0
In-Reply-To: <20180103025808.GD30682@dastard>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com, kernel-team@lge.com, daniel@ffwll.ch

On 1/3/2018 11:58 AM, Dave Chinner wrote:
> On Wed, Jan 03, 2018 at 11:28:44AM +0900, Byungchul Park wrote:
>> On 1/1/2018 7:18 PM, Matthew Wilcox wrote:
>>> On Sat, Dec 30, 2017 at 06:00:57PM -0500, Theodore Ts'o wrote:
>>>> Also, what to do with TCP connections which are created in userspace
>>>> (with some authentication exchanges happening in userspace), and then
>>>> passed into kernel space for use in kernel space, is an interesting
>>>> question.
>>>
>>> Yes!  I'd love to have a lockdep expert weigh in here.  I believe it's
>>> legitimate to change a lock's class after it's been used, essentially
>>> destroying it and reinitialising it.  If not, it should be because it's
>>> a reasonable design for an object to need different lock classes for
>>> different phases of its existance.
>>
>> I also think it should be done ultimately. And I think it's very much
>> hard since it requires to change the dependency graph of lockdep but
>> anyway possible. It's up to lockdep maintainer's will though..
> 
> We used to do this in XFS to work around the fact that the memory
> reclaim context "locks" were too stupid to understand that an object
> referenced and locked above memory allocation could not be
> accessed below in memory reclaim because memory reclaim only accesses
> /unreferenced objects/. We played whack-a-mole with lockdep for
> years to get most of the false positives sorted out.
> 
> Hence for a long time we had to re-initialise the lock context for
> the XFS inode iolock in ->evict_inode() so we could lock it for
> reclaim processing.  Eventually we ended up completely reworking the
> inode reclaim locking in XFS primarily to get rid of all the nasty
> lockdep hacks we had strewn throughout the code. It was ~2012 we
> got rid of the last inode re-init code, IIRC. Yeah:
> 
> commit 4f59af758f9092bc7b266ca919ce6067170e5172
> Author: Christoph Hellwig <hch@infradead.org>
> Date:   Wed Jul 4 11:13:33 2012 -0400
> 
>      xfs: remove iolock lock classes
>      
>      Now that we never take the iolock during inode reclaim we don't need
>      to play games with lock classes.
>      
>      Signed-off-by: Christoph Hellwig <hch@lst.de>
>      Reviewed-by: Rich Johnston <rjohnston@sgi.com>
>      Signed-off-by: Ben Myers <bpm@sgi.com>
> 
> We still have problems with lockdep false positives w.r.t. memory
> allocation contexts, mainly with code that can be called from
> both above and below memory allocation contexts. We've finally
> got __GFP_NOLOCKDEP to be able to annotate memory allocation points
> within such code paths, but that doesn't help with locks....
> 
> Byungchul, lockdep has a long, long history of having sharp edges
> and being very unfriendly to developers. We've all been scarred by
> lockdep at one time or another and so there's a fair bit of
> resistance to repeating past mistakes and allowing lockdep to
> inflict more scars on us....

As I understand what you suffered from.. I don't really want to
force it forward strongly.

So far, all problems have been handled by myself including the
final one e.i. the completion in submit_bio_wait() with the
invalidation if it's allowed. But yes, who knows the future? In
the future, that terrible thing you mentioned might or might
not happen because of cross-release.

I just felt like someone was misunderstanding what the problem
came from, what the problem was, how we could avoid it, why
cross-release should be removed and so on..

I believe the 3 ways I suggested can help, but I don't want to
strongly insist if all of you don't think so.

Thanks a lot anyway for your opinion.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
