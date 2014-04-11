Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 881C182966
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 17:36:42 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so5732860pdi.5
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 14:36:42 -0700 (PDT)
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
        by mx.google.com with ESMTPS id wh4si4934166pbc.219.2014.04.11.14.36.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 14:36:41 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so5929105pab.13
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 14:36:41 -0700 (PDT)
Message-ID: <53486067.6090506@mit.edu>
Date: Fri, 11 Apr 2014 14:36:39 -0700
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] shm: add sealing API
References: <53470E26.2030306@cybernetics.com> <CANq1E4RWf_VbzF+dPYhzHKJvnrh86me5KajmaaB1u9f9FLzftA@mail.gmail.com> <5347451C.4060106@amacapital.net> <5347F188.10408@cybernetics.com> <CANq1E4T=38VLezGH2XUZ9kc=Vtp6Ca++-ATwmEfaXZS6UrTPig@mail.gmail.com>
In-Reply-To: <CANq1E4T=38VLezGH2XUZ9kc=Vtp6Ca++-ATwmEfaXZS6UrTPig@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>, Tony Battersby <tonyb@cybernetics.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Andy Lutomirski <luto@amacapital.net>

On 04/11/2014 02:31 PM, David Herrmann wrote:
> Hi
> 
> On Fri, Apr 11, 2014 at 3:43 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
>> Exactly.  For O_DIRECT, that would be the call to get_user_pages_fast()
>> from dio_refill_pages() in fs/direct-io.c, which is ultimately called
>> from blkdev_direct_IO().
> 
> If you drop mmap_sem after pinning a page without taking a write-ref,
> you break i_mmap_writable / VM_DENYWRITE. In memfd I rely on
> i_mmap_writable to work, same thing is done by exec() (and the old,
> now disabled, MAP_DENYWRITE).
> 
> I don't know whether I should care. I mean, everyone pinning pages and
> writing to it without holding the mmap_sem has to take a write-ref for
> each page or it breaks i_mmap_writable. So this seems to be a bug in
> direct-IO, not in anyone relying on it, right?

A quick grep of the kernel tree finds exactly zero code paths
incrementing i_mmap_writable outside of mmap and fork.

Or do you mean a different kind of write ref?  What am I missing here?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
