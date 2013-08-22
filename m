Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 93D9A6B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 10:59:18 -0400 (EDT)
Subject: Re: [PATCH] mm, fs: avoid page allocation beyond i_size on read
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <20130822143041.EC9F1E0090@blue.fi.intel.com>
References: 
	 <1377099441-2224-1-git-send-email-kirill.shutemov@linux.intel.com>
	 <1377100012.2738.28.camel@menhir>
	 <20130821160817.940D3E0090@blue.fi.intel.com>
	 <1377103332.2738.37.camel@menhir>
	 <20130821135821.fc8f5a2551a28c9ce9c4b049@linux-foundation.org>
	 <1377163725.2720.18.camel@menhir>
	 <20130822130527.71C0AE0090@blue.fi.intel.com>
	 <1377178420.2720.51.camel@menhir>
	 <20130822143041.EC9F1E0090@blue.fi.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 22 Aug 2013 15:59:25 +0100
Message-ID: <1377183565.2720.72.camel@menhir>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, NeilBrown <neilb@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hi,

On Thu, 2013-08-22 at 17:30 +0300, Kirill A. Shutemov wrote:
[snip]
> > Andrew's proposed solution makes sense to me, and is probably the
> > easiest way to solve this.
> 
> Move check to no_cached_page?
Yes

> I don't see how it makes any difference for
> page cache miss case: we anyway exclude ->readpage() if it's beyond local
> i_size.
> And for cache hit local i_size will be most likely cover locally cached
> pages.
The difference is that as the function is currently written, you cannot
get to no_cached_page without first calling page_cache_sync_readahead(),
i.e. ->readpages() so that i_size will have been updated, even if
->readpages() doesn't return any read-ahead pages.

I guess that it is not very obvious that a call to ->readpages is hidden
in page_cache_sync_readahead() but that is the path that should in the
common case provide the pages from the fs, rather than the ->readpage
call thats further down do_generic_file_read()

> 
> Should we introduce an aop which can be called before i_size check in
> no_cached_page path to refresh local i_size?
> 
No, due to the call to ->readpages via page_cache_sync_readahead() it
should not be necessary.

[snip]
> > Yes, it is a different use case, but the same issue applies that without
> > a prior call to ->readpage() or ->readpages() then i_size may not be
> > correct.
> 
> I believe it's correct, but stale. I think it makes difference in the
> context. Use stale value for read vs. write race is okay, but not for read
> vs. truncate.
> 
Well stale means possibly incorrect. We just don't know until we've got
the cluster lock whether the data is correct or not, so it might as well
be incorrect for all the difference it makes. As soon as we drop the
cluster lock, the i_size may change. We always invalidate the page cache
for the inode if we drop the cluster lock though, so that we know that
->readpage(s) will be called again on the next read to refresh the
information.

Obviously if someone called fstat, for example, on the inode in the mean
time, that would also result in a refresh, as would a number of other fs
operations.

In both the page_ok: and proposed no_cached_page: situations the i_size
can change as soon as the ->readpages call has completed, but the time
difference is very small, so that returning an EOF indication in that
case is not a problem. The issue with not doing a ->readpages() call
prior to the i_size check is that the size may have been sitting around
stale for hours, days or weeks, having been updated on other nodes, and
thus it would give the wrong result.

> Will i_size be set to correct value on the first file open (struct inode
> creation)?
> 
Yes, open has to read the inode in order to know what the permissions
are. So the i_size will be set then, along with all the other inode
information.

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
