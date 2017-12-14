Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 11BE86B025E
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 21:30:27 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id s41so2337785wrc.22
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 18:30:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 36si2466123wrd.492.2017.12.13.18.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 18:30:25 -0800 (PST)
Date: Wed, 13 Dec 2017 18:30:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: save current->journal_info before calling
 fault/page_mkwrite
Message-Id: <20171213183022.adce31de7c5e704b4315e472@linux-foundation.org>
In-Reply-To: <91E1F854-7CE7-4E98-BA87-7E4E55243109@redhat.com>
References: <20171213035836.916-1-zyan@redhat.com>
	<20171213165923.0ea4eb3e996b7d8bf1fff72f@linux-foundation.org>
	<91E1F854-7CE7-4E98-BA87-7E4E55243109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Yan, Zheng" <zyan@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, viro@zeniv.linux.org.uk, jlayton@redhat.com, linux-mm@kvack.org

On Thu, 14 Dec 2017 10:20:18 +0800 "Yan, Zheng" <zyan@redhat.com> wrote:

> >> +	/*
> >> +	 * If the fault happens during write_iter() copies data from
> >> +	 * userspace, filesystem may have set current->journal_info.
> >> +	 * If the userspace memory is mapped to a file on another
> >> +	 * filesystem, fault handler of the later filesystem may want
> >> +	 * to access/modify current->journal_info.
> >> +	 */
> >> +	current->journal_info = NULL;
> >> 	ret = vma->vm_ops->fault(vmf);
> >> +	/* Restore original journal_info */
> >> +	current->journal_info = old_journal_info;
> >> 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
> >> 			    VM_FAULT_DONE_COW)))
> >> 		return ret;
> > 
> > Can you explain why you chose these two sites?  Rather than, for
> > example, way up in handle_mm_fault()?
> 
> I think they are the only two places that code can enter another filesystem

hm.  Maybe.  At this point in time.  I'm feeling that doing the
save/restore at the highest level is better.  It's cheap.

> > 
> > It's hard to believe that a fault handler will alter ->journal_info if
> > it is handling a read fault, so perhaps we only need to do this for a
> > write fault?  Although such an optimization probably isn't worthwhile. 
> > The whole thing is only about three instructions.
> 
> ceph uses current->journal_info for both read/write operations. I think btrfs also read current->journal_info during read-only operation. (I mentioned this in my previous reply)

Quite a lot of filesystems use ->journal_info.  Arguably it should be
the fs's responsibility to restore the old journal_info value after
having used it.  But that's a ton of changes :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
