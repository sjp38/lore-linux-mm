Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31B7E6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 14:17:41 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id z8so37835346igl.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:17:41 -0700 (PDT)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id a65si9380852otc.128.2016.04.15.11.17.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 11:17:40 -0700 (PDT)
Received: by mail-ob0-x22d.google.com with SMTP id n10so9687293obb.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:17:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <x49lh4e6928.fsf@segfault.boston.devel.redhat.com>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	<x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	<1460739288.3012.3.camel@intel.com>
	<x49potq6bm2.fsf@segfault.boston.devel.redhat.com>
	<1460741821.3012.11.camel@intel.com>
	<CAPcyv4hemNM4uQYCPBXyH+DWTOLvyBNBeMYstKbPdad_Cw48HQ@mail.gmail.com>
	<x49lh4e6928.fsf@segfault.boston.devel.redhat.com>
Date: Fri, 15 Apr 2016 11:17:39 -0700
Message-ID: <CAPcyv4hRQj2ZsFj7Xa_=OwcHrzP9_5yUpt3LQ+bPH4PcLe7UCQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "hch@infradead.org" <hch@infradead.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "david@fromorbit.com" <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>

On Fri, Apr 15, 2016 at 11:06 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
> Dan Williams <dan.j.williams@intel.com> writes:
>
>>>> There's a lot of special casing here, so you might consider adding
>>>> comments.
>>>
>>> Correct - maybe we should reconsider wrapper-izing this? :)
>>
>> Another option is just to skip dax_do_io() and this special casing
>> fallback entirely if errors are present.  I.e. only attempt dax_do_io
>> when: IS_DAX() && gendisk->bb && bb->count == 0.
>
> So, if there's an error anywhere on the device, penalize all I/O (not
> just writes, and not just on sectors that are bad)?  I'm not sure that's
> a great plan, either.
>

If errors are rare how much are we actually losing in practice?
Moreover, we're going to do the full badblocks lookup anyway when we
call ->direct_access().  If we had that information earlier we can
avoid this fallback dance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
