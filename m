Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1C39A6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:05:10 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id b14so81600973wmb.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 06:05:10 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id hn8si28661619wjb.93.2016.01.25.06.05.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 06:05:08 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 55E0298B71
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 14:05:08 +0000 (UTC)
Date: Mon, 25 Jan 2016 14:05:06 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm: filemap: Avoid unnecessary calls to lock_page
 when waiting for IO to complete during a read
Message-ID: <20160125140506.GF3162@techsingularity.net>
References: <1453716204-20409-1-git-send-email-mgorman@techsingularity.net>
 <1453716204-20409-3-git-send-email-mgorman@techsingularity.net>
 <20160125113513.GE20933@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160125113513.GE20933@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 25, 2016 at 12:35:13PM +0100, Jan Kara wrote:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 

Thanks!

> > ---
> >  mm/filemap.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 49 insertions(+)
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index aa38593d0cd5..235ee2b0b5da 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1649,6 +1649,15 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
> >  					index, last_index - index);
> >  		}
> >  		if (!PageUptodate(page)) {
> > +			/*
> > +			 * See comment in do_read_cache_page on why
> > +			 * wait_on_page_locked is used to avoid unnecessarily
> > +			 * serialisations and why it's safe.
> > +			 */
> > +			wait_on_page_locked(page);
> > +			if (PageUptodate(page))
> > +				goto page_ok;
> > +
> 
> We want a wait_on_page_locked_killable() here to match the
> lock_page_killable() later in do_generic_file_read()?
> 

Yes, I'll fix it in v2.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
