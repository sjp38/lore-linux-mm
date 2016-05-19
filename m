Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB4566B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 06:17:15 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id d197so14620646ioe.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 03:17:15 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id ko8si5870207oeb.87.2016.05.19.03.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 03:17:14 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id t140so15310967oie.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 03:17:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160519090521.GA26114@dhcp22.suse.cz>
References: <CAJfpeguD-S=CEogqcDOYAYJBzfyJG=MMKyFfpMo55bQk7d0_TQ@mail.gmail.com>
	<20160519090521.GA26114@dhcp22.suse.cz>
Date: Thu, 19 May 2016 12:17:14 +0200
Message-ID: <CAJfpegvqPrP=AtaOSwMX1s=-oVAEE97NMwEHUkg93dBWvOykHw@mail.gmail.com>
Subject: Re: sharing page cache pages between multiple mappings
From: Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>

On Thu, May 19, 2016 at 11:05 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 19-05-16 10:20:13, Miklos Szeredi wrote:
>> Has anyone thought about sharing pages between multiple files?
>>
>> The obvious application is for COW filesytems where there are
>> logically distinct files that physically share data and could easily
>> share the cache as well if there was infrastructure for it.
>
> FYI this has been discussed at LSFMM this year[1]. I wasn't at the
> session so cannot tell you any details but the LWN article covers it at
> least briefly.

Cool, so it's not such a crazy idea.

Darrick, would you mind briefly sharing your ideas regarding this?

The use case I have is fixing overlayfs weird behavior. The following
may result in "buf" not matching "data":

    int fr = open("foo", O_RDONLY);
    int fw = open("foo", O_RDWR);
    write(fw, data, sizeof(data));
    read(fr, buf, sizeof(data));

The reason is that "foo" is on a read-only layer, and opening it for
read-write triggers copy-up into a read-write layer.  However the old,
read-only open still refers to the unmodified file.

Fixing this properly requires that when opening a file, we don't
delegate operations fully to the underlying file, but rather allow
sharing of pages from underlying file until the file is copied up.  At
that point we switch to sharing pages with the read-write copy.

Another use case is direct access in fuse:  people often want I/O
operations on a fuse file to go directly to an underlying file.  Doing
this properly requires sharing pages between the real, underlying file
and the fuse file.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
