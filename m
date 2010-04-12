Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5496E6B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 23:25:45 -0400 (EDT)
Received: by yxe39 with SMTP id 39so2096049yxe.12
        for <linux-mm@kvack.org>; Sun, 11 Apr 2010 20:25:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100412022704.GB5151@localhost>
References: <4BBA6776.5060804@mozilla.com> <20100406095135.GB5183@cmpxchg.org>
	 <20100407022456.GA9468@localhost> <4BBBF402.70403@mozilla.com>
	 <20100407073847.GB17892@localhost> <4BBE1609.6080308@mozilla.com>
	 <20100412022704.GB5151@localhost>
Date: Mon, 12 Apr 2010 12:25:43 +0900
Message-ID: <l2z28c262361004112025ydabc82ceyfa21cff9debc85b3@mail.gmail.com>
Subject: Re: Downsides to madvise/fadvise(willneed) for application startup
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Taras Glek <tglek@mozilla.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, Wu.

On Mon, Apr 12, 2010 at 11:27 AM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Fri, Apr 09, 2010 at 01:44:41AM +0800, Taras Glek wrote:
>> On 04/07/2010 12:38 AM, Wu Fengguang wrote:
>> > On Wed, Apr 07, 2010 at 10:54:58AM +0800, Taras Glek wrote:
>> >
>> >> On 04/06/2010 07:24 PM, Wu Fengguang wrote:
>> >>
>> >>> Hi Taras,
>> >>>
>> >>> On Tue, Apr 06, 2010 at 05:51:35PM +0800, Johannes Weiner wrote:
>> >>>
>> >>>
>> >>>> On Mon, Apr 05, 2010 at 03:43:02PM -0700, Taras Glek wrote:
>> >>>>
>> >>>>
>> >>>>> Hello,
>> >>>>> I am working on improving Mozilla startup times. It turns out that=
 page
>> >>>>> faults(caused by lack of cooperation between user/kernelspace) are=
 the
>> >>>>> main cause of slow startup. I need some insights from someone who
>> >>>>> understands linux vm behavior.
>> >>>>>
>> >>>>>
>> >>> How about improve Fedora (and other distros) to preload Mozilla (and
>> >>> other apps the user run at the previous boot) with fadvise() at boot
>> >>> time? This sounds like the most reasonable option.
>> >>>
>> >>>
>> >> That's a slightly different usecase. I'd rather have all large apps
>> >> startup as efficiently as possible without any hacks. Though until we
>> >> get there, we'll be using all of the hacks we can.
>> >>
>> > Boot time user space readahead can do better than kernel heuristic
>> > readahead in several ways:
>> >
>> > - it can collect better knowledge on which files/pages will be used
>> > =C2=A0 =C2=A0which lead to high readahead hit ratio and less cache con=
sumption
>> >
>> > - it can submit readahead requests for many files in parallel,
>> > =C2=A0 =C2=A0which enables queuing (elevator, NCQ etc.) optimizations
>> >
>> > So I won't call it dirty hack :)
>> >
>> >
>> Fair enough.
>> >>> As for the kernel readahead, I have a patchset to increase default
>> >>> mmap read-around size from 128kb to 512kb (except for small memory
>> >>> systems). =C2=A0This should help your case as well.
>> >>>
>> >>>
>> >> Yes. Is the current readahead really doing read-around(ie does it rea=
d
>> >> pages before the one being faulted)? From what I've seen, having the
>> >>
>> > Sure. It will do read-around from current fault offset - 64kb to +64kb=
.
>> >
>> That's excellent.
>> >
>> >> dynamic linker read binary sections backwards causes faults.
>> >> http://sourceware.org/bugzilla/show_bug.cgi?id=3D11447
>> >>
>> > There are too many data in
>> > http://people.mozilla.com/~tglek/startup/systemtap_graphs/ld_bug/repor=
t.txt
>> > Can you show me the relevant lines? (wondering if I can ever find such=
 lines..)
>> >
>> The first part of the file lists sections in a file and their hex
>> offset+size.
>
>> lines like 0 512 offset(#1) mean a read at position 0 of 512 bytes.
>> Incidentally this first read is coming from vfs_read, so the log doesn't
>> take account readahead (unlike the other reads caused by mmap page fault=
s).
>
> Yes, every binary/library starts with this 512b read. =C2=A0It is request=
ed
> by ld.so/ld-linux.so, and will trigger a 4-page readahead. This is not
> good readahead. I wonder if ld.so can switch to mmap read for the
> first read, in order to trigger a larger 128kb readahead. However this
> will introduce a little overhead on VMA operations.

AFAIK, kernel reads first sector(ELF header and so one)  of binary in
case of binary.
in fs/exec.c,
prepare_binprm()
{
...
return kernel_read(bprm->file, 0, bprm->buf, BINPRM_BUF_SIZE);
}

But dynamic loader uses libc_read for reading of shared library's one.

So you may have a chance to increase readahead size on binary but hard on s=
hared
library. Many of app have lots of shared library so the solution of
only binary isn't big about
performance. :(

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
