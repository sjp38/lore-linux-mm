Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2426B0032
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 12:24:09 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so8832444pbb.19
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 09:24:08 -0700 (PDT)
Message-ID: <52543185.3060705@sr71.net>
Date: Tue, 08 Oct 2013 09:23:33 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmsplice: unmap gifted pages for recipient
References: <1381177293-27125-1-git-send-email-rcj@linux.vnet.ibm.com> <1381177293-27125-2-git-send-email-rcj@linux.vnet.ibm.com>
In-Reply-To: <1381177293-27125-2-git-send-email-rcj@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert C Jennings <rcj@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/07/2013 01:21 PM, Robert C Jennings wrote:
>  		spd.partial[page_nr].offset = loff;
>  		spd.partial[page_nr].len = this_len;
> +		spd.partial[page_nr].useraddr = index << PAGE_CACHE_SHIFT;
>  		len -= this_len;
>  		loff = 0;
>  		spd.nr_pages++;
> @@ -656,6 +702,7 @@ ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
>  		this_len = min_t(size_t, vec[i].iov_len, res);
>  		spd.partial[i].offset = 0;
>  		spd.partial[i].len = this_len;
> +		spd.partial[i].useraddr = (unsigned long)vec[i].iov_base;
>  		if (!this_len) {
>  			__free_page(spd.pages[i]);
>  			spd.pages[i] = NULL;
> @@ -1475,6 +1522,8 @@ static int get_iovec_page_array(const struct iovec __user *iov,
>  
>  			partial[buffers].offset = off;
>  			partial[buffers].len = plen;
> +			partial[buffers].useraddr = (unsigned long)base;
> +			base = (void*)((unsigned long)base + PAGE_SIZE);
>  
>  			off = 0;
>  			len -= plen;
> diff --git a/include/linux/splice.h b/include/linux/splice.h
> index 74575cb..56661e3 100644
> --- a/include/linux/splice.h
> +++ b/include/linux/splice.h
> @@ -44,6 +44,7 @@ struct partial_page {
>  	unsigned int offset;
>  	unsigned int len;
>  	unsigned long private;
> +	unsigned long useraddr;
>  };

"useraddr" confuses me.  You make it an 'unsigned long', yet two of the
three assignments are from "void __user *".  The other assignment:

	spd.partial[page_nr].useraddr = index << PAGE_CACHE_SHIFT;

'index' looks to be the offset inside the file, not a user address, so
I'm confused what that is doing.

Could you elaborate a little more on why 'useraddr' is suddenly needed
in these patches?  How is "index << PAGE_CACHE_SHIFT" a virtual address?
 Also, are we losing any of the advantages of sparse checking since
'useraddr' is without the __user annotation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
