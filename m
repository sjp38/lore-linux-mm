Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id E02726B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 16:03:15 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id pp5so10656341pac.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 13:03:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p6si7916662pfb.185.2016.07.27.13.03.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 13:03:15 -0700 (PDT)
Date: Wed, 27 Jul 2016 13:03:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kexec: add restriction on kexec_load() segment sizes
Message-Id: <20160727130313.c9afc876d405cc2e10da976c@linux-foundation.org>
In-Reply-To: <57983425.4090901@huawei.com>
References: <1469502219-24140-1-git-send-email-zhongjiang@huawei.com>
	<20160726125501.69c8186ab9c3b1cef89899d4@linux-foundation.org>
	<57983425.4090901@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: ebiederm@xmission.com, linux-mm@kvack.org, mm-commits@vger.kernel.org

On Wed, 27 Jul 2016 12:10:13 +0800 zhong jiang <zhongjiang@huawei.com> wrote:

> >> +	for (i = 0; i < nr_segments; i++) {
> >> +		if (PAGE_COUNT(image->segment[i].memsz) > totalram_pages / 2
> >> +				|| PAGE_COUNT(total_segments) > totalram_pages / 2)
> >> +			return result;
> > And I don't think we need this?  Unless we're worried about the sum of
> > all segments overflowing an unsigned long, which I guess is possible. 
> > But if we care about that we should handle it in the next statement:
> >
> >> +		total_segments += image->segment[i].memsz;
> > Should this be 
> >
> > 		total_pages += PAGE_COUNT(image->segment[i].memsz);
>   ok
> > ?  I think "yes", if the segments are allocated separately and "no" if
> > they are all allocated in a big blob.
>    There is a possible that  most of segments size will exceed half of  the real memory.
> 
>   if (PAGE_COUNT(image->segment[i].memsz) > totalram_pages / 2
> 	|| total_pages > totalram_pages / 2)
>   I guess that it is ok , we should bail out timely when it happens to the condition.
>   
>   is right ?
> 
>  your mean that above condition is no need. In the end, we check the overflow just one time.
>   or I misunderstand.

It doesn't matter much.  Actually I misread the code a bit.  How about

	for (i = 0; i < nr_segments; i++) {
		unsigned long seg_pages = PAGE_COUNT(image->segment[i].memsz);

		if (seg_pages > totalram_pages / 2))
			return -EINVAL;

		total_pages += seg_pages;

		if (total_pages > totalram_pages / 2)
			return -EINVAL;
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
