Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 724F86B005D
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 21:15:58 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so159389qwf.44
        for <linux-mm@kvack.org>; Wed, 12 Aug 2009 18:16:01 -0700 (PDT)
Message-ID: <4A83694F.6090809@gmail.com>
Date: Wed, 12 Aug 2009 21:15:59 -0400
From: William R Speirs <bill.speirs@gmail.com>
MIME-Version: 1.0
Subject: Re: vma_merge issue
References: <a1b36c3a0908101347t796dedbat2ecb0535c32f325b@mail.gmail.com>  <Pine.LNX.4.64.0908121841550.14314@sister.anvils> <a1b36c3a0908121204q1b59df1fk86afec9d05ec16dc@mail.gmail.com> <Pine.LNX.4.64.0908122038360.18426@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908122038360.18426@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
>> Unfortunately, that doesn't work. When I mmap pages as PROT_WRITE it
>> is checked against the CommitLimit and returns with ENOMEM as I'm
>> mmaping a lot of pages. However, I don't actually want to be charged
>> for that memory, as I won't be using all of it. This is why I mmap as
>> PROT_NONE as I'm not charged for it.
> 
> I'm sorry, I hadn't realized you're working in an overcommit_memory 2
> environment.  And it's not single user, so you don't have the freedom
> to adjust /proc/sys/vm/overcommit_ratio to suit your needs?

I could maybe change these things, but I'd have to fight with the sys 
admin... not a battle I want to engage in.

>> Then when I set a page to
>> PROT_WRITE I get charged (which is expected and OK), but then going
>> back to PROT_NONE I don't get "uncharged". This makes sense as I could
>> simply PROT_WRITE that page again and I should be charged.
> 
> Even if you never wrote to it again, PROT_READ would have to show you
> the same content as was in there before, so you definitely still need
> to be charged for it.

Good point. In my world (program) once a page goes PROT_NONE I will 
never need the memory again. But alas not everyone lives in my world...

>> However, I
>> have no way (that I know of) to tell the kernel "I'm done with this
>> page, don't charge me for it, and set it's protection to PROT_NONE."
>> I've tried madvise with MADV_DONTNEED but that doesn't seem to remove
>> the VM_ACCOUNT flag.
> 
> MADV_DONTNEED: brilliant idea, what a shame it doesn't work for you.
> I'd been on the point of volunteering a bugfix to it to do what you
> want, it would make sense; but there's a big but... we have sold
> MADV_DONTNEED as an madvise that only needs non-exclusive access
> to the mmap_sem, which means it can be used concurrently with faulting,
> which has made it much more useful to glibc (I believe).  If we were
> to fiddle with vmas and accounting and merging in there, it would go
> back to needing exclusive mmap_sem, which would hurt important users.

For my own edification, hurt these users how? Performance? Serializing 
access during a MADV_DONTNEED? I wonder how big the "hurt" would be?

> There could be a MADV_BILL_SPEIRS_WONTNEED, but even if we could
> agree on a more impartial name for it, it might be hard to justify,
> and tiresome to write the man page explaining when to use this and
> when to use that.  Could be done, but...

While my ego would love that constant...

> Oh, I've somehow missed your next paragraph...
> 
>> I have seen an mm patch that introduces MADV_FREE, which I believe
>> removes the VM_ACCOUNT flag and decrements the commit charge. Does it
>> make sense to have this type of functionality? Can I get this same
>> type of functionality (start without being charged for a page, use it,
>> then un-use it and remove the charge for it?) currently?
> 
> The name MADV_FREE is vaguely familiar, let's see, Rik, 2007.
> Looking at that patch, no, it didn't remove the commit charge:
> it kept quite close to MADV_DONTNEED in that respect.  I think
> Nick's non-exclusive mmap_sem mod to MADV_DONTNEED solved the
> particular problem which MADV_FREE was proposed for, in a much
> simpler way, so MADV_FREE didn't get any further.

Yeah, I apologize, I didn't study exactly what the proposed MADV_FREE 
was to do before suggesting it. Informative, thanks!

> What could you do?  Some variously unsatisfactory solutions,
> all of which you've probably rejected already:
> 
> Raise max_map_count via /proc/sys/vm/max_map_count
> (but probably you don't have access to do so)

Been here. Again, I'd have to fight with the sys admins...

> Don't mmap the arena in the first place, or mmap it and then munmap
> all but start and end, use MAP_FIXED within the arena for your pages,
> and pray that no library might be mmap'ing in there while you're
> running (and maybe the architecture's address choices will help you).

Interesting idea, but slightly too risky for me.

> Don't use anonymous memory, have a 1GB sparse file to back this,
> and mmap it MAP_SHARED, then you won't get charged for RAM+swap.
> 
> On Wed, 12 Aug 2009, Hugh Dickins wrote:
> 
> A "refinement" to that suggestion is to put the file on tmpfs:
> you will then get charged for RAM+swap as you use it, but you can
> use madvise MADV_REMOVE to unmap pages, punching holes in the file,
> freeing up those charges.  A little baroque, but I think it does
> amount to a way of doing exactly what you wanted in the first place.

I like this (the refined) idea a lot. I coded it up and works as 
expected, and the way I initially want.

Thanks for taking the time and providing the solution... I appreciate it.

Bill-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
