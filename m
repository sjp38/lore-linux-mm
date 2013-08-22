Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 3041D6B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 11:34:49 -0400 (EDT)
Subject: Re: [PATCH] mm, fs: avoid page allocation beyond i_size on read
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <20130822151614.2F11DE0090@blue.fi.intel.com>
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
	 <1377183565.2720.72.camel@menhir>
	 <20130822151614.2F11DE0090@blue.fi.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 22 Aug 2013 16:34:55 +0100
Message-ID: <1377185695.2720.79.camel@menhir>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, NeilBrown <neilb@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hi,

On Thu, 2013-08-22 at 18:16 +0300, Kirill A. Shutemov wrote:
> Steven Whitehouse wrote:
> > Hi,
> > 
> > On Thu, 2013-08-22 at 17:30 +0300, Kirill A. Shutemov wrote:
> > [snip]
> > > > Andrew's proposed solution makes sense to me, and is probably the
> > > > easiest way to solve this.
> > > 
> > > Move check to no_cached_page?
> > Yes
> > 
> > > I don't see how it makes any difference for
> > > page cache miss case: we anyway exclude ->readpage() if it's beyond local
> > > i_size.
> > > And for cache hit local i_size will be most likely cover locally cached
> > > pages.
> > The difference is that as the function is currently written, you cannot
> > get to no_cached_page without first calling page_cache_sync_readahead(),
> > i.e. ->readpages() so that i_size will have been updated, even if
> > ->readpages() doesn't return any read-ahead pages.
> > 
> > I guess that it is not very obvious that a call to ->readpages is hidden
> > in page_cache_sync_readahead() but that is the path that should in the
> > common case provide the pages from the fs, rather than the ->readpage
> > call thats further down do_generic_file_read()
> 
> I've checked the codepath before and to me it looks like ->readpages()
> will not be called beyond i_size. Codepath is:
> 
> page_cache_sync_readahead()
>  ondemand_readahead()
>   __do_page_cache_readahead()
>    read_pages()
>     mapping->a_ops->readpages()
> 
> But if you check __do_page_cache_readahead():
> 
> 152 static int
> 153 __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
> 154                         pgoff_t offset, unsigned long nr_to_read,
> 155                         unsigned long lookahead_size)
> 156 {
> ...
> 163         loff_t isize = i_size_read(inode);
> 164
> 165         if (isize == 0)
> 166                 goto out;
> 167
> 168         end_index = ((isize - 1) >> PAGE_CACHE_SHIFT);
> ...
> 173         for (page_idx = 0; page_idx < nr_to_read; page_idx++) {
> 174                 pgoff_t page_offset = offset + page_idx;
> 175
> 176                 if (page_offset > end_index)
> 177                         break;
> ...
> 193         }
> ...
> 200         if (ret)
> 201                 read_pages(mapping, filp, &page_pool, ret);
> 202         BUG_ON(!list_empty(&page_pool));
> 203 out:
> 204         return ret;
> 205 }
> 
> Do I miss something?
> 

Hrm. It looks like that Andrew's proposal is not going to work then :(

The trouble is that readahead has broken silently in this one case,
since the net result of the readahead not going ahead at this point, is
that ->readpage will be called later on. So in the cases where it
matters (i.e. i_size updated remotely), we'd probably not have noticed
it before as the read will still return successfully.

That is real problem though... so maybe this isn't as easy as I'd first
thought,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
