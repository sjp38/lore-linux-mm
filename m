Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 9E8716B0070
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 19:54:00 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so7696214ied.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 16:54:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121023224706.GR4291@dastard>
References: <1350996411-5425-1-git-send-email-casualfisher@gmail.com>
	<20121023224706.GR4291@dastard>
Date: Wed, 24 Oct 2012 07:53:59 +0800
Message-ID: <CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
From: YingHang Zhu <casualfisher@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: akpm@linux-foundation.org, Fengguang Wu <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Dave,
On Wed, Oct 24, 2012 at 6:47 AM, Dave Chinner <david@fromorbit.com> wrote:
> On Tue, Oct 23, 2012 at 08:46:51PM +0800, Ying Zhu wrote:
>> Hi,
>>   Recently we ran into the bug that an opened file's ra_pages does not
>> synchronize with it's backing device's when the latter is changed
>> with blockdev --setra, the application needs to reopen the file
>> to know the change,
>
> or simply call fadvise(fd, POSIX_FADV_NORMAL) to reset the readhead
> window to the (new) bdi default.
>
>> which is inappropriate under our circumstances.
>
> Which are? We don't know your circumstances, so you need to tell us
> why you need this and why existing methods of handling such changes
> are insufficient...
>
> Optimal readahead windows tend to be a physical property of the
> storage and that does not tend to change dynamically. Hence block
> device readahead should only need to be set up once, and generally
> that can be done before the filesystem is mounted and files are
> opened (e.g. via udev rules). Hence you need to explain why you need
> to change the default block device readahead on the fly, and why
> fadvise(POSIX_FADV_NORMAL) is "inappropriate" to set readahead
> windows to the new defaults.
Our system is a fuse-based file system, fuse creates a
pseudo backing device for the user space file systems, the default readahead
size is 128KB and it can't fully utilize the backing storage's read ability,
so we should tune it.
The above third-party application using our file system maintains
some long-opened files, we does not have any chances
to force them to call fadvise(POSIX_FADV_NORMAL). :(
Thanks,
      Ying Zhu
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
