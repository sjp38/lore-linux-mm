Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id ADF8B6B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 21:28:02 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so4690029pbb.22
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 18:28:01 -0700 (PDT)
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
        by mx.google.com with ESMTPS id f8si3127965pbc.415.2014.04.10.18.28.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 18:28:00 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so4600606pdj.17
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 18:28:00 -0700 (PDT)
Message-ID: <5347451C.4060106@amacapital.net>
Date: Thu, 10 Apr 2014 18:27:56 -0700
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] shm: add sealing API
References: <53470E26.2030306@cybernetics.com> <CANq1E4RWf_VbzF+dPYhzHKJvnrh86me5KajmaaB1u9f9FLzftA@mail.gmail.com>
In-Reply-To: <CANq1E4RWf_VbzF+dPYhzHKJvnrh86me5KajmaaB1u9f9FLzftA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>, Tony Battersby <tonyb@cybernetics.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

On 04/10/2014 05:22 PM, David Herrmann wrote:
> Hi
> 
> On Thu, Apr 10, 2014 at 11:33 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
>> For O_DIRECT the kernel pins the submitted pages in memory for DMA by
>> incrementing the page reference counts when the I/O is submitted,
>> allowing the pages to be modified by DMA even if they are no longer
>> mapped in the address space of the process.  This is different from a
>> regular read(), which uses the CPU to copy the data and will fail if the
>> pages are not mapped.
> 
> Can you please provide an example code-path? For instance,
> file_read_actor() does not pin any pages but only keeps the user-space
> address and resolves it once it has data to write.

This may be an issue for anything in the kernel that calls
get_user_pages and holds onto the result at any time that mmap_sem isn't
held.

I don't know exactly what does that, but RDMA comes to mind.  So does
(ugh!) vmsplice, although I suspect that vmsplice doesn't write.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
