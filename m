Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id A81846B0032
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 01:13:43 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so3667257wid.17
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 22:13:43 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id s5si21216511wju.40.2014.12.19.22.13.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 22:13:43 -0800 (PST)
Date: Sat, 20 Dec 2014 06:13:37 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 4/5] swapfile: use ->read_iter and ->write_iter
Message-ID: <20141220061337.GB22149@ZenIV.linux.org.uk>
References: <cover.1419044605.git.osandov@osandov.com>
 <d8819b57849221b3db7c479f070067808912f0d5.1419044605.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d8819b57849221b3db7c479f070067808912f0d5.1419044605.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On Fri, Dec 19, 2014 at 07:18:28PM -0800, Omar Sandoval wrote:

> +		ret = swap_file->f_op->read_iter(&kiocb, &to);
> +		if (ret == PAGE_SIZE) {
> +			SetPageUptodate(page);
>  			count_vm_event(PSWPIN);
> +			ret = 0;
> +		} else {
> +			ClearPageUptodate(page);
> +			SetPageError(page);
> +		}
> +		unlock_page(page);

Umm...  What's to guarantee that ->read_iter() won't try lock_page() on what
turns out to be equal to page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
