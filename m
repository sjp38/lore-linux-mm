Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9DBE46B0035
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 09:41:06 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id e16so5985507qcx.27
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 06:41:06 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id m34si3278480qge.138.2014.04.11.06.41.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 06:41:06 -0700 (PDT)
Message-ID: <5347F188.10408@cybernetics.com>
Date: Fri, 11 Apr 2014 09:43:36 -0400
From: Tony Battersby <tonyb@cybernetics.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] shm: add sealing API
References: <53470E26.2030306@cybernetics.com> <CANq1E4RWf_VbzF+dPYhzHKJvnrh86me5KajmaaB1u9f9FLzftA@mail.gmail.com> <5347451C.4060106@amacapital.net>
In-Reply-To: <5347451C.4060106@amacapital.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: David Herrmann <dh.herrmann@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

Andy Lutomirski wrote:
> On 04/10/2014 05:22 PM, David Herrmann wrote:
>   
>> Hi
>>
>> On Thu, Apr 10, 2014 at 11:33 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
>>     
>>> For O_DIRECT the kernel pins the submitted pages in memory for DMA by
>>> incrementing the page reference counts when the I/O is submitted,
>>> allowing the pages to be modified by DMA even if they are no longer
>>> mapped in the address space of the process.  This is different from a
>>> regular read(), which uses the CPU to copy the data and will fail if the
>>> pages are not mapped.
>>>       
>> Can you please provide an example code-path? For instance,
>> file_read_actor() does not pin any pages but only keeps the user-space
>> address and resolves it once it has data to write.
>>     
>
> This may be an issue for anything in the kernel that calls
> get_user_pages and holds onto the result at any time that mmap_sem isn't
> held.
>
>   

Exactly.  For O_DIRECT, that would be the call to get_user_pages_fast()
from dio_refill_pages() in fs/direct-io.c, which is ultimately called
from blkdev_direct_IO().

>From the comment for get_user_pages_fast(): "Attempt to pin user pages
in memory..."

Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
