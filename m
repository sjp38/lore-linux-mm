Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E22016B026C
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 09:54:56 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g5-v6so5438102edp.1
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 06:54:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l22-v6si1448424eda.370.2018.08.07.06.54.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 06:54:55 -0700 (PDT)
Date: Tue, 7 Aug 2018 15:54:53 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: adjust max read count in generic_file_buffered_read()
Message-ID: <20180807135453.nhatdtw25wa6dtzm@quack2.suse.cz>
References: <20180719081726.3341-1-cgxu519@gmx.com>
 <20180719085812.sjup2odrjyuigt3l@quack2.suse.cz>
 <20180720161429.d63dccb9f66799dc0ff74dba@linux-foundation.org>
 <20180806102203.hmobd26cujmlfcsw@quack2.suse.cz>
 <20180806155927.4740babd057df9d5078281b1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806155927.4740babd057df9d5078281b1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Chengguang Xu <cgxu519@gmx.com>, mgorman@techsingularity.net, jlayton@redhat.com, ak@linux.intel.com, mawilcox@microsoft.com, tim.c.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>

On Mon 06-08-18 15:59:27, Andrew Morton wrote:
> On Mon, 6 Aug 2018 12:22:03 +0200 Jan Kara <jack@suse.cz> wrote:
> 
> > On Fri 20-07-18 16:14:29, Andrew Morton wrote:
> > > On Thu, 19 Jul 2018 10:58:12 +0200 Jan Kara <jack@suse.cz> wrote:
> > > 
> > > > On Thu 19-07-18 16:17:26, Chengguang Xu wrote:
> > > > > When we try to truncate read count in generic_file_buffered_read(),
> > > > > should deliver (sb->s_maxbytes - offset) as maximum count not
> > > > > sb->s_maxbytes itself.
> > > > > 
> > > > > Signed-off-by: Chengguang Xu <cgxu519@gmx.com>
> > > > 
> > > > Looks good to me. You can add:
> > > > 
> > > > Reviewed-by: Jan Kara <jack@suse.cz>
> > > 
> > > Yup.
> > > 
> > > What are the runtime effects of this bug?
> > 
> > Good question. I think ->readpage() could be called for index beyond
> > maximum file size supported by the filesystem leading to weird filesystem
> > behavior due to overflows in internal calculations.
> > 
> 
> Sure.  But is it possible for userspace to trigger this behaviour? 
> Possibly all callers have already sanitized the arguments by this stage
> in which case the statement is arguably redundant.

So I don't think there's any sanitization going on before
generic_file_buffered_read(). E.g. I don't see any s_maxbytes check on
ksys_read() -> vfs_read() -> __vfs_read() -> new_sync_read() ->
call_read_iter() -> generic_file_read_iter() ->
generic_file_buffered_read() path... However now thinking about this again:
We are guaranteed i_size is within s_maxbytes (places modifying i_size
are checking for this) and generic_file_buffered_read() stops when it
should read beyond i_size. So in the end I don't think there's any breakage
possible and the patch is not necessary?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
