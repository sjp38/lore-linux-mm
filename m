Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 903836B02F3
	for <linux-mm@kvack.org>; Wed, 24 May 2017 13:06:26 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n188so221299593oig.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:06:26 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g41si3018803otd.261.2017.05.24.10.06.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 10:06:25 -0700 (PDT)
Received: from mail-yw0-f177.google.com (mail-yw0-f177.google.com [209.85.161.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D7483239F9
	for <linux-mm@kvack.org>; Wed, 24 May 2017 17:06:24 +0000 (UTC)
Received: by mail-yw0-f177.google.com with SMTP id l74so92347818ywe.2
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:06:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170524165710.GG19448@e104818-lin.cambridge.arm.com>
References: <1495474514-24425-1-git-send-email-catalin.marinas@arm.com>
 <20170523203700.GW8951@wotan.suse.de> <20170524165710.GG19448@e104818-lin.cambridge.arm.com>
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Wed, 24 May 2017 10:06:03 -0700
Message-ID: <CAB=NE6XiL98RAv3hSRsvDjmDmkOckymQ-pKcQh=oNVfhU6FtOg@mail.gmail.com>
Subject: Re: [PATCH] mm: kmemleak: Treat vm_struct as alternative reference to
 vmalloc'ed objects
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andy Lutomirski <luto@amacapital.net>

On Wed, May 24, 2017 at 9:57 AM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> On Tue, May 23, 2017 at 10:37:00PM +0200, Luis R. Rodriguez wrote:
>> On Mon, May 22, 2017 at 06:35:14PM +0100, Catalin Marinas wrote:
>> > Kmemleak requires that vmalloc'ed objects have a minimum reference count
>> > of 2: one in the corresponding vm_struct object and the other owned by
>> > the vmalloc() caller. There are cases, however, where the original
>> > vmalloc() returned pointer is lost and, instead, a pointer to vm_struct
>> > is stored (see free_thread_stack()). Kmemleak currently reports such
>> > objects as leaks.
>> >
>> > This patch adds support for treating any surplus references to an object
>> > as additional references to a specified object. It introduces the
>> > kmemleak_vmalloc() API function which takes a vm_struct pointer and sets
>> > its surplus reference passing to the actual vmalloc() returned pointer.
>> > The __vmalloc_node_range() calling site has been modified accordingly.
>> >
>> > An unrelated minor change is included in this patch to change the type
>> > of kmemleak_object.flags to unsigned int (previously unsigned long).
>> >
>> > Reported-by: "Luis R. Rodriguez" <mcgrof@kernel.org>
>>
>> Tested-by: Luis R. Rodriguez <mcgrof@kernel.org>
>
> Thanks.
>
>> > diff --git a/mm/kmemleak.c b/mm/kmemleak.c
>> > index 20036d4f9f13..11ab654502fd 100644
>> > --- a/mm/kmemleak.c
>> > +++ b/mm/kmemleak.c
>> > @@ -1188,6 +1249,30 @@ static bool update_checksum(struct kmemleak_object *object)
>> >  }
>> >
>> >  /*
>> > + * Update an object's references. object->lock must be held by the caller.
>> > + */
>> > +static void update_refs(struct kmemleak_object *object)
>> > +{
>> > +   if (!color_white(object)) {
>> > +           /* non-orphan, ignored or new */
>> > +           return;
>> > +   }
>> > +
>> > +   /*
>> > +    * Increase the object's reference count (number of pointers to the
>> > +    * memory block). If this count reaches the required minimum, the
>> > +    * object's color will become gray and it will be added to the
>> > +    * gray_list.
>> > +    */
>> > +   object->count++;
>> > +   if (color_gray(object)) {
>> > +           /* put_object() called when removing from gray_list */
>> > +           WARN_ON(!get_object(object));
>> > +           list_add_tail(&object->gray_list, &gray_list);
>> > +   }
>> > +}
>> > +
>> > +/*
>>
>> This an initial use of it seems to be very possible and likely without the
>> vmalloc special case, ie, can this be added as a separate patch to make the
>> actual functional change easier to read ?
>
> The above is just moving code from scan_block() into a separate
> function.

Exactly.

> But I'm happy to split this patch into 2-3 patches if it's
> easier to follow.

If it does cause a regression the block of code reverted would also be
smaller to revert / inspect.

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
