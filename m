Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id DDD896B0005
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 19:33:14 -0500 (EST)
Received: from mail-vb0-f49.google.com ([209.85.212.49])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1U14Z7-00067z-LU
	for linux-mm@kvack.org; Fri, 01 Feb 2013 00:33:13 +0000
Received: by mail-vb0-f49.google.com with SMTP id s24so2121095vbi.22
        for <linux-mm@kvack.org>; Thu, 31 Jan 2013 16:33:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130131154331.09d157a3.akpm@linux-foundation.org>
References: <20130128091039.GG6871@arwen.pp.htv.fi>
	<CACVXFVOATzTJq+-5M9j3G3y_WUrWKJt=naPkjkLwGDmT0H8gog@mail.gmail.com>
	<20130131154331.09d157a3.akpm@linux-foundation.org>
Date: Fri, 1 Feb 2013 08:33:12 +0800
Message-ID: <CACVXFVO415U1amgUUOoy_1CLjfUqw98QqD8mCVixAzNQ2_Nzqw@mail.gmail.com>
Subject: Re: Page allocation failure on v3.8-rc5
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: balbi@ti.com, Linux USB Mailing List <linux-usb@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

On Fri, Feb 1, 2013 at 7:43 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 30 Jan 2013 19:53:22 +0800
> Ming Lei <ming.lei@canonical.com> wrote:
>
>> The allocation failure is caused by the big sizeof(struct parsed_partitions),
>> which is 64K in my 32bit box,
>
> Geeze.
>
> We could fix that nicely by making parsed_partitions.parts an array of
> pointers to a single `struct parsed_partition' and allocating those
> on-demand.
>
> But given the short-lived nature of this storage and the infrequency of
> check_partition(), that isn't necessary.
>
>> could you test the blow patch to see
>> if it can fix the allocation failure?
>
> (The patch is wordwrapped)

Sorry for that, I send out it for test.

>
>> ...
>>
>> @@ -106,18 +107,43 @@ static int (*check_part[])(struct parsed_partitions *) = {
>>       NULL
>>  };
>>
>> +struct parsed_partitions *allocate_partitions(int nr)
>> +{
>> +     struct parsed_partitions *state;
>> +
>> +     state = kzalloc(sizeof(struct parsed_partitions), GFP_KERNEL);
>
> I personally prefer sizefo(*state) here.  It means the reader doesn't
> have to scroll back to check things.

OK, will use sizeof(*state).

>> +     if (!state)
>> +             return NULL;
>> +
>> +     state->parts = vzalloc(nr * sizeof(state->parts[0]));
>> +     if (!state->parts) {
>> +             kfree(state);
>> +             return NULL;
>> +     }
>
> It doesn't really need to be this complex - we could just vmalloc the
> entire `struct parsed_partitions'.  But I see that your change will

The above approach can save one 32K allocation approximately.

> cause us to allcoate much less memory in many situations, which is
> good.  It should be mentioned in the changelog!

OK, I will add the changelog later.


Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
