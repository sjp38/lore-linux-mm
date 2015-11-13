Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 715EF6B0269
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 14:23:20 -0500 (EST)
Received: by wmww144 with SMTP id w144so44204068wmw.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 11:23:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 81si7480607wmm.87.2015.11.13.11.23.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Nov 2015 11:23:19 -0800 (PST)
Date: Fri, 13 Nov 2015 11:23:10 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH, RESEND] ipc/shm: handle removed segments gracefully in
 shm_mmap()
Message-ID: <20151113192310.GC3502@linux-uzut.site>
References: <1447232220-36879-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151111170347.GA3502@linux-uzut.site>
 <20151111195023.GA17310@node.shutemov.name>
 <20151113053137.GB3502@linux-uzut.site>
 <20151113091259.GB28904@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20151113091259.GB28904@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>, Manfred Spraul <manfred@colorfullife.com>

On Fri, 13 Nov 2015, Kirill A. Shutemov wrote:

>On Thu, Nov 12, 2015 at 09:31:37PM -0800, Davidlohr Bueso wrote:
>> On Wed, 11 Nov 2015, Kirill A. Shutemov wrote:
>> >And I had concern about your approach:
>> >
>> >	If I read it correctly, with the patch we would ignore locking
>> >	failure inside shm_open() and mmap will succeed in this case. So
>> >	the idea is to have shm_close() no-op and therefore symmetrical.
>>
>> Both open and close are no-ops in the case the segment has been removed,
>
>The part I disagree is that shm_open() shouldn't be allowed for removed
>segment. Basically, I prefer to keep the policy we have now.
>
>> that's the symmetrical, and I'm not sure I follow -- we don't ignore locking
>> failure in shm_open _at all_. Just like your approach, all I do is return if
>> there's an error...
>
>As you wrote in the comment, shm_check_vma_validity() check is racy. It's
>just speculative check which doesn't guarantee that shm_lock() in
>shm_open() will succeed. If this race happen, you just ignore this locking
>failure and proceed. You compensate this, essentially failed shm_open(),
>by no-op in shm_close().

With the exception of the call in shm_mmap, we handle shm_open and shm_close
the same way, we both consider them no-ops, just that you return the error
code from shm_lock. But we can easily recover this error within the mmap call,
so this seems unnecessary. See below.

>
>In my opinion, failed shm_lock() in shm_open() should lead to returning
>error from shm_mmap(). And there's no need in shm_close() hackery.
>My patch tries to implement this.
>
>>
>> >	That's look fragile to me. We would silently miss some other
>> >	broken open/close pattern.
>>
>> Such cases, if any, should be fixed and handled appropriately, not hide
>> it under the rung, methinks.
>
>But, don't you think you *do* hide such cases? With you patch pattern like
>shm_open()-shm_close()-shm_close() will not trigger any visible effect.
>
>> >>o My no-ops explicitly pair.
>> >
>> >As I said before, I don't think we should ignore locking error in
>> >shm_open(). If we propagate the error back to caller shm_close() should
>> >never happen, therefore no-op is unneeded in shm_close(): my patch trigger
>> >WARN() there.
>>
>> Yes, you WARN() in shm_close, but you still make it a no-op...
>
>We can crash kernel with BUG_ON() there, but would it help anyone?

So a failed shm_lock() used to always be a BUG_ON, but I don't think
we want to go back to that. Ultimately, a busted ipc id is not a reason
to halt the kernel.

>The WARN() is just to make broken open/close visible.

I really don't like that you have two different logic for shm_open and close
(more below).

>
>> >>>	ret = sfd->file->f_op->mmap(sfd->file, vma);
>> >>>-	if (ret != 0)
>> >>>+	if (ret) {
>> >>>+		shm_close(vma);
>> >>>		return ret;
>> >>>+	}
>> >>
>> >>Hmm what's this shm_close() about?
>> >
>> >Undo shp->shm_nattch++ in successful __shm_open().
>>
>> Yeah that's just nasty.
>
>I don't see why: we successfully opened the segment, but f_op->mmap
>failed -- let's close the segment. It's normal error path.

I was referring to the fact that I hate having to prematurely call shm_open()
just for this case, and then have to backout, ie for nattach. Similarly, I
dislike that you make shm_close behave one way and _shm_open another, looks
hacky.

That said, I do agree that we should inform EIDRM back to the shm_mmap
caller. My immediate thought would be to recheck right after shm_open returns.
I realize this is also hacky as we run into similar inconsistencies that I
mentioned above. But that's a caller (and the only one), not the whole
shm_open/close. Also, just like we are concerned about EIDRM, should we also
care about EINVAL -- where we race with explicit user shmctl(RMID) calls but
we hold reference to nattach?? I mean, why bother doing mmap if the segment is
marked for deletion and ipc won't touch it again anyway (failed idr lookups).
The downside to that is the extra lookup overhead, so perhaps your approach
is better. But looks like the right thing to do conceptually. Something like so?

shm_mmap()
{
	err = shm_check_vma_validity()
	if (err)

	->mmap()

	shm_open()
	err = shm_check_vma_validity()
	if (err)
	   return err; /* shm_open was a nop, return the corresponding error */

	return 0;
}

So considering EINVAL, even your approach to bumping up nattach by calling
_shm_open earlier isn't enough. Races exposed to user called rmid can still
occur between dropping the lock and doing ->mmap(). Ultimately this leads to
all ipc_valid_object() checks, as we totally ignore SHM_DEST segments nowadays
since we forbid mapping previously removed segments.

I think this is the first thing we must decide before going forward with this
mess. ipc currently defines invalid objects by merely checking the deleted flag.

Manfred, any thoughts?

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
