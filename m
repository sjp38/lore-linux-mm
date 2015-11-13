Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id EBC576B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 00:31:45 -0500 (EST)
Received: by wmec201 with SMTP id c201so64932362wme.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 21:31:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jp7si12335988wjc.168.2015.11.12.21.31.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Nov 2015 21:31:44 -0800 (PST)
Date: Thu, 12 Nov 2015 21:31:37 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH, RESEND] ipc/shm: handle removed segments gracefully in
 shm_mmap()
Message-ID: <20151113053137.GB3502@linux-uzut.site>
References: <1447232220-36879-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151111170347.GA3502@linux-uzut.site>
 <20151111195023.GA17310@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20151111195023.GA17310@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>

On Wed, 11 Nov 2015, Kirill A. Shutemov wrote:
>And I had concern about your approach:
>
>	If I read it correctly, with the patch we would ignore locking
>	failure inside shm_open() and mmap will succeed in this case. So
>	the idea is to have shm_close() no-op and therefore symmetrical.

Both open and close are no-ops in the case the segment has been removed,
that's the symmetrical, and I'm not sure I follow -- we don't ignore locking
failure in shm_open _at all_. Just like your approach, all I do is return if
there's an error...

>	That's look fragile to me. We would silently miss some other
>	broken open/close pattern.

Such cases, if any, should be fixed and handled appropriately, not hide
it under the rung, methinks.

>>
>> o My shm_check_vma_validity() also deals with IPC_RMID as we do the
>> ipc_valid_object() check.
>
>Mine too:
>
> shm_mmap()
>   __shm_open()
>     shm_lock()
>       ipc_lock()
>         ipc_valid_object()
>
>Or I miss something?

Sorry, I meant ipc_obtain_object_idr, so EINVAL is also accounted for, we
the segment is already deleted and not only marked as such.

>
>> o We have a new WARN where necessary, instead of having one now is shm_open.
>
>I'm not sure why you think that shm_close() which was never paired with
>successful shm_open() doesn't deserve WARN().
>
>> o My no-ops explicitly pair.
>
>As I said before, I don't think we should ignore locking error in
>shm_open(). If we propagate the error back to caller shm_close() should
>never happen, therefore no-op is unneeded in shm_close(): my patch trigger
>WARN() there.

Yes, you WARN() in shm_close, but you still make it a no-op...

>
>> >	ret = sfd->file->f_op->mmap(sfd->file, vma);
>> >-	if (ret != 0)
>> >+	if (ret) {
>> >+		shm_close(vma);
>> >		return ret;
>> >+	}
>>
>> Hmm what's this shm_close() about?
>
>Undo shp->shm_nattch++ in successful __shm_open().

Yeah that's just nasty.

>
>I've got impression that I miss something important about how locking in
>IPC/SHM works, but I cannot grasp what.. Hm?.

Could you be more specific? The only lock involved here is the ipc object lock,
if you haven't, you might want to refer to ipc/util.c which has a brief ipc
locking description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
