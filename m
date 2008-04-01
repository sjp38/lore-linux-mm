From: "Tom May" <tom@tommay.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Date: Tue, 1 Apr 2008 16:35:06 -0700
Message-ID: <ab3f9b940804011635g2de833d0l44558f78a1cce1e5@mail.gmail.com>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Sat, Feb 9, 2008 at 8:19 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>  The /dev/mem_notify is low memory notification device.
>  it can avoid swappness and oom by cooperationg with the user process=
=2E
>
>  the Linux Today article is very nice description. (great works by Ja=
ke Edge)
>  http://www.linuxworld.com/news/2008/020508-kernel.html
>
>  <quoted>
>  When memory gets tight, it is quite possible that applications have =
memory
>  allocated=97often caches for better performance=97that they could fr=
ee.
>  After all, it is generally better to lose some performance than to f=
ace the
>  consequences of being chosen by the OOM killer.
>  But, currently, there is no way for a process to know that the kerne=
l is
>  feeling memory pressure.
>  The patch provides a way for interested programs to monitor the /dev=
/mem_notify
>   file to be notified if memory starts to run low.
>  </quoted>
>
>
>  You need not be annoyed by OOM any longer :)
>  please any comments!

Thanks for this patch set!  I ported it to 2.6.23.9 and tried it, on a
system with no swap since I'm evaluating this for an embedded system.
In practice, the criterion it uses for notifications wasn't sufficient =
to avoid
memory problems, including OOM, in a cyclic allocate/notify/free
sequence which is probably typical.

I tried it with a real-world program that, among other things, mmaps
anonymous pages and touches them at a reasonable speed until it gets
notified via /dev/mem_notify, releases most of them with
madvise(MADV_DONTNEED), then loops to start the cycle again.

What tends to happen is that I do indeed get notifications via
/dev/mem_notify when the kernel would like to be swapping, at which
point I free memory.  But the notifications come at a time when the
kernel needs memory, and it gets the memory by discarding some Cached
or Mapped memory (I can see these decreasing in /proc/meminfo with
each notification).  With each mmap/notify/madvise cycle the Cached
and Mapped memory gets smaller, until eventually while I'm touching
pages the kernel can't find enough memory and will either invoke the
OOM killer or return ENOMEM from syscalls.  This is precisely the
situation I'm trying to avoid by using /dev/mem_notify.

The criterion of "notify when the kernel would like to swap" feels
correct, but in addition I seem to need something like "notify when
cached+mapped+free memory is getting low".

I'll need to be looking into doing this, so any comments or ideas are
welcome.

Thanks,
=2Etom
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
