Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 18E296B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 23:08:20 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so2108668ied.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 20:08:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121025023808.GA23462@localhost>
References: <1350996411-5425-1-git-send-email-casualfisher@gmail.com>
	<20121023224706.GR4291@dastard>
	<CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com>
	<20121024201921.GX4291@dastard>
	<CAA9v8mExDX1TYgCrRfYuh82SnNmNkqC4HjkmczSnz3Ca4zT_qw@mail.gmail.com>
	<20121025015014.GC29378@dastard>
	<CAA9v8mEULAEHn8qSsFokEue3c0hy8pK8bkYB+6xOtz_Tgbp0vw@mail.gmail.com>
	<20121025023808.GA23462@localhost>
Date: Thu, 25 Oct 2012 11:08:18 +0800
Message-ID: <CAA9v8mFDP8NTfgoL9tVt2FNAGa13t+0tAUrWvTqt2G-RmEki9A@mail.gmail.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
From: YingHang Zhu <casualfisher@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>

On Thu, Oct 25, 2012 at 10:38 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> Hi YingHang,
>
>> Actually I've talked about it with Fengguang, he advised we should unify the
>> ra_pages in struct bdi and file_ra_state and leave the issue that
>> spreading data
>> across disks as it is.
>> Fengguang, what's you opinion about this?
>
> Yeah the two ra_pages may run out of sync for already opened files,
> which could be a problem for long opened files. However as Dave put
> it, a device's max readahead size is typically a static value that can
> be set at mount time. So, the question is: do you really hurt from the
> old behavior that deserves this code change?
We could advise the above application to reopen files.
As I mentioned previously the many scst users also have this problem:
[quote]
Note2: you need to restart SCST after you changed read-ahead settings
on the target. It is a limitation of the Linux read ahead
implementation. It reads RA values for each file only when the file
is open and not updates them when the global RA parameters changed.
Hence, the need for vdisk to reopen all its files/devices.
[/quote]
So IMHO it's a functional bug in kernel that brings inconvenience to the
application developers.
>
> I agree with Dave that the multi-disk case is not a valid concern.  In
> fact, how can the patch help that case? I mean, if it's two fuse files
> lying in two disks, it *was* not a problem at all. If it's one big
> file spreading to two disks, it's a too complex scheme to be
> practically manageable which I doubt if you have such a setup.
Yes this patch does not solve the issue here. I'm just push the discussion
a little further, in reality we may never meet such setup.

Thanks,
         Ying Hang
>
> Thanks,
> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
