Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5BCE6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 12:50:00 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id i75so86020542ioa.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 09:50:00 -0700 (PDT)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id u50si8451084otd.144.2016.05.02.09.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 09:50:00 -0700 (PDT)
Received: by mail-ob0-x234.google.com with SMTP id n10so78832765obb.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 09:50:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57277EDA.9000803@plexistor.com>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
	<1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
	<5727753F.6090104@plexistor.com>
	<CAPcyv4jWPTDbbw6uMFEEt2Kazgw+wb5Pfwroej--uQPE+AtUbA@mail.gmail.com>
	<57277EDA.9000803@plexistor.com>
Date: Mon, 2 May 2016 09:49:59 -0700
Message-ID: <CAPcyv4jnz69a3S+XZgLaLojHZmpfoVXGDkJkt_1Q=8kk0gik9w@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Vishal Verma <vishal.l.verma@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-block@vger.kernel.org, Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew@wil.cx>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>, Jens Axboe <axboe@fb.com>, Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Mon, May 2, 2016 at 9:22 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
> On 05/02/2016 07:01 PM, Dan Williams wrote:
>> On Mon, May 2, 2016 at 8:41 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
>>> On 04/29/2016 12:16 AM, Vishal Verma wrote:
>>>> All IO in a dax filesystem used to go through dax_do_io, which cannot
>>>> handle media errors, and thus cannot provide a recovery path that can
>>>> send a write through the driver to clear errors.
>>>>
>>>> Add a new iocb flag for DAX, and set it only for DAX mounts. In the IO
>>>> path for DAX filesystems, use the same direct_IO path for both DAX and
>>>> direct_io iocbs, but use the flags to identify when we are in O_DIRECT
>>>> mode vs non O_DIRECT with DAX, and for O_DIRECT, use the conventional
>>>> direct_IO path instead of DAX.
>>>>
>>>
>>> Really? What are your thinking here?
>>>
>>> What about all the current users of O_DIRECT, you have just made them
>>> 4 times slower and "less concurrent*" then "buffred io" users. Since
>>> direct_IO path will queue an IO request and all.
>>> (And if it is not so slow then why do we need dax_do_io at all? [Rhetorical])
>>>
>>> I hate it that you overload the semantics of a known and expected
>>> O_DIRECT flag, for special pmem quirks. This is an incompatible
>>> and unrelated overload of the semantics of O_DIRECT.
>>
>> I think it is the opposite situation, it us undoing the premature
>> overloading of O_DIRECT that went in without performance numbers.
>
> We have tons of measurements. Is not hard to imagine the results though.
> Specially the 1000 threads case
>
>> This implementation clarifies that dax_do_io() handles the lack of a
>> page cache for buffered I/O and O_DIRECT behaves as it nominally would
>> by sending an I/O to the driver.
>
>> It has the benefit of matching the
>> error semantics of a typical block device where a buffered write could
>> hit an error filling the page cache, but an O_DIRECT write potentially
>> triggers the drive to remap the block.
>>
>
> I fail to see how in writes the device error semantics regarding remapping of
> blocks is any different between buffered and direct IO. As far as the block
> device it is the same exact code path. All The big difference is higher in the
> VFS.
>
> And ... So you are willing to sacrifice the 99% hotpath for the sake of the
> 1% error path? and piggybacking on poor O_DIRECT.
>
> Again there are tons of O_DIRECT apps out there, why are you forcing them to
> change if they want true pmem performance?

This isn't forcing them to change.  This is the path of least surprise
as error semantics are identical to a typical block device.  Yes, an
application can go faster by switching to the "buffered" / dax_do_io()
path it can go even faster to switch to mmap() I/O and use DAX
directly.  If we can later optimize the O_DIRECT path to bring it's
performance more in line with dax_do_io(), great, but the
implementation should be correct first and optimized later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
