Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6A67B6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:18:18 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id o11so115101649qge.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:18:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x69si25512679qha.127.2016.01.25.10.18.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 10:18:17 -0800 (PST)
Date: Mon, 25 Jan 2016 19:18:12 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm, gup: introduce concept of "foreign" get_user_pages()
Message-ID: <20160125181812.GA9050@redhat.com>
References: <20160122180219.164259F1@viggo.jf.intel.com>
 <20160125131723.GB17206@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160125131723.GB17206@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, vbabka@suse.cz, jack@suse.cz

On 01/25, Srikar Dronamraju wrote:
>
> > The uprobes is_trap_at_addr() location holds mmap_sem and
> > calls get_user_pages(current->mm) on an instruction address.  This
> > makes it a pretty unique gup caller.

Yes, in particular is_trap_at_addr() doesn't look really nice. But we need
to read the insn under mmap_sem to avoid the race with unregister + register
at the same address, so that we won't send the wrong SIGTRAP in this case.

> Changes for uprobes.c looks good to me.
> Acked-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Agreed, the changes in uprobes.c look fine.


> > @@ -1700,7 +1700,13 @@ static int is_trap_at_addr(struct mm_str
> >  	if (likely(result == 0))
> >  		goto out;
> >
> > -	result = get_user_pages(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
> > +	/*
> > +	 * The NULL 'tsk' here ensures that any faults that occur here
> > +	 * will not be accounted to the task.  'mm' *is* current->mm,
> > +	 * but we treat this as a 'foreign' access since it is
> > +	 * essentially a kernel access to the memory.
> > +	 */
> > +	result = get_user_pages_foreign(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
> >  	if (result < 0)
> >  		return result;

Yes, but perhaps we should simply remove this get_user_pages_foreign() and just
return -EFAULT if copy_from_user_inatomic() fails. This should be very unlikely
case, I think it would be fine to restart this insn and take another bp hit to
fault this page in.

Srikar what do you think? IIRC, this get_user_pages() was needed before, when
is_trap_at_addr() had other (non-restartable) callers with mm != current->mm.

But again, I think this patch is fine, we can do this later.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
