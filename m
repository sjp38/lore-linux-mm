Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7776B0037
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 10:03:55 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id x13so11116250qcv.6
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 07:03:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id iz10si6566684qcb.68.2014.02.03.07.03.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Feb 2014 07:03:54 -0800 (PST)
Date: Mon, 3 Feb 2014 07:03:46 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] shmgetfd idea
Message-ID: <20140203150346.GA30427@infradead.org>
References: <52E709C0.1050006@linaro.org>
 <20140130084657.GA31508@infradead.org>
 <CAPXgP13rAYV9SEQ0jgzD2C2vwWVxgqQfD__+ooAQcoPUu-RXhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPXgP13rAYV9SEQ0jgzD2C2vwWVxgqQfD__+ooAQcoPUu-RXhQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kay Sievers <kay@vrfy.org>
Cc: Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>, Al Viro <viro@zeniv.linux.org.uk>, Michael Kerrisk <mtk.manpages@gmail.com>

On Thu, Jan 30, 2014 at 05:02:40PM +0100, Kay Sievers wrote:
> Ashmem and kdbus can name the deleted files, which is useful for
> debugging and tools to show the associated name for the file
> descriptor. They also show up in /proc/$PID/maps/ and possibly in
> /proc/$PID/fd/.
> 
> O_TMPFILE always creates files with just the name "/". Unless that is
> changed we wouldn't want switch over to O_TMPFILE, because we would
> lose that nice feature.
> 
> Is there are way to "fix" O_TMPFILE to accept the name of the file to
> be created, instead of insisting to take only the leading directory as
> the argument?

As far as the VFS is concerned this should be fairly easily doable,
we'd just have to switch O_TMPFILE to the same lookup parent first
algorithm used for O_CREAT.  The filesystems shouldn't really care
at all as the name will never be stored on disk.

In fact such a full-path O_TMPFILE would be much nicer than the
current one as it has more similar arguments to the normal O_CREAT open
that I would document it as the default one, even if the old semantics
would have to still be supported for backwards compatibility.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
