Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBE0A6B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 20:11:51 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id n127so160986849qkf.3
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 17:11:51 -0800 (PST)
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com. [209.85.220.177])
        by mx.google.com with ESMTPS id p33si104727qtb.236.2017.02.27.17.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 17:11:50 -0800 (PST)
Received: by mail-qk0-f177.google.com with SMTP id n127so126075843qkf.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 17:11:50 -0800 (PST)
Message-ID: <1488244308.7627.5.camel@redhat.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] do we really need PG_error at all?
From: Jeff Layton <jlayton@redhat.com>
Date: Mon, 27 Feb 2017 20:11:48 -0500
In-Reply-To: <87varvp5v1.fsf@notabene.neil.brown.name>
References: <1488120164.2948.4.camel@redhat.com>
	 <1488129033.4157.8.camel@HansenPartnership.com>
	 <877f4cr7ew.fsf@notabene.neil.brown.name>
	 <1488151856.4157.50.camel@HansenPartnership.com>
	 <874lzgqy06.fsf@notabene.neil.brown.name>
	 <1488208047.2876.6.camel@redhat.com>
	 <DC27F5BA-BCCA-41FF-8D41-7BB99AA4DB26@dilger.ca>
	 <87varvp5v1.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>, Andreas Dilger <adilger@dilger.ca>
Cc: linux-block@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>, lsf-pc <lsf-pc@lists.linuxfoundation.org>, Neil Brown <neilb@suse.de>, LKML <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, 2017-02-28 at 10:32 +1100, NeilBrown wrote:
> On Mon, Feb 27 2017, Andreas Dilger wrote:
> 
> > 
> > My thought is that PG_error is definitely useful for applications to get
> > correct errors back when doing write()/sync_file_range() so that they know
> > there is an error in the data that _they_ wrote, rather than receiving an
> > error for data that may have been written by another thread, and in turn
> > clearing the error from another thread so it *doesn't* know it had a write
> > error.
> 
> It might be useful in that way, but it is not currently used that way.
> Such usage would be a change in visible behaviour.
> 
> sync_file_range() calls filemap_fdatawait_range(), which calls
> filemap_check_errors().
> If there have been any errors in the file recently, inside or outside
> the range, the latter will return an error which will propagate up.
> 
> > 
> > As for stray sync() clearing PG_error from underneath an application, that
> > shouldn't happen since filemap_fdatawait_keep_errors() doesn't clear errors
> > and is used by device flushing code (fdatawait_one_bdev(), wait_sb_inodes()).
> 
> filemap_fdatawait_keep_errors() calls __filemap_fdatawait_range() which
> clears PG_error on every page.
> What it doesn't do is call filemap_check_errors(), and so doesn't clear
> AS_ENOSPC or AS_EIO.
> 
> 

I think it's helpful to get a clear idea of what happens now in the face
of errors and what we expect to happen, and I don't quite have that yet:

--------------------------8<-----------------------------
void page_endio(struct page *page, bool is_write, int err)
{
A A A A A A A A if (!is_write) {
A A A A A A A A A A A A A A A A if (!err) {
A A A A A A A A A A A A A A A A A A A A A A A A SetPageUptodate(page);
A A A A A A A A A A A A A A A A } else {
A A A A A A A A A A A A A A A A A A A A A A A A ClearPageUptodate(page);
A A A A A A A A A A A A A A A A A A A A A A A A SetPageError(page);
A A A A A A A A A A A A A A A A }
A A A A A A A A A A A A A A A A unlock_page(page);
A A A A A A A A } else {
A A A A A A A A A A A A A A A A if (err) {
A A A A A A A A A A A A A A A A A A A A A A A A SetPageError(page);
A A A A A A A A A A A A A A A A A A A A A A A A if (page->mapping)
A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A mapping_set_error(page->mapping, err);
A A A A A A A A A A A A A A A A }
A A A A A A A A A A A A A A A A end_page_writeback(page);
A A A A A A A A }
}
--------------------------8<-----------------------------

...not everything uses page_endio, but it's a good place to look since
we have both flavors of error handling in one place.

On a write error, we SetPageError and set the error in the mapping.

What I'm not clear on is:

1) what happens to the page at that point when we get a writeback error?
Does it just remain in-core and is allowed to service reads (assuming
that it was uptodate before)?

Can I redirty it and have it retry the write? Is there standard behavior
for this or is it just up to the whim of the filesystem?

I'll probably have questions about the read side as well, but for now it
looks like it's mostly used in an ad-hoc way to communicate errors
across subsystems (block to fs layer, for instance).
--
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
