Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id AD6FC6B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 22:31:32 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so1185086iak.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 19:31:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50889FF1.9030107@gmail.com>
References: <1350996411-5425-1-git-send-email-casualfisher@gmail.com>
	<20121023224706.GR4291@dastard>
	<CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com>
	<20121024201921.GX4291@dastard>
	<CAA9v8mExDX1TYgCrRfYuh82SnNmNkqC4HjkmczSnz3Ca4zT_qw@mail.gmail.com>
	<20121025015014.GC29378@dastard>
	<CAA9v8mEULAEHn8qSsFokEue3c0hy8pK8bkYB+6xOtz_Tgbp0vw@mail.gmail.com>
	<50889FF1.9030107@gmail.com>
Date: Thu, 25 Oct 2012 10:31:32 +0800
Message-ID: <CAA9v8mGMUHaPJwJuGUkC9xWPYiu5pHEhcehRC0T3U7-oJwF13w@mail.gmail.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
From: YingHang Zhu <casualfisher@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: akpm@linux-foundation.org, Fengguang Wu <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 25, 2012 at 10:12 AM, Ni zhan Chen <nizhan.chen@gmail.com> wrote:
> On 10/25/2012 10:04 AM, YingHang Zhu wrote:
>>
>> On Thu, Oct 25, 2012 at 9:50 AM, Dave Chinner <david@fromorbit.com> wrote:
>>>
>>> On Thu, Oct 25, 2012 at 08:17:05AM +0800, YingHang Zhu wrote:
>>>>
>>>> On Thu, Oct 25, 2012 at 4:19 AM, Dave Chinner <david@fromorbit.com>
>>>> wrote:
>>>>>
>>>>> On Wed, Oct 24, 2012 at 07:53:59AM +0800, YingHang Zhu wrote:
>>>>>>
>>>>>> Hi Dave,
>>>>>> On Wed, Oct 24, 2012 at 6:47 AM, Dave Chinner <david@fromorbit.com>
>>>>>> wrote:
>>>>>>>
>>>>>>> On Tue, Oct 23, 2012 at 08:46:51PM +0800, Ying Zhu wrote:
>>>>>>>>
>>>>>>>> Hi,
>>>>>>>>    Recently we ran into the bug that an opened file's ra_pages does
>>>>>>>> not
>>>>>>>> synchronize with it's backing device's when the latter is changed
>>>>>>>> with blockdev --setra, the application needs to reopen the file
>>>>>>>> to know the change,
>>>>>>>
>>>>>>> or simply call fadvise(fd, POSIX_FADV_NORMAL) to reset the readhead
>>>>>>> window to the (new) bdi default.
>>>>>>>
>>>>>>>> which is inappropriate under our circumstances.
>>>>>>>
>>>>>>> Which are? We don't know your circumstances, so you need to tell us
>>>>>>> why you need this and why existing methods of handling such changes
>>>>>>> are insufficient...
>>>>>>>
>>>>>>> Optimal readahead windows tend to be a physical property of the
>>>>>>> storage and that does not tend to change dynamically. Hence block
>>>>>>> device readahead should only need to be set up once, and generally
>>>>>>> that can be done before the filesystem is mounted and files are
>>>>>>> opened (e.g. via udev rules). Hence you need to explain why you need
>>>>>>> to change the default block device readahead on the fly, and why
>>>>>>> fadvise(POSIX_FADV_NORMAL) is "inappropriate" to set readahead
>>>>>>> windows to the new defaults.
>>>>>>
>>>>>> Our system is a fuse-based file system, fuse creates a
>>>>>> pseudo backing device for the user space file systems, the default
>>>>>> readahead
>>>>>> size is 128KB and it can't fully utilize the backing storage's read
>>>>>> ability,
>>>>>> so we should tune it.
>>>>>
>>>>> Sure, but that doesn't tell me anything about why you can't do this
>>>>> at mount time before the application opens any files. i.e.  you've
>>>>> simply stated the reason why readahead is tunable, not why you need
>>>>> to be fully dynamic.....
>>>>
>>>> We store our file system's data on different disks so we need to change
>>>> ra_pages
>>>> dynamically according to where the data resides, it can't be fixed at
>>>> mount time
>>>> or when we open files.
>>>
>>> That doesn't make a whole lot of sense to me. let me try to get this
>>> straight.
>>>
>>> There is data that resides on two devices (A + B), and a fuse
>>> filesystem to access that data. There is a single file in the fuse
>>> fs has data on both devices. An app has the file open, and when the
>>> data it is accessing is on device A you need to set the readahead to
>>> what is best for device A? And when the app tries to access data for
>>> that file that is on device B, you need to set the readahead to what
>>> is best for device B? And you are changing the fuse BDI readahead
>>> settings according to where the data in the back end lies?
>>>
>>> It seems to me that you should be setting the fuse readahead to the
>>> maximum of the readahead windows the data devices have configured at
>>> mount time and leaving it at that....
>>
>> Then it may not fully utilize some device's read IO bandwidth and put too
>> much
>> burden on other devices.
>>>>
>>>> The abstract bdi of fuse and btrfs provides some dynamically changing
>>>> bdi.ra_pages
>>>> based on the real backing device. IMHO this should not be ignored.
>>>
>>> btrfs simply takes into account the number of disks it has for a
>>> given storage pool when setting up the default bdi ra_pages during
>>> mount.  This is basically doing what I suggested above.  Same with
>>> the generic fuse code - it's simply setting a sensible default value
>>> for the given fuse configuration.
>>>
>>> Neither are dynamic in the sense you are talking about, though.
>>
>> Actually I've talked about it with Fengguang, he advised we should unify
>> the
>
>
> But how can bdi related ra_pages reflect different files' readahead window?
> Maybe these different files are sequential read, random read and so on.
I think you mean the dynamic tuning of readahead window, that's exactly the job
of readahead algorithm and it's reflected by file_ra_state.sync_size and
file_ra_state.async_size.
The ra_pages in struct file_ra_state only means the max readahead ability.

Thanks,
    Ying Zhu
>
>> ra_pages in struct bdi and file_ra_state and leave the issue that
>> spreading data
>> across disks as it is.
>> Fengguang, what's you opinion about this?
>>
>> Thanks,
>>           Ying Zhu
>>>
>>> Cheers,
>>>
>>> Dave.
>>> --
>>> Dave Chinner
>>> david@fromorbit.com
>>
>> --
>>
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
