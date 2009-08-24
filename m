Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5DBEE6B005A
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:32:50 -0400 (EDT)
Received: from coyote.coyote.den ([141.153.112.139]) by vms173005.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008; 32bit))
 with ESMTPA id <0KOU00HAUZY90J30@vms173005.mailsrvcs.net> for
 linux-mm@kvack.org; Sun, 23 Aug 2009 21:22:57 -0500 (CDT)
From: Gene Heskett <gene.heskett@verizon.net>
Subject: Re: Bad page state (was Re: Linux 2.6.31-rc7)
Date: Sun, 23 Aug 2009 22:22:40 -0400
References: <alpine.LFD.2.01.0908211810390.3158@localhost.localdomain>
 <200908230420.46228.gene.heskett@verizon.net>
 <alpine.LFD.2.01.0908230943490.3158@localhost.localdomain>
In-reply-to: <alpine.LFD.2.01.0908230943490.3158@localhost.localdomain>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-1
Content-transfer-encoding: 7bit
Content-disposition: inline
Message-id: <200908232222.40377.gene.heskett@verizon.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sunday 23 August 2009, Linus Torvalds wrote:
>Gene - good news and bad news.
>
>The good news is that this is almost certainly not a kernel bug.
>
>The bad news is that your machine is almost certainly buggy and you'll
>need to replace your RAM (although it's possible that just removing it
>and re-seating it could fix things). See for details below.
>
Spot on!

Which, when I had a chance today after memtest ran and found a stuck bit 
00004000 at 2 separate addresses fairly early in the testing, I let it run 
for another 6 hours while I painted some shutters, and it ran without 
incrementing the counts of those 2 addresses.  So after dinner I stripped out 
the cards as all slots are full and laid the mobo out the right side of the 
beast, then pulled all  4 1GB modules, putting the front one in the back 
slot, sorta rotating the tires. Then I let memtest run for about 45 minutes 
with no further errors.  That faint knocking sound?  Me, rapping on my head, 
cuz I should have grokked that.  I'll catchup on my email & let memtest run 
for a few hours again tomorrow.

More...

>On Sun, 23 Aug 2009, Gene Heskett wrote:
>> I changed the vmlinuz compression to gzip and rebooted to it last night,
>> and got this shortly after the bootup to -rc7 with the kernal cli
>> argument that makes sensors work on an asus board again:
>>
>> Aug 22 22:29:07 coyote kernel: [ 2449.053652] BUG: Bad page state in
>> process python  pfn:a0e93 Aug 22 22:29:07 coyote kernel: [ 2449.053658]
>> page:c28fc260 flags:80004000 count:0 mapcount:0 mapping:(null) index:0
>> Aug 22 22:29:07 coyote kernel: [ 2449.053662] Pid: 4818, comm: python Not
>> tainted 2.6.31-rc7 #3 Aug 22 22:29:07 coyote kernel: [ 2449.053664] Call
>> Trace:
>> Aug 22 22:29:07 coyote kernel: [ 2449.053672]  [<c130fb33>] ?
>> printk+0x23/0x40 Aug 22 22:29:07 coyote kernel: [ 2449.053678] 
>> [<c108352f>] bad_page+0xcf/0x150 Aug 22 22:29:07 coyote kernel: [
>> 2449.053682]  [<c10845cd>] get_page_from_freelist+0x37d/0x480 Aug 22
>> 22:29:07 coyote kernel: [ 2449.053686]  [<c10848af>]
>> __alloc_pages_nodemask+0xdf/0x520 Aug 22 22:29:07 coyote kernel: [
>> 2449.053691]  [<c1095ff9>] handle_mm_fault+0x4a9/0x9f0 Aug 22 22:29:07
>> coyote kernel: [ 2449.053695]  [<c105ca83>] ?
>> tick_dev_program_event+0x43/0xf0 Aug 22 22:29:07 coyote kernel: [
>> 2449.053699]  [<c105cbd6>] ? tick_program_event+0x36/0x60 Aug 22 22:29:07
>> coyote kernel: [ 2449.053703]  [<c1020d61>] do_page_fault+0x141/0x290 Aug
>> 22 22:29:07 coyote kernel: [ 2449.053707]  [<c1020c20>] ?
>> do_page_fault+0x0/0x290 Aug 22 22:29:07 coyote kernel: [ 2449.053710] 
>> [<c131339b>] error_code+0x73/0x78 Aug 22 22:29:07 coyote kernel: [
>> 2449.053712] Disabling lock debugging due to kernel taint
>>
>> This doesn't look exactly like the previous one but the result is
>> similar.
>
>Actually, it looks _too_ much like the previous one in one very specific
>regard: that 'page' pointer is identical. Anf that is where the 'flags'
>came from.
>
>Look here:
>> Aug 21 22:37:47 coyote kernel: [ 1030.152737] BUG: Bad page state in
>> process lzma  pfn:a1093 Aug 21 22:37:47 coyote kernel: [ 1030.152743]
>> page:c28fc260 flags:80004000 count:0 mapcount:0 mapping:(null) index:0
>>
>> Aug 22 22:29:07 coyote kernel: [ 2449.053652] BUG: Bad page state in
>> process python  pfn:a0e93 Aug 22 22:29:07 coyote kernel: [ 2449.053658]
>> page:c28fc260 flags:80004000 count:0 mapcount:0 mapping:(null) index:0
>
>and notice how "page:c28fc260" is the same, even though 'pfn' is not.

Yes, and that is I believe, the same address that memtest triggered on for 
the 1st and 3rd errors, there was another, at about 1/2 meg higher address in 
between.  I shot a pix of the memtest screen just for the records.

Its pny memory, and possibly still in warranty, I find out tomorrow for sure.

>Gene - I can almost guarantee that you have bad memory. Why?
>
> - 'pfn' is the Linux kernel "page index" - so when the two 'pfn' numbers
>    are different, that means that we're talking about different
>    physical pages, and indexes into the 'struct page[]' array.
>
> - but because the page array was allocated at different addresses
>   (probably because of slightly different configurations and timings
>   during boot), the actual physical memory location that describes those
>   different pages happens to be the same.
>
> - and I can almost guarantee that you have a bit that is stuck to 1 in
>   that RAM location. The 'flags' field is the first one in 'struct page',
>   and so it's the memory location at kernel virtual address c28fc260 that
>   is corrupt - and the way the kernel mappings work on x86, that's
>   physical address 28fc260 (at around the 40MB mark).

40.7, and 41.3 according to memtest. :)

>There is almost certainly no way that this is a kernel bug - that memory
>location is smack dab in the middle of that 'struct page[]' array, and
>there is absolutely no reason why two different kernels with clearly
>different allocations would set the same incorrect bug. I mean - it
>_could_ happen, and maybe there's some really subtle idiotic thing going
>on, but it's really unlikely.
>
>The address is just so random, and so non-special - and yet it's exactly
>the same physical address in both cases, even though it actually describes
>different things as far as the kernel is concerned. That's an almost 100%
>sure sign of a hard-error in your memory.
>
>And depending on kernel config options, that bad RAM location will be used
>for different things. In your two cases, it's been used for the 'struct
>page[]' array both times, but in other cases it could have been used for
>something else - and maybe resulted in random crashes or other odd things,
>rather than happen to get noticed by a debug test.
>
>The good news about hard memory errors is that if you boot into a memory
>tester like memtest86, it's going to find it. So we're not going to have
>to guess about whether I'm right or not - I would suggest you go download
>memtest86+ from www.memtest.org and run it. I'd just get the bootable ISO
>image of memtest86+ v2.11 and burn it to a CD, and boot it, but there are
>other ways to run that thing.
>
>It's even possible that depending on which distro you have, you may
>already have a "memtest" entry in your LILO or grub setup. I think SuSE
>installs memtest as one of the bootable options, for example.

I had an entry for it from a kubuntu install that has since committed 
suicide.  I'm about up to my armpits in fedora, so I have a mandriva 2009.1 
install on another drive that may well become the main os.  Not near as much 
trouble with codecs with an offshore verse of this.  All I need to do is get 
all my scripts and a 7GB email corpus moved.  Unforch, by the time I get that 
done the next mandriva will be out. So many things to do, and relatively 
little time to do them.  Too many other hobbies and honeydo's. :)

Thanks for not spanking me on this one Linus, I blew it, badly.

			Linus

-- 
Cheers, Gene
"There are four boxes to be used in defense of liberty:
 soap, ballot, jury, and ammo. Please use in that order."
-Ed Howdershelt (Author)
The NRA is offering FREE Associate memberships to anyone who wants them.
<https://www.nrahq.org/nrabonus/accept-membership.asp>

  I marvel at the strength of human weakness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
