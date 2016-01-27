Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id E146B6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 23:26:25 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id 6so156191741qgy.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 20:26:25 -0800 (PST)
Received: from mail-qk0-x231.google.com (mail-qk0-x231.google.com. [2607:f8b0:400d:c09::231])
        by mx.google.com with ESMTPS id s104si4877290qgd.51.2016.01.26.20.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 20:26:25 -0800 (PST)
Received: by mail-qk0-x231.google.com with SMTP id s5so72615416qkd.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 20:26:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160127035215.GA7813@js1304-P5Q-DELUXE>
References: <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20160126141152.e1043d14502dcca17813afb3@linux-foundation.org>
	<CAPcyv4hytzxpNt2RT6b5M6iuqz6V3GdSnO3eHwqpHVt4gfXPxg@mail.gmail.com>
	<20160126145153.44e4f38b04200209d133c0a3@linux-foundation.org>
	<CAPcyv4im4yQqLqRW9DsNRVsRTgWH1CPu1diJryZ4T57rDCWrzg@mail.gmail.com>
	<20160127011817.GA7398@js1304-P5Q-DELUXE>
	<CAPcyv4i9-mdPCVdrODOWS19vKKJJYuMZrvXbZ9eZKZc3Ua3QRA@mail.gmail.com>
	<20160127021515.GA7562@js1304-P5Q-DELUXE>
	<CAPcyv4hbdMymT5AWKoQXMjzmLLsiAMPT3HnEFi4i93ydkd69WQ@mail.gmail.com>
	<20160127035215.GA7813@js1304-P5Q-DELUXE>
Date: Tue, 26 Jan 2016 20:26:24 -0800
Message-ID: <CAA9_cmdgLJD-XYy0MyoQMmLOUHro=jYNsW_Sh13gL95y7537xA@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: support CONFIG_ZONE_DEVICE + CONFIG_ZONE_DMA
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Rik van Riel <riel@redhat.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Jerome Glisse <j.glisse@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Tue, Jan 26, 2016 at 7:52 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Tue, Jan 26, 2016 at 07:23:59PM -0800, Dan Williams wrote:
>> On Tue, Jan 26, 2016 at 6:15 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>> > On Tue, Jan 26, 2016 at 05:37:38PM -0800, Dan Williams wrote:
>> >> On Tue, Jan 26, 2016 at 5:18 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>> [..]
>> >> > Please refer my previous attempt to add a new zone, ZONE_CMA.
>> >> >
>> >> > https://lkml.org/lkml/2015/2/12/84
>> >> >
>> >> > It salvages a bit from SECTION_WIDTH by increasing section size.
>> >> > Similarly, I guess we can reduce NODE_WIDTH if needed although
>> >> > it could cause to reduce maximum node size.
>> >>
>> >> Dave pointed out to me that LAST__PID_SHIFT might be a better
>> >> candidate to reduce to 7 bits.  That field is for storing pids which
>> >> are already bigger than 8 bits.  If it is relying on the fact that
>> >> pids don't rollover very often then likely the impact of 7-bits
>> >> instead of 8 will be minimal.
>> >
>> > Hmm... I'm not sure it's possible or not, but, it looks not a general
>> > solution. It will solve your problem because you are using 64 bit arch
>> > but other 32 bit archs can't get the benefit.
>>
>> This is where the ZONE_CMA and ZONE_DEVICE efforts diverge.
>> ZONE_DEVICE is meant to enable DMA access to hundreds of gigagbytes of
>> persistent memory.  A 64-bit-only limitation for ZONE_DEVICE is
>> reasonable.
>
> Yes, but, my point is that if someone need another zone like as
> ZONE_CMA, they couldn't get the benefit from this change. They need to
> re-investigate what bits they can reduce and need to re-do all things.
>
> If it is implemented more generally at this time, it can relieve their
> burden and less churn the code. It would be helpful for maintainability.

I agree in principle that finding a 32-bit compatible solution is
desirable, but it simply may not be feasible.

For now, I'll help with auditing the existing bits so we can enumerate
the tradeoffs.

Hmm, one tradeoff that comes to mind for 32-bit is sacrificing
ZONE_HIGHMEM, for ZONE_CMA.  Are there configurations that need both
enabled?  If a platform needs highmem it really should be using a
64-bit kernel (if possible), desire for ZONE_CMA might be a nice
encouragement to lessen the prevalence of highmem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
