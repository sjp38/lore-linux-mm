Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2C55A6B0260
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 17:46:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u78so586001wmd.4
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 14:46:54 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 64si4754600edo.541.2017.09.29.14.46.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 14:46:52 -0700 (PDT)
Subject: Re: [PATCH 15/15] afs: Use find_get_pages_range_tag()
References: <20170927160334.29513-1-jack@suse.cz>
 <20170927160334.29513-16-jack@suse.cz>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <ea1aa003-aaff-a17c-5a2c-28ed3c97a588@oracle.com>
Date: Fri, 29 Sep 2017 17:46:45 -0400
MIME-Version: 1.0
In-Reply-To: <20170927160334.29513-16-jack@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org

On 09/27/2017 12:03 PM, Jan Kara wrote:
> Use find_get_pages_range_tag() in afs_writepages_region() as we are
> interested only in pages from given range. Remove unnecessary code after
> this conversion.
>
> CC: David Howells <dhowells@redhat.com>
> CC: linux-afs@lists.infradead.org
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>   fs/afs/write.c | 11 ++---------
>   1 file changed, 2 insertions(+), 9 deletions(-)
>
> diff --git a/fs/afs/write.c b/fs/afs/write.c
> index 106e43db1115..d62a6b54152d 100644
> --- a/fs/afs/write.c
> +++ b/fs/afs/write.c
> @@ -497,20 +497,13 @@ static int afs_writepages_region(struct address_space *mapping,
>   	_enter(",,%lx,%lx,", index, end);
>   
>   	do {
> -		n = find_get_pages_tag(mapping, &index, PAGECACHE_TAG_DIRTY,
> -				       1, &page);
> +		n = find_get_pages_range_tag(mapping, &index, end,
> +					PAGECACHE_TAG_DIRTY, 1, &page);
>   		if (!n)
>   			break;
>   
>   		_debug("wback %lx", page->index);
>   
> -		if (page->index > end) {
> -			*_next = index;
> -			put_page(page);
> -			_leave(" = 0 [%lx]", *_next);
> -			return 0;
> -		}
> -
>   		/* at this point we hold neither mapping->tree_lock nor lock on
>   		 * the page itself: the page may be truncated or invalidated
>   		 * (changing page->mapping to NULL), or even swizzled back from

There's also one other caller of find_get_pages_tag that could be 
converted, wdata_alloc_and_fillpages.  Since the 256 max mentioned in 
the comment below no longer seems to apply, maybe something like this?:

diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 92fdf9c35de2..4dbd24231e8a 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1963,31 +1963,14 @@ wdata_alloc_and_fillpages(pgoff_t tofind, struct 
address_space *mapping,
                           pgoff_t end, pgoff_t *index,
                           unsigned int *found_pages)
  {
-       unsigned int nr_pages;
-       struct page **pages;
-       struct cifs_writedata *wdata;
-
-       wdata = cifs_writedata_alloc((unsigned int)tofind,
-                                    cifs_writev_complete);
+       struct cifs_writedata *wdata = 
cifs_writedata_alloc((unsigned)tofind,
+ cifs_writev_complete);
         if (!wdata)
                 return NULL;

-       /*
-        * find_get_pages_tag seems to return a max of 256 on each
-        * iteration, so we must call it several times in order to
-        * fill the array or the wsize is effectively limited to
-        * 256 * PAGE_SIZE.
-        */
-       *found_pages = 0;
-       pages = wdata->pages;
-       do {
-               nr_pages = find_get_pages_tag(mapping, index,
-                                             PAGECACHE_TAG_DIRTY, tofind,
-                                             pages);
-               *found_pages += nr_pages;
-               tofind -= nr_pages;
-               pages += nr_pages;
-       } while (nr_pages && tofind && *index <= end);
+       *found_pages = find_get_pages_range_tag(mapping, index, end,
+                                               PAGECACHE_TAG_DIRTY, tofind,
+                                               wdata->pages);

         return wdata;
  }

Otherwise the set looks good, so for the whole thing,

Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
