Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 0DB206B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 09:48:45 -0400 (EDT)
Date: Tue, 24 Jul 2012 09:48:38 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] block_dev:Fix bug when read/write block-device which is
 larger than 16TB in 32bit-OS.
Message-ID: <20120724134838.GA26102@infradead.org>
References: <201205291656322966937@gmail.com>
 <201207242044249532601@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201207242044249532601@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: majianpeng <majianpeng@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, Jul 24, 2012 at 08:44:27PM +0800, majianpeng wrote:
> On 2012-05-29 16:56 majianpeng <majianpeng@gmail.com> Wrote:
> >The size of block-device is larger than 16TB, and the os is 32bit.
> >If the offset of read/write is larger then 16TB. The index of address_space will
> >overflow and supply data from low offset instead.

We can't support > 16TB block device on 32-bit systems with 4k page
size, just like we can't support files that large.

For filesystems the s_maxbytes limit of MAX_LFS_FILESIZE takes care of
that, but it seems like we miss that check for block devices.

The proper fix is to add that check (either via s_maxbytes or by
checking MAX_LFS_FILESIZE) to generic_write_checks and
generic_file_aio_read (or a block device specific wrapper)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
