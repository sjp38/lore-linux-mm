Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id D5CFC6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 14:49:46 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id bs12so1339258qab.14
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 11:49:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5160C244.6080807@gmail.com>
References: <20130325134247.GB1393@localhost.localdomain> <515CF884.8010103@gmail.com>
 <CAF-E8XFQFm9GrBnkax+TiByUPHxp=Ukp1LcuAWjYL0OeLE1Saw@mail.gmail.com> <5160C244.6080807@gmail.com>
From: Andrew Shewmaker <agshew@gmail.com>
Date: Mon, 8 Apr 2013 12:49:25 -0600
Message-ID: <CAF-E8XHnTTUPm1s5RF2wEC-sjt3wYDhLgj__UQRz-b6AyC++vQ@mail.gmail.com>
Subject: Re: [PATCH v7 2/2] mm: replace hardcoded 3% with admin_reserve_pages knob
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, ric.masonn@gmail.com

On Sat, Apr 6, 2013 at 6:48 PM, Simon Jeons <simon.jeons@gmail.com> wrote:
> Hi Andrew,
>
> On 04/05/2013 11:02 PM, Andrew Shewmaker wrote:
>>
>> On Wed, Apr 3, 2013 at 9:50 PM, Simon Jeons <simon.jeons@gmail.com> wrote:
>>>>
>>>> FAQ
>>>>
>> ...
>>>>
>>>>    * How do you calculate a minimum useful reserve?
>>>>
>>>>      A user or the admin needs enough memory to login and perform
>>>>      recovery operations, which includes, at a minimum:
>>>>
>>>>      sshd or login + bash (or some other shell) + top (or ps, kill,
>>>> etc.)
>>>>
>>>>      For overcommit 'guess', we can sum resident set sizes (RSS).
>>>>      On x86_64 this is about 8MB.
>>>>
>>>>      For overcommit 'never', we can take the max of their virtual sizes
>>>> (VSZ)
>>>>      and add the sum of their RSS.
>>>>      On x86_64 this is about 128MB.
>>>
>>>
>>> 1.Why has this different between guess and never?
>>
>> The default, overcommit 'guess' mode, only needs a reserve for
>> what the recovery programs will typically use. Overcommit 'never'
>> mode will only successfully launch an app when it can fulfill all of
>> its requested memory allocations--even if the app only uses a
>> fraction of what it asks for.
>
>
> VSZ has already cover RSS, is it? why account RSS again?

Right. Technically, I could leave out the RSS of the process that
I'm taking the VSZ of. Leaving it in makes the estimate 2-4 MB
larger, but it is just an estimate.

Choosing a good minimum is difficult because the behavior with
and without swap is different. With swap, only about 8MB reserves
are needed whether overcommit is disabled or not. Without swap,
I was always able to recover when I set the reserves to over 230MB
each. However, I was often able to recover with much less.

128MB seemed to me like a decent compromise between swap
and noswap modes, but it isn't totally safe for the case when
both swap and memory overcommit are disabled. In that case,
I think that an admin will have to tune the reserves for their specific
situation.

--
Andrew Shewmaker

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
