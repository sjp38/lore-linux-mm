Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA17160
	for <linux-mm@kvack.org>; Sun, 29 Nov 1998 15:11:53 -0500
Subject: Re: Update shared mappings
References: <87btm3dmxy.fsf@atlas.CARNet.hr> <199811301352.NAA03313@dax.scot.redhat.com>
Reply-To: Zlatko.Calusic@CARNet.hr
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 30 Nov 1998 16:19:17 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 30 Nov 1998 13:52:08 GMT"
Message-ID: <87yaotcioa.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Linux-MM List <linux-mm@kvack.org>, Andi Kleen <andi@zero.aec.at>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On 20 Nov 1998 05:10:01 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> > Should this patch be applied to kernel? [Andrea's
> > update_shared_mappings patch]
> 
> No.

:)

> The mmap_semaphore is already taken out _much_ earlier on in msync(), or
> the vm_area_struct can be destroyed by another thread.  Is this patch
> tested?  Won't we deadlock immediately on doing this extra down()
> operation? 

You're right. And that is the exact reason why I had locks with
StarOffice in down_sem().

Andrea already contacted me, and I think this now concludes our
conversation regarding that problem. :)

> 
> The only reason that this patch works in its current state is that
> exit_mmap() skips the down(&mm->mmap_sem).  It can safely do so only
> because if we are exiting the mmap, we know we are the last thread and
> so no other thread can be playing games with us.  So, exit_mmap()
> doesn't deadlock, but a sys_msync() on the region looks as if it will.
> 
> Other than that, it looks fine.  One other thing occurs to me, though:
> it would be easy enough to add a condition (atomic_read(&page->count) >
> 2) on this to disable the update-mappings call entirely if the page is
> only mapped by one vma (which will be a very common case).  We already
> access the count field, so we are avoiding the cost of any extra cache
> misses if we make this check.
> 
> Comments?
> 

You're probably right.

Hopefully, Andrea will resend his patch with necessary fixes, so after
testing it gets included in kernel.

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	    Life would be easier if I had the source code.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
