Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB4A16B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 04:57:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h26-v6so666982eds.14
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 01:57:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18-v6si3475469edl.68.2018.08.08.01.57.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 01:57:48 -0700 (PDT)
Date: Wed, 8 Aug 2018 10:57:47 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: adjust max read count in generic_file_buffered_read()
Message-ID: <20180808085747.GE15413@quack2.suse.cz>
References: <20180719081726.3341-1-cgxu519@gmx.com>
 <20180719085812.sjup2odrjyuigt3l@quack2.suse.cz>
 <20180720161429.d63dccb9f66799dc0ff74dba@linux-foundation.org>
 <20180806102203.hmobd26cujmlfcsw@quack2.suse.cz>
 <20180806155927.4740babd057df9d5078281b1@linux-foundation.org>
 <20180807135453.nhatdtw25wa6dtzm@quack2.suse.cz>
 <7be05929-a5d0-e0b0-9d48-705c3840ee95@gmx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7be05929-a5d0-e0b0-9d48-705c3840ee95@gmx.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgxu519 <cgxu519@gmx.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, jlayton@redhat.com, ak@linux.intel.com, mawilcox@microsoft.com, tim.c.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Wed 08-08-18 08:57:13, cgxu519 wrote:
> On 08/07/2018 09:54 PM, Jan Kara wrote:
> > On Mon 06-08-18 15:59:27, Andrew Morton wrote:
> > > On Mon, 6 Aug 2018 12:22:03 +0200 Jan Kara <jack@suse.cz> wrote:
> > > 
> > > > On Fri 20-07-18 16:14:29, Andrew Morton wrote:
> > > > > On Thu, 19 Jul 2018 10:58:12 +0200 Jan Kara <jack@suse.cz> wrote:
> > > > > 
> > > > > > On Thu 19-07-18 16:17:26, Chengguang Xu wrote:
> > > > > > > When we try to truncate read count in generic_file_buffered_read(),
> > > > > > > should deliver (sb->s_maxbytes - offset) as maximum count not
> > > > > > > sb->s_maxbytes itself.
> > > > > > > 
> > > > > > > Signed-off-by: Chengguang Xu <cgxu519@gmx.com>
> > > > > > Looks good to me. You can add:
> > > > > > 
> > > > > > Reviewed-by: Jan Kara <jack@suse.cz>
> > > > > Yup.
> > > > > 
> > > > > What are the runtime effects of this bug?
> > > > Good question. I think ->readpage() could be called for index beyond
> > > > maximum file size supported by the filesystem leading to weird filesystem
> > > > behavior due to overflows in internal calculations.
> > > > 
> > > Sure.  But is it possible for userspace to trigger this behaviour?
> > > Possibly all callers have already sanitized the arguments by this stage
> > > in which case the statement is arguably redundant.
> > So I don't think there's any sanitization going on before
> > generic_file_buffered_read(). E.g. I don't see any s_maxbytes check on
> > ksys_read() -> vfs_read() -> __vfs_read() -> new_sync_read() ->
> > call_read_iter() -> generic_file_read_iter() ->
> > generic_file_buffered_read() path... However now thinking about this again:
> > We are guaranteed i_size is within s_maxbytes (places modifying i_size
> > are checking for this) and generic_file_buffered_read() stops when it
> > should read beyond i_size. So in the end I don't think there's any breakage
> > possible and the patch is not necessary?
> > 
> I think most of time i_size is within s_maxbytes in local filesystem,
> but consider network filesystem, write big file in 64bit client and
> read in 32bit client, in this case maybe generic_file_buffered_read()
> can read more than s_maxbytes, right?

I'd consider this an internal problem in the implementation of the
networking filesystem. Not something VFS should care about. It's similar to
a normal filesystem loading corrupted file size from disk...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
