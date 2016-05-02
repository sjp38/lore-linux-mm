Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F54D6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 12:22:54 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j8so144875781lfd.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 09:22:54 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id ld7si34979575wjb.127.2016.05.02.09.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 09:22:53 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id n129so113989051wmn.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 09:22:52 -0700 (PDT)
Message-ID: <57277EDA.9000803@plexistor.com>
Date: Mon, 02 May 2016 19:22:50 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>	<1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>	<5727753F.6090104@plexistor.com> <CAPcyv4jWPTDbbw6uMFEEt2Kazgw+wb5Pfwroej--uQPE+AtUbA@mail.gmail.com>
In-Reply-To: <CAPcyv4jWPTDbbw6uMFEEt2Kazgw+wb5Pfwroej--uQPE+AtUbA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Vishal Verma <vishal.l.verma@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-block@vger.kernel.org, Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew@wil.cx>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>, Jens Axboe <axboe@fb.com>, Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On 05/02/2016 07:01 PM, Dan Williams wrote:
> On Mon, May 2, 2016 at 8:41 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
>> On 04/29/2016 12:16 AM, Vishal Verma wrote:
>>> All IO in a dax filesystem used to go through dax_do_io, which cannot
>>> handle media errors, and thus cannot provide a recovery path that can
>>> send a write through the driver to clear errors.
>>>
>>> Add a new iocb flag for DAX, and set it only for DAX mounts. In the IO
>>> path for DAX filesystems, use the same direct_IO path for both DAX and
>>> direct_io iocbs, but use the flags to identify when we are in O_DIRECT
>>> mode vs non O_DIRECT with DAX, and for O_DIRECT, use the conventional
>>> direct_IO path instead of DAX.
>>>
>>
>> Really? What are your thinking here?
>>
>> What about all the current users of O_DIRECT, you have just made them
>> 4 times slower and "less concurrent*" then "buffred io" users. Since
>> direct_IO path will queue an IO request and all.
>> (And if it is not so slow then why do we need dax_do_io at all? [Rhetorical])
>>
>> I hate it that you overload the semantics of a known and expected
>> O_DIRECT flag, for special pmem quirks. This is an incompatible
>> and unrelated overload of the semantics of O_DIRECT.
> 
> I think it is the opposite situation, it us undoing the premature
> overloading of O_DIRECT that went in without performance numbers.

We have tons of measurements. Is not hard to imagine the results though.
Specially the 1000 threads case

> This implementation clarifies that dax_do_io() handles the lack of a
> page cache for buffered I/O and O_DIRECT behaves as it nominally would
> by sending an I/O to the driver.  

> It has the benefit of matching the
> error semantics of a typical block device where a buffered write could
> hit an error filling the page cache, but an O_DIRECT write potentially
> triggers the drive to remap the block.
> 

I fail to see how in writes the device error semantics regarding remapping of
blocks is any different between buffered and direct IO. As far as the block
device it is the same exact code path. All The big difference is higher in the
VFS.

And ... So you are willing to sacrifice the 99% hotpath for the sake of the
1% error path? and piggybacking on poor O_DIRECT.

Again there are tons of O_DIRECT apps out there, why are you forcing them to
change if they want true pmem performance?

I still believe dax_do_io() can be made more resilient to errors, and clear
errors on writes. Me going digging in old patches ...

Cheers
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
