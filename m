Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id A29E86B02B5
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:18:16 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id n68so19362663itn.4
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 13:18:16 -0800 (PST)
Received: from mail-it0-x230.google.com (mail-it0-x230.google.com. [2607:f8b0:4001:c0b::230])
        by mx.google.com with ESMTPS id a76si3211219ita.52.2016.11.15.13.18.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 13:18:15 -0800 (PST)
Received: by mail-it0-x230.google.com with SMTP id c20so174920179itb.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 13:18:15 -0800 (PST)
Subject: Re: [PATCH/RFC] mm: don't cap request size based on read-ahead
 setting
References: <7d8739c2-09ea-8c1f-cef7-9b8b40766c6a@kernel.dk>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <6e924b0e-a2fc-5983-fd7d-80c956308937@kernel.dk>
Date: Tue, 15 Nov 2016 14:18:12 -0700
MIME-Version: 1.0
In-Reply-To: <7d8739c2-09ea-8c1f-cef7-9b8b40766c6a@kernel.dk>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 11/10/2016 10:00 AM, Jens Axboe wrote:
> Hi,
>
> We ran into a funky issue, where someone doing 256K buffered reads saw
> 128K requests at the device level. Turns out it is read-ahead capping
> the request size, since we use 128K as the default setting. This doesn't
> make a lot of sense - if someone is issuing 256K reads, they should see
> 256K reads, regardless of the read-ahead setting.
>
> To make matters more confusing, there's an odd interaction with the
> fadvise hint setting. If we tell the kernel we're doing sequential IO on
> this file descriptor, we can get twice the read-ahead size. But if we
> tell the kernel that we are doing random IO, hence disabling read-ahead,
> we do get nice 256K requests at the lower level. An application
> developer will be, rightfully, scratching his head at this point,
> wondering wtf is going on. A good one will dive into the kernel source,
> and silently weep.
>
> This patch introduces a bdi hint, io_pages. This is the soft max IO size
> for the lower level, I've hooked it up to the bdev settings here.
> Read-ahead is modified to issue the maximum of the user request size,
> and the read-ahead max size, but capped to the max request size on the
> device side. The latter is done to avoid reading ahead too much, if the
> application asks for a huge read. With this patch, the kernel behaves
> like the application expects.

Any comments on this?

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
