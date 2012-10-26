Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 2C6B96B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 01:00:44 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so4125754ied.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 22:00:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121026035550.GA8894@localhost>
References: <20121023224706.GR4291@dastard>
	<CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com>
	<20121024201921.GX4291@dastard>
	<CAA9v8mExDX1TYgCrRfYuh82SnNmNkqC4HjkmczSnz3Ca4zT_qw@mail.gmail.com>
	<20121025015014.GC29378@dastard>
	<CAA9v8mEULAEHn8qSsFokEue3c0hy8pK8bkYB+6xOtz_Tgbp0vw@mail.gmail.com>
	<50889FF1.9030107@gmail.com>
	<20121025025826.GB23462@localhost>
	<20121026002544.GI29378@dastard>
	<CAA9v8mG4Sck=S4SGrorndzAgZzgDs1h9vWa1DhmC-2-FVF=Upg@mail.gmail.com>
	<20121026035550.GA8894@localhost>
Date: Fri, 26 Oct 2012 13:00:43 +0800
Message-ID: <CAA9v8mFV13rey4O3MW4122k163+UgcSLCsp1CkrFVDf-0iWzVw@mail.gmail.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
From: YingHang Zhu <casualfisher@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Ni zhan Chen <nizhan.chen@gmail.com>

On Fri, Oct 26, 2012 at 11:55 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> On Fri, Oct 26, 2012 at 11:38:11AM +0800, YingHang Zhu wrote:
>> On Fri, Oct 26, 2012 at 8:25 AM, Dave Chinner <david@fromorbit.com> wrote:
>> > On Thu, Oct 25, 2012 at 10:58:26AM +0800, Fengguang Wu wrote:
>> >> Hi Chen,
>> >>
>> >> > But how can bdi related ra_pages reflect different files' readahead
>> >> > window? Maybe these different files are sequential read, random read
>> >> > and so on.
>> >>
>> >> It's simple: sequential reads will get ra_pages readahead size while
>> >> random reads will not get readahead at all.
>> >>
>> >> Talking about the below chunk, it might hurt someone that explicitly
>> >> takes advantage of the behavior, however the ra_pages*2 seems more
>> >> like a hack than general solution to me: if the user will need
>> >> POSIX_FADV_SEQUENTIAL to double the max readahead window size for
>> >> improving IO performance, then why not just increase bdi->ra_pages and
>> >> benefit all reads? One may argue that it offers some differential
>> >> behavior to specific applications, however it may also present as a
>> >> counter-optimization: if the root already tuned bdi->ra_pages to the
>> >> optimal size, the doubled readahead size will only cost more memory
>> >> and perhaps IO latency.
>> >>
>> >> --- a/mm/fadvise.c
>> >> +++ b/mm/fadvise.c
>> >> @@ -87,7 +86,6 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>> >>                 spin_unlock(&file->f_lock);
>> >>                 break;
>> >>         case POSIX_FADV_SEQUENTIAL:
>> >> -               file->f_ra.ra_pages = bdi->ra_pages * 2;
>> >
>> > I think we really have to reset file->f_ra.ra_pages here as it is
>> > not a set-and-forget value. e.g.  shrink_readahead_size_eio() can
>> > reduce ra_pages as a result of IO errors. Hence if you have had io
>> > errors, telling the kernel that you are now going to do  sequential
>> > IO should reset the readahead to the maximum ra_pages value
>> > supported....
>> If we unify file->f_ra.ra_pages and its' bdi->ra_pages, then the error-prone
>> device's readahead can be directly tuned or turned off with blockdev
>> thus affect all files
>> using the device and without bring more complexity...
>
> It's not really feasible/convenient for the end users to hand tune
> blockdev readahead size on IO errors. Even many administrators are
> totally unaware of the readahead size parameter.
You are right, so the problem comes in this way:
    If one file's read failure will affect other files? I mean for
rotating disks and discs,
a file's read failure may be due to the bad sectors which tend to be consecutive
and won't affect other files' reading status. However for tape drive
the read failure
usually indicates data corruption and other file's reading may also fail.
    In other words, should we consider how many files failed to read data and
where they failed as a factor to indicate the status of the backing device,
or treat these files independently?
    If we choose the previous one we can accumulate the statistics and
change bdi.ra_pages,
otherwise we may do some check for FMODE_RANDOM before we change the readahead
window.
     I may missed something, please point it out.
Thanks,
      Ying Zhu
>
> Thanks,
> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
