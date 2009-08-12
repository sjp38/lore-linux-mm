Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 818D76B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 22:49:59 -0400 (EDT)
Received: from mlsv1.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id 6D40933CC8
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 11:50:04 +0900 (JST)
Message-ID: <4A822DD4.1050202@hitachi.com>
Date: Wed, 12 Aug 2009 11:49:56 +0900
From: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for migration
    aware file systems
References: <200908051136.682859934@firstfloor.org>
    <20090805093643.E0C00B15D8@basil.firstfloor.org>
    <4A7FBFD1.2010208@hitachi.com> <20090810074421.GA6838@basil.fritz.box>
    <4A80EAA3.7040107@hitachi.com> <20090811071756.GC14368@basil.fritz.box>
In-Reply-To: <20090811071756.GC14368@basil.fritz.box>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: tytso@mit.edu, hch@infradead.org, mfasheh@suse.com, aia21@cantab.net, hugh.dickins@tiscali.co.uk, swhiteho@redhat.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> On Tue, Aug 11, 2009 at 12:50:59PM +0900, Hidehiro Kawai wrote:
> 
>>>And application
>>>that doesn't handle current IO errors correctly will also
>>>not necessarily handle hwpoison correctly (it's not better and not worse)
>>
>>This is my main concern.  I'd like to prevent re-corruption even if
>>applications don't have good manners.
> 
> I don't think there's much we can do if the application doesn't
> check for IO errors properly. What would you do if it doesn't
> check for IO errors at all? If it checks for IO errors it simply
> has to check for them on all IO operations -- if they do 
> they will detect hwpoison errors correctly too.

I believe it's not uncommon for applications to do buffered write
and then exit without fsync().  And I think it's difficult to
preclude such applications and commands from the system perfectly.
 
>>That is why I suggested this:
>>
>>>>(2) merge this patch with new panic_on_dirty_page_cache_corruption
>>>>    sysctl
> 
> You probably mean panic_on_non_anonymous_dirty_page_cache
> Normally anonymous memory is dirty.

Yes, and sorry for my ambiguous description.  I used the word "cache"
to intend to not include anonymous pages.
 
> It's unclear to me this special mode is really desirable.
> Does it bring enough value to the user to justify the complexity
> of another exotic option?  The case is relatively exotic,
> as in dirty write cache that is mapped to a file.
> 
> Try to explain it in documentation and you see how ridiculous it sounds; u
> it simply doesn't have clean semantics
> 
> ("In case you have applications with broken error IO handling on
> your mission critical system ...") 

Generally, dropping unwritten dirty page caches is considered to be
risky.  So the "panic on IO error" policy has been used as usual
practice for some systems.  I just suggested that we adopted
this policy into machine check errors. 

vm.memory_failure_recovery satisfies my minimal requirement.
It's OK at this stage, but I'd like to improve this in the future.

Another option is to introduce "ignore all" policy instead of
panicking at the beginig of memory_failure().  Perhaps it finally
causes SRAR machine check, and then kernel will panic or a process
will be killed.  Anyway, this is a topic for the next stage.
 
>>>(4) accept that hwpoison error handling is not better and not worse than normal
>>>IO error handling.
>>>
>>>We opted for (4).
>>
>>Could you consider adopting (2) or (3)?  Fengguang's sticky EIO
>>approach (http://lkml.org/lkml/2009/6/11/294) is also OK.
> 
> I believe redesigned IO error handling does not belong in the 
> core hwpoison patchkit.

I agree.
 
> If you want to have improved IO error handling feel free to
> submit it separately. I agree this area could use some work.
> But it probably needs more design work first.

Well, this patch set itself looks good to me.
I also looked into the other patches, I couldn't find any
problems (although I'm not good judge of reviewing).

Reviewed-by: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>

Thanks,
-- 
Hidehiro Kawai
Hitachi, Systems Development Laboratory
Linux Technology Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
