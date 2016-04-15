Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id B9FAC6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 14:24:14 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id e185so216449532vkb.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:24:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w186si24186463qhe.26.2016.04.15.11.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 11:24:14 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	<x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	<1460739288.3012.3.camel@intel.com>
	<x49potq6bm2.fsf@segfault.boston.devel.redhat.com>
	<1460741821.3012.11.camel@intel.com>
	<CAPcyv4hemNM4uQYCPBXyH+DWTOLvyBNBeMYstKbPdad_Cw48HQ@mail.gmail.com>
	<x49lh4e6928.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4hRQj2ZsFj7Xa_=OwcHrzP9_5yUpt3LQ+bPH4PcLe7UCQ@mail.gmail.com>
Date: Fri, 15 Apr 2016 14:24:10 -0400
In-Reply-To: <CAPcyv4hRQj2ZsFj7Xa_=OwcHrzP9_5yUpt3LQ+bPH4PcLe7UCQ@mail.gmail.com>
	(Dan Williams's message of "Fri, 15 Apr 2016 11:17:39 -0700")
Message-ID: <x494mb2ivcl.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "hch@infradead.org" <hch@infradead.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "david@fromorbit.com" <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>

Dan Williams <dan.j.williams@intel.com> writes:

> On Fri, Apr 15, 2016 at 11:06 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
>> Dan Williams <dan.j.williams@intel.com> writes:
>>
>>>>> There's a lot of special casing here, so you might consider adding
>>>>> comments.
>>>>
>>>> Correct - maybe we should reconsider wrapper-izing this? :)
>>>
>>> Another option is just to skip dax_do_io() and this special casing
>>> fallback entirely if errors are present.  I.e. only attempt dax_do_io
>>> when: IS_DAX() && gendisk->bb && bb->count == 0.
>>
>> So, if there's an error anywhere on the device, penalize all I/O (not
>> just writes, and not just on sectors that are bad)?  I'm not sure that's
>> a great plan, either.
>>
>
> If errors are rare how much are we actually losing in practice?

How long is a piece of string?

> Moreover, we're going to do the full badblocks lookup anyway when we
> call ->direct_access().  If we had that information earlier we can
> avoid this fallback dance.

None of the proposed approaches looks clean to me.  I'll go along with
whatever you guys think is best.  I am in favor of wrapping up all that
duplicated code, though.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
