Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4327E6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 05:50:23 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id l13so3285205iga.4
        for <linux-mm@kvack.org>; Thu, 22 May 2014 02:50:23 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id fd15si21149817icb.34.2014.05.22.02.50.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 02:50:22 -0700 (PDT)
Received: by mail-ig0-f177.google.com with SMTP id l13so3285203iga.4
        for <linux-mm@kvack.org>; Thu, 22 May 2014 02:50:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140521193336.5df90456.akpm@linux-foundation.org>
References: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20140521154250.95bc3520ad8d192d95efe39b@linux-foundation.org>
	<537d5ee4.4914e00a.5672.ffff85d5SMTPIN_ADDED_BROKEN@mx.google.com>
	<20140521193336.5df90456.akpm@linux-foundation.org>
Date: Thu, 22 May 2014 13:50:22 +0400
Message-ID: <CALYGNiMeDtiaA6gfbEYcXbwkuFvTRCLC9KmMOPtopAgGg5b6AA@mail.gmail.com>
Subject: Re: [PATCH 0/4] pagecache scanning with /proc/kpagecache
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@openvz.org>

On Thu, May 22, 2014 at 6:33 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 21 May 2014 22:19:55 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
>
>> > A much nicer interface would be for us to (finally!) implement
>> > fincore(), perhaps with an enhanced per-present-page payload which
>> > presents the info which you need (although we don't actually know what
>> > that info is!).
>>
>> page/pfn of each page slot and its page cache tag as shown in patch 4/4.
>>
>> > This would require open() - it appears to be a requirement that the
>> > caller not open the file, but no reason was given for this.
>> >
>> > Requiring open() would address some of the obvious security concerns,
>> > but it will still be possible for processes to poke around and get some
>> > understanding of the behaviour of other processes.  Careful attention
>> > should be paid to this aspect of any such patchset.
>>
>> Sorry if I missed your point, but this interface defines fixed mapping
>> between file position in /proc/kpagecache and in-file page offset of
>> the target file. So we do not need to use seq_file mechanism, that's
>> why open() is not defined and default one is used.
>> The same thing is true for /proc/{kpagecount,kpageflags}, from which
>> I copied/pasted some basic code.
>
> I think you did miss my point ;) Please do a web search for fincore -
> it's a syscall similar to mincore(), only it queries pagecache:
> fincore(int fd, loff_t offset, ...).  In its simplest form it queries
> just for present/absent, but we could increase the query payload to
> incorporate additional per-page info.
>
> It would take a lot of thought and discussion to nail down the
> fincore() interface (we've already tried a couple of times).  But
> unfortunately, fincore() is probably going to be implemented one day
> and it will (or at least could) make /proc/kpagecache obsolete.
>

It seems fincore() also might obsolete /proc/kpageflags and /proc/pid/pagemap.
because it might be implemented for /dev/mem and /proc/pid/mem as well
as for normal files.

Something like this:
int fincore(int fd, u64 *kpf, u64 *pfn, size_t length, off_t offset)

It reports PFN and page-flags in KPF_* notation. PFN array is optional.
KFP_NOPAGE reports hole, otherwise this is present page, but probably
not-uptodate.
KFP_SOFTDIRTY already here.


Also we need new flag KFP_SWAPENTRY for vm/shmem to report swap-entry
instead of pfn.
Probably this is redundant, we cannot report pfn and swap-entry
togerher if page present and in swap-cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
