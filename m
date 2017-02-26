Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1ECBA6B0038
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 12:10:39 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b2so137938178pgc.6
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 09:10:39 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id q1si8549709plb.117.2017.02.26.09.10.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 Feb 2017 09:10:37 -0800 (PST)
Message-ID: <1488129033.4157.8.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] do we really need PG_error at all?
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sun, 26 Feb 2017 09:10:33 -0800
In-Reply-To: <1488120164.2948.4.camel@redhat.com>
References: <1488120164.2948.4.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: lsf-pc <lsf-pc@lists.linuxfoundation.org>, Neil Brown <neilb@suse.de>, linux-scsi <linux-scsi@vger.kernel.org>, linux-block@vger.kernel.org

[added linux-scsi and linux-block because this is part of our error
handling as well]
On Sun, 2017-02-26 at 09:42 -0500, Jeff Layton wrote:
> Proposing this as a LSF/MM TOPIC, but it may turn out to be me just 
> not understanding the semantics here.
> 
> As I was looking into -ENOSPC handling in cephfs, I noticed that
> PG_error is only ever tested in one place [1] 
> __filemap_fdatawait_range, which does this:
> 
> 	if (TestClearPageError(page))
> 		ret = -EIO;
> 
> This error code will override any AS_* error that was set in the
> mapping. Which makes me wonder...why don't we just set this error in 
> the mapping and not bother with a per-page flag? Could we potentially
> free up a page flag by eliminating this?

Note that currently the AS_* codes are only set for write errors not
for reads and we have no mapping error handling at all for swap pages,
but I'm sure this is fixable.

>From the I/O layer point of view we take great pains to try to pinpoint
the error exactly to the sector.  We reflect this up by setting the
PG_error flag on the page where the error occurred.  If we only set the
error on the mapping, we lose that granularity, because the mapping is
mostly at the file level (or VMA level for anon pages).

So I think the question for filesystem people from us would be do you
care about this accuracy?  If it's OK just to know an error occurred
somewhere in this file, then perhaps we don't need it.

James

> The main argument I could see for keeping it is that removing it 
> might subtly change the behavior of sync_file_range if you have tasks
> syncing different ranges in a file concurrently. I'm not sure if that 
> would break any guarantees though.
> 
> Even if we do need it, I think we might need some cleanup here 
> anyway. A lot of readpage operations end up setting that flag when 
> they hit an error. Isn't it wrong to return an error on fsync, just 
> because we had a read error somewhere in the file in a range that was
> never dirtied?
> 
> --
> [1]: there is another place in f2fs, but it's more or less equivalent 
> to the call site in __filemap_fdatawait_range.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
