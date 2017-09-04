Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5076B04AB
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 08:30:43 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n33so246891wrn.6
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 05:30:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y9si5270864wrg.186.2017.09.04.05.30.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Sep 2017 05:30:41 -0700 (PDT)
Date: Mon, 4 Sep 2017 14:30:39 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Message-ID: <20170904123039.GA5664@quack2.suse.cz>
References: <CABXGCsOL+_OgC0dpO1+Zeg=iu7ryZRZT4S7k-io8EGB0ZRgZGw@mail.gmail.com>
 <20170903074306.GA8351@infradead.org>
 <CABXGCsMmEvEh__R2L47jqVnxv9XDaT_KP67jzsUeDLhF2OuOyA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="vkogqOf2sHV7VnPd"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CABXGCsMmEvEh__R2L47jqVnxv9XDaT_KP67jzsUeDLhF2OuOyA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Sun 03-09-17 19:08:54, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2 wrote:
> On 3 September 2017 at 12:43, Christoph Hellwig <hch@infradead.org> wrote:
> >
> > This is:
> >
> >         bh = head = page_buffers(page);
> >
> > Which looks odd and like some sort of VM/writeback change might
> > have triggered that we get a page without buffers, despite always
> > creating buffers in iomap_begin/end and page_mkwrite.
> >
> > Ccing linux-mm if anything odd happen in that area recently.
> >
> > Can you tell anything about the workload you are running?
> >
> 
> On XFS partition stored launched KVM VM images, + home partition with
> Google Chrome profiles.
> Seems the bug triggering by high memory consumption and using swap
> which two times larger than system memory.
> I saw that it happens when swap has reached size of system memory.

Can you reproduce this? I've seen one occurence of this on our distro
4.4-based kernel but we were never able to reproduce and find the culprit.
If you can reproduce, could you run with the attached debug patch to see
whether the WARN_ON triggers? Because my suspicion is that there is some
subtle race in page table teardown vs writeback vs page reclaim which can
result in page being dirtied without filesystem being notified about it (I
have seen very similar oops for ext4 as well which leads me to suspicion
this is a generic issue). Thanks!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--vkogqOf2sHV7VnPd
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-xfs-Debug-when-page-can-get-dirty-without-buffers.patch"


--vkogqOf2sHV7VnPd--
