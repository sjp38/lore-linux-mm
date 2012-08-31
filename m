From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm/mmu_notifier: init notifier if necessary
Date: Fri, 31 Aug 2012 09:07:01 +0800
Message-ID: <35210.2869692773$1346375269@news.gmane.org>
References: <1345819076-12545-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20120824145151.b92557cc.akpm@linux-foundation.org>
 <50389f4d.0793b60a.1627.7710SMTPIN_ADDED@mx.google.com>
 <20120830121302.492732d2.akpm@linux-foundation.org>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1T7Fi5-0004NK-RO
	for glkm-linux-mm-2@m.gmane.org; Fri, 31 Aug 2012 03:07:46 +0200
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id DE2266B0069
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 21:07:40 -0400 (EDT)
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 30 Aug 2012 21:07:38 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 90C4A38C8047
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 21:07:06 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7V176sR125948
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 21:07:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7V175AN026630
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 21:07:06 -0400
Content-Disposition: inline
In-Reply-To: <20120830121302.492732d2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>

On Thu, Aug 30, 2012 at 12:13:02PM -0700, Andrew Morton wrote:
>On Sat, 25 Aug 2012 17:47:50 +0800
>Gavin Shan <shangw@linux.vnet.ibm.com> wrote:
>
>> >> --- a/mm/mmu_notifier.c
>> >> +++ b/mm/mmu_notifier.c
>> >> @@ -192,22 +192,23 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
>> >>  
>> >>  	BUG_ON(atomic_read(&mm->mm_users) <= 0);
>> >>  
>> >> -	ret = -ENOMEM;
>> >> -	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
>> >> -	if (unlikely(!mmu_notifier_mm))
>> >> -		goto out;
>> >> -
>> >>  	if (take_mmap_sem)
>> >>  		down_write(&mm->mmap_sem);
>> >>  	ret = mm_take_all_locks(mm);
>> >>  	if (unlikely(ret))
>> >> -		goto out_cleanup;
>> >> +		goto out;
>> >>  
>> >>  	if (!mm_has_notifiers(mm)) {
>> >> +		mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm),
>> >> +					GFP_ATOMIC);
>> >
>> >Why was the code switched to the far weaker GFP_ATOMIC?  We can still
>> >perform sleeping allocations inside mmap_sem.
>> >
>> 
>> Yes, we can perform sleeping while allocating memory, but we're holding
>> the "mmap_sem". GFP_KERNEL possiblly block somebody else who also waits
>> on mmap_sem for long time even though the case should be rare :-)
>
>GFP_ATOMIC allocations are unreliable.  If the allocation attempt fails
>here, an entire kernel subsystem will have failed, quite probably
>requiring a reboot.  It's a bad tradeoff.
>

Yep. Thanks, Andrew :-)

>Please fix this and retest.  With lockdep enabled, of course.
>
>And please do not attempt to sneak changes like this into the kernel
>without even mentioning them in the changelog.  If I hadn't have
>happened to notice this, we'd have ended up with a less reliable
>kernel.
>

I'll fix and rerest it.

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
