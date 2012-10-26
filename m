Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 59BCD6B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 22:25:09 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so2845094oag.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 19:25:08 -0700 (PDT)
Message-ID: <5089F47E.5010405@gmail.com>
Date: Fri, 26 Oct 2012 10:25:02 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
References: <1350996411-5425-1-git-send-email-casualfisher@gmail.com> <20121023224706.GR4291@dastard> <CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com> <20121024201921.GX4291@dastard> <CAA9v8mExDX1TYgCrRfYuh82SnNmNkqC4HjkmczSnz3Ca4zT_qw@mail.gmail.com> <20121025015014.GC29378@dastard> <CAA9v8mEULAEHn8qSsFokEue3c0hy8pK8bkYB+6xOtz_Tgbp0vw@mail.gmail.com> <50889FF1.9030107@gmail.com> <20121025025826.GB23462@localhost> <20121026002544.GI29378@dastard>
In-Reply-To: <20121026002544.GI29378@dastard>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, YingHang Zhu <casualfisher@gmail.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/26/2012 08:25 AM, Dave Chinner wrote:
> On Thu, Oct 25, 2012 at 10:58:26AM +0800, Fengguang Wu wrote:
>> Hi Chen,
>>
>>> But how can bdi related ra_pages reflect different files' readahead
>>> window? Maybe these different files are sequential read, random read
>>> and so on.
>> It's simple: sequential reads will get ra_pages readahead size while
>> random reads will not get readahead at all.
>>
>> Talking about the below chunk, it might hurt someone that explicitly
>> takes advantage of the behavior, however the ra_pages*2 seems more
>> like a hack than general solution to me: if the user will need
>> POSIX_FADV_SEQUENTIAL to double the max readahead window size for
>> improving IO performance, then why not just increase bdi->ra_pages and
>> benefit all reads? One may argue that it offers some differential
>> behavior to specific applications, however it may also present as a
>> counter-optimization: if the root already tuned bdi->ra_pages to the
>> optimal size, the doubled readahead size will only cost more memory
>> and perhaps IO latency.
>>
>> --- a/mm/fadvise.c
>> +++ b/mm/fadvise.c
>> @@ -87,7 +86,6 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>>                  spin_unlock(&file->f_lock);
>>                  break;
>>          case POSIX_FADV_SEQUENTIAL:
>> -               file->f_ra.ra_pages = bdi->ra_pages * 2;
> I think we really have to reset file->f_ra.ra_pages here as it is
> not a set-and-forget value. e.g.  shrink_readahead_size_eio() can
> reduce ra_pages as a result of IO errors. Hence if you have had io
> errors, telling the kernel that you are now going to do  sequential
> IO should reset the readahead to the maximum ra_pages value
> supported....

Good catch!

>
> Cheers,
>
> Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
