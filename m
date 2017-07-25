Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5356F6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:19:58 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id v49so63937566qtc.2
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:19:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h67si11501962qkf.310.2017.07.25.12.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:19:57 -0700 (PDT)
Date: Tue, 25 Jul 2017 21:19:52 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170725191952.GR29716@redhat.com>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725142626.GJ26723@dhcp22.suse.cz>
 <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
 <20170725152300.GM26723@dhcp22.suse.cz>
 <20170725153110.qzfz7wpnxkjwh5bc@node.shutemov.name>
 <20170725160359.GO26723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725160359.GO26723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 25, 2017 at 06:04:00PM +0200, Michal Hocko wrote:
> -	down_write(&mm->mmap_sem);
> +	if (tsk_is_oom_victim(current))
> +		down_write(&mm->mmap_sem);
>  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>  	tlb_finish_mmu(&tlb, 0, -1);
>  
> @@ -3012,7 +3014,8 @@ void exit_mmap(struct mm_struct *mm)
>  	}
>  	mm->mmap = NULL;
>  	vm_unacct_memory(nr_accounted);
> -	up_write(&mm->mmap_sem);
> +	if (tsk_is_oom_victim(current))
> +		up_write(&mm->mmap_sem);

How is this possibly safe? mark_oom_victim can run while exit_mmap is
running. Even if you cache the first read in the local stack, failure
to notice you marked it, could lead to use after free. Or at least
there's no comment on which lock should prevent the use after free
with the above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
