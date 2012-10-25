Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id AA5806B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 23:12:34 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so2112637ied.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 20:12:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121025025826.GB23462@localhost>
References: <1350996411-5425-1-git-send-email-casualfisher@gmail.com>
	<20121023224706.GR4291@dastard>
	<CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com>
	<20121024201921.GX4291@dastard>
	<CAA9v8mExDX1TYgCrRfYuh82SnNmNkqC4HjkmczSnz3Ca4zT_qw@mail.gmail.com>
	<20121025015014.GC29378@dastard>
	<CAA9v8mEULAEHn8qSsFokEue3c0hy8pK8bkYB+6xOtz_Tgbp0vw@mail.gmail.com>
	<50889FF1.9030107@gmail.com>
	<20121025025826.GB23462@localhost>
Date: Thu, 25 Oct 2012 11:12:33 +0800
Message-ID: <CAA9v8mESzPQ6gONDYyZTvCvHYb+MvW0dTmkyjWmX72PPufraqg@mail.gmail.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
From: YingHang Zhu <casualfisher@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ni zhan Chen <nizhan.chen@gmail.com>, Dave Chinner <david@fromorbit.com>

On Thu, Oct 25, 2012 at 10:58 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> Hi Chen,
>
>> But how can bdi related ra_pages reflect different files' readahead
>> window? Maybe these different files are sequential read, random read
>> and so on.
>
> It's simple: sequential reads will get ra_pages readahead size while
> random reads will not get readahead at all.
>
> Talking about the below chunk, it might hurt someone that explicitly
> takes advantage of the behavior, however the ra_pages*2 seems more
> like a hack than general solution to me: if the user will need
> POSIX_FADV_SEQUENTIAL to double the max readahead window size for
> improving IO performance, then why not just increase bdi->ra_pages and
> benefit all reads? One may argue that it offers some differential
> behavior to specific applications, however it may also present as a
> counter-optimization: if the root already tuned bdi->ra_pages to the
> optimal size, the doubled readahead size will only cost more memory
> and perhaps IO latency.
I agree, we should choose the reasonable solution here.

Thanks,
     Ying Zhu
>
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -87,7 +86,6 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>                 spin_unlock(&file->f_lock);
>                 break;
>         case POSIX_FADV_SEQUENTIAL:
> -               file->f_ra.ra_pages = bdi->ra_pages * 2;
>                 spin_lock(&file->f_lock);
>                 file->f_mode &= ~FMODE_RANDOM;
>                 spin_unlock(&file->f_lock);
>
> Thanks,
> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
