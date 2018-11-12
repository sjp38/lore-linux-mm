Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7616B0280
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:00:28 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 98so23155678qkp.22
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 04:00:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q45si362583qte.344.2018.11.12.04.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 04:00:27 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
	<2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
	<87bm6zaa04.fsf@oldenburg.str.redhat.com>
	<6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
	<87k1ln8o7u.fsf@oldenburg.str.redhat.com>
	<20181108201231.GE5481@ram.oc3035372033.ibm.com>
	<87bm6z71yw.fsf@oldenburg.str.redhat.com>
	<20181109180947.GF5481@ram.oc3035372033.ibm.com>
Date: Mon, 12 Nov 2018 13:00:19 +0100
In-Reply-To: <20181109180947.GF5481@ram.oc3035372033.ibm.com> (Ram Pai's
	message of "Fri, 9 Nov 2018 10:09:47 -0800")
Message-ID: <87efbqqze4.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-api@vger.kernel.org

* Ram Pai:

> On Thu, Nov 08, 2018 at 09:23:35PM +0100, Florian Weimer wrote:
>> * Ram Pai:
>> 
>> > Florian,
>> >
>> > 	I can. But I am struggling to understand the requirement. Why is
>> > 	this needed?  Are we proposing a enhancement to the sys_pkey_alloc(),
>> > 	to be able to allocate keys that are initialied to disable-read
>> > 	only?
>> 
>> Yes, I think that would be a natural consequence.
>> 
>> However, my immediate need comes from the fact that the AMR register can
>> contain a flag combination that is not possible to represent with the
>> existing PKEY_DISABLE_WRITE and PKEY_DISABLE_ACCESS flags.  User code
>> could write to AMR directly, so I cannot rule out that certain flag
>> combinations exist there.
>> 
>> So I came up with this:
>> 
>> int
>> pkey_get (int key)
>> {
>>   if (key < 0 || key > PKEY_MAX)
>>     {
>>       __set_errno (EINVAL);
>>       return -1;
>>     }
>>   unsigned int index = pkey_index (key);
>>   unsigned long int amr = pkey_read ();
>>   unsigned int bits = (amr >> index) & 3;
>> 
>>   /* Translate from AMR values.  PKEY_AMR_READ standing alone is not
>>      currently representable.  */
>>   if (bits & PKEY_AMR_READ)
>
> this should be
>    if (bits & (PKEY_AMR_READ|PKEY_AMR_WRITE))

This would return zero for PKEY_AMR_READ alone.

>>     return PKEY_DISABLE_ACCESS;
>
>
>>   else if (bits == PKEY_AMR_WRITE)
>>     return PKEY_DISABLE_WRITE;
>>   return 0;
>> }

It's hard to tell whether PKEY_DISABLE_ACCESS is better in this case.
Which is why I want PKEY_DISABLE_READ.

>> And this is not ideal.  I would prefer something like this instead:
>> 
>>   switch (bits)
>>     {
>>       case PKEY_AMR_READ | PKEY_AMR_WRITE:
>>         return PKEY_DISABLE_ACCESS;
>>       case PKEY_AMR_READ:
>>         return PKEY_DISABLE_READ;
>>       case PKEY_AMR_WRITE:
>>         return PKEY_DISABLE_WRITE;
>>       case 0:
>>         return 0;
>>     }
>
> yes.
>  and on x86 it will be something like:
>    switch (bits)
>      {
>        case PKEY_PKRU_ACCESS :
>          return PKEY_DISABLE_ACCESS;
>        case PKEY_AMR_WRITE:
>          return PKEY_DISABLE_WRITE;
>        case 0:
>          return 0;
>      }

x86 returns the PKRU bits directly, including the nonsensical case
(PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE).

> But for this to work, why do you need to enhance the sys_pkey_alloc()
> interface?  Not that I am against it. Trying to understand if the
> enhancement is really needed.

sys_pkey_alloc performs an implicit pkey_set for the newly allocated key
(that is, it updates the PKRU/AMR register).  It makes sense to match
the behavior of the userspace implementation.

Thanks,
Florian
