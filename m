Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5FEC482966
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 17:31:28 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id lx4so6012732iec.10
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 14:31:28 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id mx10si7090235icb.32.2014.04.11.14.31.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 14:31:27 -0700 (PDT)
Received: by mail-ie0-f175.google.com with SMTP id to1so5957003ieb.20
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 14:31:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5347F188.10408@cybernetics.com>
References: <53470E26.2030306@cybernetics.com>
	<CANq1E4RWf_VbzF+dPYhzHKJvnrh86me5KajmaaB1u9f9FLzftA@mail.gmail.com>
	<5347451C.4060106@amacapital.net>
	<5347F188.10408@cybernetics.com>
Date: Fri, 11 Apr 2014 23:31:27 +0200
Message-ID: <CANq1E4T=38VLezGH2XUZ9kc=Vtp6Ca++-ATwmEfaXZS6UrTPig@mail.gmail.com>
Subject: Re: [PATCH 2/6] shm: add sealing API
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Andy Lutomirski <luto@amacapital.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

Hi

On Fri, Apr 11, 2014 at 3:43 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
> Exactly.  For O_DIRECT, that would be the call to get_user_pages_fast()
> from dio_refill_pages() in fs/direct-io.c, which is ultimately called
> from blkdev_direct_IO().

If you drop mmap_sem after pinning a page without taking a write-ref,
you break i_mmap_writable / VM_DENYWRITE. In memfd I rely on
i_mmap_writable to work, same thing is done by exec() (and the old,
now disabled, MAP_DENYWRITE).

I don't know whether I should care. I mean, everyone pinning pages and
writing to it without holding the mmap_sem has to take a write-ref for
each page or it breaks i_mmap_writable. So this seems to be a bug in
direct-IO, not in anyone relying on it, right?

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
