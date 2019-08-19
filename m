Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E03AC3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 16:05:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0520420651
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 16:05:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0520420651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66DFB6B0006; Mon, 19 Aug 2019 12:05:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61F256B0007; Mon, 19 Aug 2019 12:05:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E6376B0010; Mon, 19 Aug 2019 12:05:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0215.hostedemail.com [216.40.44.215])
	by kanga.kvack.org (Postfix) with ESMTP id 2738D6B0006
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:05:29 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id CBB963D00
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:05:28 +0000 (UTC)
X-FDA: 75839652336.11.trees70_69e869d640242
X-HE-Tag: trees70_69e869d640242
X-Filterd-Recvd-Size: 4351
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:05:27 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0B7FF3090FCB;
	Mon, 19 Aug 2019 16:05:26 +0000 (UTC)
Received: from mail (ovpn-120-35.rdu2.redhat.com [10.10.120.35])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3AC0860BE2;
	Mon, 19 Aug 2019 16:05:19 +0000 (UTC)
Date: Mon, 19 Aug 2019 12:05:17 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kefeng Wang <wangkefeng.wang@huawei.com>,
	Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190819160517.GG31518@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190814135351.GY17933@dhcp22.suse.cz>
 <7e0e4254-17f4-5f07-e9af-097c4162041a@huawei.com>
 <20190814151049.GD11595@redhat.com>
 <20190814154101.GF11595@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814154101.GF11595@redhat.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 19 Aug 2019 16:05:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 05:41:02PM +0200, Oleg Nesterov wrote:
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -880,6 +880,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
>  	/* len == 0 means wake all */
>  	struct userfaultfd_wake_range range = { .len = 0, };
>  	unsigned long new_flags;
> +	bool xxx;
>  
>  	WRITE_ONCE(ctx->released, true);
>  
> @@ -895,8 +896,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
>  	 * taking the mmap_sem for writing.
>  	 */
>  	down_write(&mm->mmap_sem);
> -	if (!mmget_still_valid(mm))
> -		goto skip_mm;
> +	xxx = mmget_still_valid(mm);
>  	prev = NULL;
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
>  		cond_resched();
> @@ -907,19 +907,20 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
>  			continue;
>  		}
>  		new_flags = vma->vm_flags & ~(VM_UFFD_MISSING | VM_UFFD_WP);
> -		prev = vma_merge(mm, prev, vma->vm_start, vma->vm_end,
> -				 new_flags, vma->anon_vma,
> -				 vma->vm_file, vma->vm_pgoff,
> -				 vma_policy(vma),
> -				 NULL_VM_UFFD_CTX);
> -		if (prev)
> -			vma = prev;
> -		else
> -			prev = vma;
> +		if (xxx) {
> +			prev = vma_merge(mm, prev, vma->vm_start, vma->vm_end,
> +					 new_flags, vma->anon_vma,
> +					 vma->vm_file, vma->vm_pgoff,
> +					 vma_policy(vma),
> +					 NULL_VM_UFFD_CTX);
> +			if (prev)
> +				vma = prev;
> +			else
> +				prev = vma;
> +		}
>  		vma->vm_flags = new_flags;
>  		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
>  	}
> -skip_mm:
>  	up_write(&mm->mmap_sem);
>  	mmput(mm);
>  wakeup:

The proposed fix looks correct, can you resend in a way that can be merged?

What happens is there are 4 threads, the uffdio copy with NULL source
address is just to induce more thread creation, then one thread does
UFFDIO_COPY with source in the uffd region so it blocks in
handle_userfault inside UFFDIO_COPY. When one of the threads then does
the illegal instruction the core dump starts. The core dump wakes the
userfault and the copy-user in UFFDIO_COPY is being retried after
userfaultfd_release already run because one of the other threads
already went through do_exit. It's a bit strange that the file that
was opened by the ioctl() syscall gets released and its
file->private_data destroyed before the ioctl syscall has a chance to
return to userland.

Anyway the same race condition can still happen for a rogue page fault
that is happening when the core dump start so the above fix is needed
anyway.

