Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id BCBB56B0006
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 11:33:46 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id w135so5328806oie.11
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 08:33:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m69si2442550otc.268.2018.02.01.08.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 08:33:46 -0800 (PST)
Date: Thu, 1 Feb 2018 11:33:42 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Killing reliance on struct page->mapping
Message-ID: <20180201163341.GB3085@redhat.com>
References: <20180130004347.GD4526@redhat.com>
 <20180131165646.GI29051@ZenIV.linux.org.uk>
 <20180131174245.GE2912@redhat.com>
 <20180131175558.GA30522@ZenIV.linux.org.uk>
 <20180131181356.GG2912@redhat.com>
 <35c2908e-b6ba-fc29-0a3c-15cb8cf00256@kernel.dk>
 <20180201155748.GA3085@redhat.com>
 <0badeb21-c08b-80bf-6631-a18c67696f74@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0badeb21-c08b-80bf-6631-a18c67696f74@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-block@vger.kernel.org

On Thu, Feb 01, 2018 at 09:00:13AM -0700, Jens Axboe wrote:
> On 2/1/18 8:57 AM, Jerome Glisse wrote:
> > On Thu, Feb 01, 2018 at 08:34:58AM -0700, Jens Axboe wrote:
> >> On 1/31/18 11:13 AM, Jerome Glisse wrote:
> >>> That's one solution, another one is to have struct bio_vec store
> >>> buffer_head pointer and not page pointer, from buffer_head you can
> >>> find struct page and using buffer_head and struct page pointer you
> >>> can walk the KSM rmap_item chain to find back the mapping. This
> >>> would be needed on I/O error for pending writeback of a newly write
> >>> protected page, so one can argue that the overhead of the chain lookup
> >>> to find back the mapping against which to report IO error, is an
> >>> acceptable cost.
> >>
> >> Ehm nope. bio_vec is a generic container for pages, requiring
> >> buffer_heads to be able to do IO would be insanity.
> > 
> > The extra pointer dereference would be killing performance ?
> 
> No, I'm saying that requiring a buffer_head to be able to do IO
> is insanity. That's how things used to be in the pre-2001 days.

Oh ok i didn't thought it would be a problem, iirc it seemed to me that
nobh fs were allocating a buffer_head just do I/O but my memory is probably
confuse. Well i can use the one bit flag idea then allmost same semantic
patch but if flag is (ie page is write protected)set then to get the real
page address you have to do an extra memory dereference. So it would add
an extra test for common existing case and an extra derefence for the write
protect case. No need for buffer_head.

Thanks for pointing out this buffer_head thing :)

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
