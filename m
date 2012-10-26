Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 41A926B0073
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 22:30:19 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so3993416ied.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 19:30:18 -0700 (PDT)
Message-ID: <5089F5AD.5040708@gmail.com>
Date: Fri, 26 Oct 2012 10:30:05 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
References: <1350996411-5425-1-git-send-email-casualfisher@gmail.com> <20121023224706.GR4291@dastard> <CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com> <20121024201921.GX4291@dastard> <CAA9v8mExDX1TYgCrRfYuh82SnNmNkqC4HjkmczSnz3Ca4zT_qw@mail.gmail.com> <20121025015014.GC29378@dastard> <CAA9v8mEULAEHn8qSsFokEue3c0hy8pK8bkYB+6xOtz_Tgbp0vw@mail.gmail.com> <50889FF1.9030107@gmail.com> <20121025025826.GB23462@localhost> <20121026002544.GI29378@dastard> <20121026012758.GA6282@localhost>
In-Reply-To: <20121026012758.GA6282@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, YingHang Zhu <casualfisher@gmail.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/26/2012 09:27 AM, Fengguang Wu wrote:
> On Fri, Oct 26, 2012 at 11:25:44AM +1100, Dave Chinner wrote:
>> On Thu, Oct 25, 2012 at 10:58:26AM +0800, Fengguang Wu wrote:
>>> Hi Chen,
>>>
>>>> But how can bdi related ra_pages reflect different files' readahead
>>>> window? Maybe these different files are sequential read, random read
>>>> and so on.
>>> It's simple: sequential reads will get ra_pages readahead size while
>>> random reads will not get readahead at all.
>>>
>>> Talking about the below chunk, it might hurt someone that explicitly
>>> takes advantage of the behavior, however the ra_pages*2 seems more
>>> like a hack than general solution to me: if the user will need
>>> POSIX_FADV_SEQUENTIAL to double the max readahead window size for
>>> improving IO performance, then why not just increase bdi->ra_pages and
>>> benefit all reads? One may argue that it offers some differential
>>> behavior to specific applications, however it may also present as a
>>> counter-optimization: if the root already tuned bdi->ra_pages to the
>>> optimal size, the doubled readahead size will only cost more memory
>>> and perhaps IO latency.
>>>
>>> --- a/mm/fadvise.c
>>> +++ b/mm/fadvise.c
>>> @@ -87,7 +86,6 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>>>                  spin_unlock(&file->f_lock);
>>>                  break;
>>>          case POSIX_FADV_SEQUENTIAL:
>>> -               file->f_ra.ra_pages = bdi->ra_pages * 2;
>> I think we really have to reset file->f_ra.ra_pages here as it is
>> not a set-and-forget value. e.g.  shrink_readahead_size_eio() can
>> reduce ra_pages as a result of IO errors. Hence if you have had io
>> errors, telling the kernel that you are now going to do  sequential
>> IO should reset the readahead to the maximum ra_pages value
>> supported....
> Good point!
>
> .... but wait .... this patch removes file->f_ra.ra_pages in all other
> places too, so there will be no file->f_ra.ra_pages to be reset here...

In his patch,

  static void shrink_readahead_size_eio(struct file *filp,
                                         struct file_ra_state *ra)
  {
-       ra->ra_pages /= 4;
+       spin_lock(&filp->f_lock);
+       filp->f_mode |= FMODE_RANDOM;
+       spin_unlock(&filp->f_lock);

As the example in comment above this function, the read maybe still 
sequential, and it will waste IO bandwith if modify to FMODE_RANDOM 
directly.

>
> Thanks,
> Fengguang
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
