Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4BBA16B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 01:24:30 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id w7so2420021lbi.34
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 22:24:29 -0700 (PDT)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id rb9si17067530lbb.31.2014.09.22.22.24.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 22:24:28 -0700 (PDT)
Received: by mail-lb0-f171.google.com with SMTP id l4so8078287lbv.30
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 22:24:28 -0700 (PDT)
Message-ID: <54210407.1000602@gmail.com>
Date: Tue, 23 Sep 2014 07:24:23 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ipc/shm.c: increase the limits for SHMMAX, SHMALL
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>	 <CAKgNAkjuU68hgyMOVGBVoBTOhhGdBytQh6H0ExiLoXfujKyP_w@mail.gmail.com> <1401823560.4911.2.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1401823560.4911.2.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: mtk.manpages@gmail.com, Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 06/03/2014 09:26 PM, Davidlohr Bueso wrote:
> On Fri, 2014-05-02 at 15:16 +0200, Michael Kerrisk (man-pages) wrote:
>> Hi Manfred,
>>
>> On Mon, Apr 21, 2014 at 4:26 PM, Manfred Spraul
>> <manfred@colorfullife.com> wrote:
>>> Hi all,
>>>
>>> the increase of SHMMAX/SHMALL is now a 4 patch series.
>>> I don't have ideas how to improve it further.
>>
>> On the assumption that your patches are heading to mainline, could you
>> send me a man-pages patch for the changes?
> 
> It seems we're still behind here and the 3.16 merge window is already
> opened. Please consider this, and again feel free to add/modify as
> necessary. I think adding a note as below is enough and was hesitant to
> add a lot of details... Thanks.
> 
> 8<--------------------------------------------------
> From: Davidlohr Bueso <davidlohr@hp.com>
> Subject: [PATCH] shmget.2: document new limits for shmmax/shmall
> 
> These limits have been recently enlarged and
> modifying them is no longer really necessary.
> Update the manpage.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
>  man2/shmget.2 | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/man2/shmget.2 b/man2/shmget.2
> index f781048..77764ea 100644
> --- a/man2/shmget.2
> +++ b/man2/shmget.2
> @@ -299,6 +299,11 @@ with 8kB page size, it yields 2^20 (1048576).
>  
>  On Linux, this limit can be read and modified via
>  .IR /proc/sys/kernel/shmall .
> +As of Linux 3.16, the default value for this limit is increased to
> +.B ULONG_MAX - 2^24
> +pages, which is as large as it can be without helping userspace overflow
> +the values. Modifying this limit is therefore discouraged. This is suitable
> +for both 32 and 64-bit systems.
>  .TP
>  .B SHMMAX
>  Maximum size in bytes for a shared memory segment.
> @@ -306,6 +311,12 @@ Since Linux 2.2, the default value of this limit is 0x2000000 (32MB).
>  
>  On Linux, this limit can be read and modified via
>  .IR /proc/sys/kernel/shmmax .
> +As of Linux 3.16, the default value for this limit is increased from 32Mb
> +to
> +.B ULONG_MAX - 2^24
> +bytes, which is as large as it can be without helping userspace overflow
> +the values. Modifying this limit is therefore discouraged. This is suitable
> +for both 32 and 64-bit systems.
>  .TP
>  .B SHMMIN
>  Minimum size in bytes for a shared memory segment: implementation

David,

I applied various pieces from your patch on top of material
that I already had, so that now we have the text below describing
these limits.  Comments/suggestions/improvements from all welcome.

Cheers,

Michael

       SHMALL System-wide limit on the number of pages of shared memory.

              On  Linux,  this  limit  can  be  read  and  modified  via
              /proc/sys/kernel/shmall.  Since Linux  3.16,  the  default
              value for this limit is:

                  ULONG_MAX - 2^24

              The  effect  of  this  value  (which  is suitable for both
              32-bit and 64-bit systems) is to impose no  limitation  on
              allocations.   This value, rather than ULONG_MAX, was choa??
              sen as the default to prevent some cases where  historical
              applications  simply  raised  the  existing  limit without
              first checking its current value.  Such applications would
              cause  the  value  to  overflow  if  the  limit was set at
              ULONG_MAX.

              From Linux 2.4 up to Linux 3.15,  the  default  value  for
              this limit was:

                  SHMMAX / PAGE_SIZE * (SHMMNI / 16)

              If  SHMMAX  and SHMMNI were not modified, then multiplying
              the result of this formula by the  page  size  (to  get  a
              value  in  bytes)  yielded a value of 8 GB as the limit on
              the total memory used by all shared memory segments.

       SHMMAX Maximum size in bytes for a shared memory segment.

              On  Linux,  this  limit  can  be  read  and  modified  via
              /proc/sys/kernel/shmmax.   Since  Linux  3.16, the default
              value for this limit is:

                  ULONG_MAX - 2^24

              The effect of this  value  (which  is  suitable  for  both
              32-bit  and  64-bit systems) is to impose no limitation on
              allocations.  See the description of SHMALL for a  discusa??
              sion  of why this default value (rather than ULONG_MAX) is
              used.

              From Linux 2.2 up to Linux 3.15, the default value of this
              limit was 0x2000000 (32MB).

              Because  it  is  not possible to map just part of a shared
              memory  segment,  the  amount  of  virtual  memory  places
              another limit on the maximum size of a usable segment: for
              example, on i386 the largest segments that can  be  mapped
              have  a  size of around 2.8 GB, and on x86_64 the limit is
              around 127 TB.



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
