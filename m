Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 88E1E6B0072
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 21:00:28 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20121210103913.020858db777e2f48c59713b6@mxc.nes.nec.co.jp>
	<20121219161856.e6aa984f.akpm@linux-foundation.org>
	<20121220112103.d698c09a9d1f27a253a63d37@mxc.nes.nec.co.jp>
	<33710E6CAA200E4583255F4FB666C4E20AB2DEA3@G01JPEXMBYT03>
Date: Thu, 20 Dec 2012 18:00:11 -0800
In-Reply-To: <33710E6CAA200E4583255F4FB666C4E20AB2DEA3@G01JPEXMBYT03> (Daisuke
	Hatayama's message of "Thu, 20 Dec 2012 03:02:56 +0000")
Message-ID: <87licsrwpg.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v2] Add the values related to buddy system for filtering free pages.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hatayama, Daisuke" <d.hatayama@jp.fujitsu.com>
Cc: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "cpw@sgi.com" <cpw@sgi.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

"Hatayama, Daisuke" <d.hatayama@jp.fujitsu.com> writes:

>> From: kexec-bounces@lists.infradead.org
>> [mailto:kexec-bounces@lists.infradead.org] On Behalf Of Atsushi Kumagai
>> Sent: Thursday, December 20, 2012 11:21 AM
>
>> On Wed, 19 Dec 2012 16:18:56 -0800
>> Andrew Morton <akpm@linux-foundation.org> wrote:
>> 
>> > On Mon, 10 Dec 2012 10:39:13 +0900
>> > Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp> wrote:
>> >
>
>> >
>> > We might change the PageBuddy() implementation at any time, and
>> > makedumpfile will break.  Or in this case, become less efficient.
>> >
>> > Is there any way in which we can move some of this logic into the
>> > kernel?  In this case, add some kernel code which uses PageBuddy() on
>> > behalf of makedumpfile, rather than replicating the PageBuddy() logic
>> > in userspace?
>> 
>> In last month, Cliff Wickman proposed such idea:
>> 
>>   [PATCH v2] makedumpfile: request the kernel do page scans
>>   http://lists.infradead.org/pipermail/kexec/2012-November/007318.html
>> 
>>   [PATCH] scan page tables for makedumpfile, 3.0.13 kernel
>>   http://lists.infradead.org/pipermail/kexec/2012-November/007319.html
>> 
>> In his idea, the kernel does page scans to distinguish unnecessary pages
>> (free pages and others) and returns the list of PFN's which should be
>> excluded for makedumpfile.
>> As a result, makedumpfile doesn't need to consider internal kernel
>> behavior.
>> 
>> I think it's a good idea from the viewpoint of maintainability and
>> performance.

> I also think wide part of his code can be reused in this work. But the bad
> performance is caused by a lot of ioremap, not a lot of copying. See my
> profiling result I posted some days ago. Two issues, ioremap one and filtering
> maintainability, should be considered separately. Even on ioremap issue,
> there is secondary one to consider in memory consumption on the 2nd
> kernel.

Thanks.  I was wondering why moving the code into /proc/vmcore would
make things faster.

> Also, I have one question. Can we always think of 1st and 2nd kernels
> are same?

Not at all.  Distros frequently implement it with the same kernel in
both role but it should be possible to use an old crusty stable kernel
as the 2nd kernel.

> If I understand correctly, kexec/kdump can use the 2nd kernel different
> from the 1st's. So, differnet kernels need to do the same thing as makedumpfile
> does. If assuming two are same, problem is mush simplified.

As a developer it becomes attractive to use a known stable kernel to
capture the crash dump even as I experiment with a brand new kernel.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
