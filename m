Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2FC2808A2
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 22:08:56 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id 9so165932606qkk.6
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 19:08:56 -0800 (PST)
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com. [209.85.220.171])
        by mx.google.com with ESMTPS id r11si7118935qtc.213.2017.03.09.19.08.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 19:08:55 -0800 (PST)
Received: by mail-qk0-f171.google.com with SMTP id 1so149752683qkl.3
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 19:08:54 -0800 (PST)
Message-ID: <1489115329.15257.1.camel@redhat.com>
Subject: Re: [PATCH v2 3/9] mm: clear any AS_* errors when returning error
 on any fsync or close
From: Jeff Layton <jlayton@redhat.com>
Date: Thu, 09 Mar 2017 22:08:49 -0500
In-Reply-To: <20170310000939.GC30285@linux.intel.com>
References: <20170308162934.21989-1-jlayton@redhat.com>
	 <20170308162934.21989-4-jlayton@redhat.com>
	 <20170310000939.GC30285@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: viro@zeniv.linux.org.uk, akpm@linux-foundation.org, konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, jack@suse.cz, neilb@suse.com, openosd@gmail.com, adilger@dilger.ca, James.Bottomley@HansenPartnership.com

On Thu, 2017-03-09 at 17:09 -0700, Ross Zwisler wrote:
> On Wed, Mar 08, 2017 at 11:29:28AM -0500, Jeff Layton wrote:
> > Currently we don't clear the address space error when there is a -EIO
> > error on fsynci, due to writeback initiation failure. If writes fail
> 
> 	   fsync
> 
> > with -EIO and the mapping is flagged with an AS_EIO or AS_ENOSPC error,
> > then we can end up returning errors on two fsync calls, even when a
> > write between them succeeded (or there was no write).
> > 
> > Ensure that we also clear out any mapping errors when initiating
> > writeback fails with -EIO in filemap_write_and_wait and
> > filemap_write_and_wait_range.
> > 
> > Suggested-by: Jan Kara <jack@suse.cz>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  mm/filemap.c | 20 ++++++++++++++++++--
> >  1 file changed, 18 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 1694623a6289..fc123b9833e1 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -488,7 +488,7 @@ EXPORT_SYMBOL(filemap_fdatawait);
> >  
> >  int filemap_write_and_wait(struct address_space *mapping)
> >  {
> > -	int err = 0;
> > +	int err;
> >  
> >  	if ((!dax_mapping(mapping) && mapping->nrpages) ||
> >  	    (dax_mapping(mapping) && mapping->nrexceptional)) {
> > @@ -499,10 +499,18 @@ int filemap_write_and_wait(struct address_space *mapping)
> >  		 * But the -EIO is special case, it may indicate the worst
> >  		 * thing (e.g. bug) happened, so we avoid waiting for it.
> >  		 */
> > -		if (err != -EIO) {
> > +		if (likely(err != -EIO)) {
> 
> The above two cleanup changes were made only to filemap_write_and_wait(), but
> should also probably be done to filemap_write_and_wait_range() to keep them as
> consistent as possible?

Thanks, I fixed that in the patch in my tree. Unfortunately, as Neil
pointed out, there is a bigger problem here...

There are a lot of callers of the filemap_write_and_wait* functions
that never check the return code at all, and some others that call this
from codepaths that where we can't report errors properly. Yet, the
mapping error gets cleared out anyway, which means that fsync will
probably never see it.

So while I doubt this patch will make anything worse,A I think we have
to look at fixing those problems first. We need to ensure that when
filemap_check_errors is called, that we're in a codepath where we can
actually report the error to something that can interpret it properly.
Basically, only in write, fsync, msync or close codepaths. For the
others, we need to use something like filemap_fdatawait_keep_errors so
that we don't end up dropping writeback errors onto the floor.

I'm going to look at fixing that up first (maybe as a preliminary
series to this one). There are a lot of callers though, and I don't see
a way around having to go and review all of these callsites
individually. Maybe it's be best to just lift the filemap_check_errors
calls higher in the call stack to ensure that? Not sure...

Anyway...I'm first trying to collect a list of what I think needs
fixing here, and figure out how to break all of this up into manageable
pieces and order it sanely.
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
