Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id DF1CB6B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 16:58:26 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so3000128pbb.6
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 13:58:26 -0700 (PDT)
Date: Thu, 3 Oct 2013 13:58:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,fs: introduce helpers around i_mmap_mutex
Message-Id: <20131003135822.e0b2ca10fe5a460714bb82a3@linux-foundation.org>
In-Reply-To: <1380745066-9925-2-git-send-email-davidlohr@hp.com>
References: <1380745066-9925-1-git-send-email-davidlohr@hp.com>
	<1380745066-9925-2-git-send-email-davidlohr@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed,  2 Oct 2013 13:17:45 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:

> Various parts of the kernel acquire and release this mutex,
> so add i_mmap_lock_write() and immap_unlock_write() helper
> functions that will encapsulate this logic. The next patch
> will make use of these.
> 
> ...
>
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -478,6 +478,16 @@ struct block_device {
>  
>  int mapping_tagged(struct address_space *mapping, int tag);
>  
> +static inline void i_mmap_lock_write(struct address_space *mapping)
> +{
> +	mutex_lock(&mapping->i_mmap_mutex);
> +}

I don't understand the thinking behind the "_write".  There is no
"_read" and all callsites use "_write", so why not call it
i_mmap_lock()?

I *assume* the answer is "so we can later convert some sites to a new
i_mmap_lock_read()".  If so, the changelog should have discussed this. 
If not, still confused.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
