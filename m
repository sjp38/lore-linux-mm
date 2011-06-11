Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 450D16B0012
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 13:18:51 -0400 (EDT)
Received: by iwg8 with SMTP id 8so3986470iwg.14
        for <linux-mm@kvack.org>; Sat, 11 Jun 2011 10:18:49 -0700 (PDT)
Message-ID: <4DF3A376.1000601@gmail.com>
Date: Sat, 11 Jun 2011 11:18:46 -0600
From: Robert Hancock <hancockrwd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
References: <20110610004331.13672278.akpm@linux-foundation.org> <BANLkTimC8K2_H7ZEu2XYoWdA09-3XxpV7Q@mail.gmail.com> <20110610091233.GJ24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101150280.17197@chino.kir.corp.google.com> <20110610185858.GN24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101456080.23076@chino.kir.corp.google.com> <20110610220748.GO24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101510000.23076@chino.kir.corp.google.com> <20110610222020.GP24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101526390.24646@chino.kir.corp.google.com> <20110611094500.GA2356@debian.cable.virginmedia.net>
In-Reply-To: <20110611094500.GA2356@debian.cable.virginmedia.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: David Rientjes <rientjes@google.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

On 06/11/2011 03:45 AM, Catalin Marinas wrote:
> On Fri, Jun 10, 2011 at 03:30:35PM -0700, David Rientjes wrote:
>> On Fri, 10 Jun 2011, Russell King - ARM Linux wrote:
>>> So those platforms which don't have a DMA zone, don't have any problems
>>> with DMA, yet want to use the very same driver which does have a problem
>>> on ISA hardware have to also put up with a useless notification that
>>> their kernel might be broken?
>>>
>>> Are you offering to participate on other architectures mailing lists to
>>> answer all the resulting queries?
>>
>> It all depends on the wording of the "warning", it should make it clear
>> that this is not always an error condition and only affects certain types
>> of hardware which the user may or may not have.
>
> I think people will still be worried when they get a warning. And there
> are lots of platforms that don't need ZONE_DMA just because devices can
> access the full RAM. As Russell said, same drivers may be used on
> platforms that can actually do DMA only to certain areas of memory and
> require ZONE_DMA (there are several examples on ARM).
>
> If you want, you can add something like CONFIG_ARCH_HAS_ZONE_DMA across
> all the platforms that support ZONE_DMA and only get the warning if
> ZONE_DMA is available but not enabled.

It sounds to me like these drivers using GFP_DMA should really be fixed 
to use the proper DMA API. That's what it's there for. The problem is 
that GFP_DMA doesn't really mean anything generically other than "memory 
suitable for DMA according to some criteria". On x86 it means low 16MB, 
on some other platforms it presumably means other things, on others it 
means nothing at all. It's quite likely that a driver that requests 
GFP_DMA isn't likely to get exactly what it wants on all platforms (for 
example on x86 the allocation will be constrained to the low 16MB which 
is unnecessarily restrictive for most devices).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
