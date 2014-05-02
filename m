Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id C5BE66B0037
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:16:59 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id cm18so3147869qab.25
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:16:59 -0700 (PDT)
Received: from mail-qa0-x22e.google.com (mail-qa0-x22e.google.com [2607:f8b0:400d:c00::22e])
        by mx.google.com with ESMTPS id j6si14022329qan.32.2014.05.02.06.16.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:16:59 -0700 (PDT)
Received: by mail-qa0-f46.google.com with SMTP id w8so4195203qac.5
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:16:59 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Fri, 2 May 2014 15:16:39 +0200
Message-ID: <CAKgNAkjuU68hgyMOVGBVoBTOhhGdBytQh6H0ExiLoXfujKyP_w@mail.gmail.com>
Subject: Re: [PATCH 0/4] ipc/shm.c: increase the limits for SHMMAX, SHMALL
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Manfred,

On Mon, Apr 21, 2014 at 4:26 PM, Manfred Spraul
<manfred@colorfullife.com> wrote:
> Hi all,
>
> the increase of SHMMAX/SHMALL is now a 4 patch series.
> I don't have ideas how to improve it further.

On the assumption that your patches are heading to mainline, could you
send me a man-pages patch for the changes?

Thanks,

Michael


> The change itself is trivial, the only problem are interger overflows.
> The overflows are not new, but if we make huge values the default,
> then the code should be free from overflows.
>
> SHMMAX:
>
> - shmmem_file_setup places a hard limit on the segment size:
>   MAX_LFS_FILESIZE.
>
>   On 32-bit, the limit is > 1 TB, i.e. 4 GB-1 byte segments are
>   possible. Rounded up to full pages the actual allocated size
>   is 0. --> must be fixed, patch 3
>
> - shmat:
>   - find_vma_intersection does not handle overflows properly.
>     --> must be fixed, patch 1
>
>   - the rest is fine, do_mmap_pgoff limits mappings to TASK_SIZE
>     and checks for overflows (i.e.: map 2 GB, starting from
>     addr=2.5GB fails).
>
> SHMALL:
> - after creating 8192 segments size (1L<<63)-1, shm_tot overflows and
>   returns 0.  --> must be fixed, patch 2.
>
> User space:
> - Obviuosly, there could be overflows in user space. There is nothing
>   we can do, only use values smaller than ULONG_MAX.
>   I ended with "ULONG_MAX - 1L<<24":
>
>   - TASK_SIZE cannot be used because it is the size of the current
>     task. Could be 4G if it's a 32-bit task on a 64-bit kernel.
>
>   - The maximum size is not standardized across archs:
>     I found TASK_MAX_SIZE, TASK_SIZE_MAX and TASK_SIZE_64.
>
>   - Just in case some arch revives a 4G/4G split, nearly
>     ULONG_MAX is a valid segment size.
>
>   - Using "0" as a magic value for infinity is even worse, because
>     right now 0 means 0, i.e. fail all allocations.
>
> Andrew: Could you add it into -akpm and move it towards linux-next?
>
> --
>         Manfred



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
