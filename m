Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id AAB1F6B0253
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:22:58 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l68so1479007wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:22:58 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id h82si21525843wmf.37.2016.02.29.10.22.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 10:22:57 -0800 (PST)
Received: by mail-wm0-f48.google.com with SMTP id l68so3191599wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:22:57 -0800 (PST)
Date: Mon, 29 Feb 2016 19:22:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] uprobes: wait for mmap_sem for write killable
Message-ID: <20160229182256.GQ16930@dhcp22.suse.cz>
References: <1456752417-9626-16-git-send-email-mhocko@kernel.org>
 <1456767743-18665-1-git-send-email-mhocko@kernel.org>
 <20160229181105.GG3615@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229181105.GG3615@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon 29-02-16 19:11:06, Oleg Nesterov wrote:
> On 02/29, Michal Hocko wrote:
> >
> > --- a/kernel/events/uprobes.c
> > +++ b/kernel/events/uprobes.c
> > @@ -1130,7 +1130,9 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
> >  	struct vm_area_struct *vma;
> >  	int ret;
> >  
> > -	down_write(&mm->mmap_sem);
> > +	if (down_write_killable(&mm->mmap_sem))
> > +		return -EINTR;
> > +
> >  	if (mm->uprobes_state.xol_area) {
> >  		ret = -EALREADY;
> >  		goto fail;
> > @@ -1468,7 +1470,8 @@ static void dup_xol_work(struct callback_head *work)
> >  	if (current->flags & PF_EXITING)
> >  		return;
> >  
> > -	if (!__create_xol_area(current->utask->dup_xol_addr))
> > +	if (!__create_xol_area(current->utask->dup_xol_addr) &&
> > +			!fatal_signal_pending(current)
> >  		uprobe_warn(current, "dup xol area");
> >  }
> 
> Looks good, thanks.

Can I consider this your Acked-by?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
