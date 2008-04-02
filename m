From: "Tom May" <tom@tommay.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Date: Wed, 2 Apr 2008 10:45:05 -0700
Message-ID: <ab3f9b940804021045r28e88ce9vfddad5362ea6372d@mail.gmail.com>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
	 <ab3f9b940804011635g2de833d0l44558f78a1cce1e5@mail.gmail.com>
	 <20080402154910.9588.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759361AbYDBRpj@vger.kernel.org>
In-Reply-To: <20080402154910.9588.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Wed, Apr 2, 2008 at 12:31 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi Tom,
>
>  Thank you very useful comment.
>  that is very interesting.
>
>
>  > I tried it with a real-world program that, among other things, mmaps
>  > anonymous pages and touches them at a reasonable speed until it gets
>  > notified via /dev/mem_notify, releases most of them with
>  > madvise(MADV_DONTNEED), then loops to start the cycle again.
>  >
>  > What tends to happen is that I do indeed get notifications via
>  > /dev/mem_notify when the kernel would like to be swapping, at which
>  > point I free memory.  But the notifications come at a time when the
>  > kernel needs memory, and it gets the memory by discarding some Cached
>  > or Mapped memory (I can see these decreasing in /proc/meminfo with
>  > each notification).  With each mmap/notify/madvise cycle the Cached
>  > and Mapped memory gets smaller, until eventually while I'm touching
>  > pages the kernel can't find enough memory and will either invoke the
>  > OOM killer or return ENOMEM from syscalls.  This is precisely the
>  > situation I'm trying to avoid by using /dev/mem_notify.
>
>  Could you send your test program?

Unfortunately, no, it's a Java Virtual Machine (which is a perfect
user of /dev/mem_notify since it can garbage collect on notification,
among other times).

But it should be possible to make a small program with the same
behavior; I'll do that.

>  I can't reproduce that now, sorry.
>
>
>
>  > The criterion of "notify when the kernel would like to swap" feels
>  > correct, but in addition I seem to need something like "notify when
>  > cached+mapped+free memory is getting low".
>
>  Hmmm,
>  I think this idea is only useful when userland process call
>  madvise(MADV_DONTNEED) periodically.

Do you have a recommendation for freeing memory?  I could maybe use
munmap/mmap, but that's not atomic and may be "worse" (more overhead,
etc.) than madvise(MADV_DONTNEED).

>  but I hope improve my patch and solve your problem.
>  if you don' mind, please help my testing ;)

It's my pleasure to help in any way I can.

.tom
