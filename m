Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 8CE766B0038
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 01:30:49 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id aq17so29213iec.9
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 22:30:48 -0700 (PDT)
Message-ID: <516E3383.5060105@gmail.com>
Date: Wed, 17 Apr 2013 13:30:43 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch 0/2] mm: Add parameters to make kernel behavior at
 memory error on dirty cache selectable
References: <51662D5B.3050001@hitachi.com> <20130411134915.GH16732@two.firstfloor.org>
In-Reply-To: <20130411134915.GH16732@two.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On 04/11/2013 09:49 PM, Andi Kleen wrote:
>> As a result, if the dirty cache includes user data, the data is lost,
>> and data corruption occurs if an application uses old data.

Hi Andi,

Could you give me the link of your mce testcase?

> The application cannot use old data, the kernel code kills it if it
> would do that. And if it's IO data there is an EIO triggered.
>
> iirc the only concern in the past was that the application may miss
> the asynchronous EIO because it's cleared on any fd access.
>
> This is a general problem not specific to memory error handling,
> as these asynchronous IO errors can happen due to other reason
> (bad disk etc.)
>
> If you're really concerned about this case I think the solution
> is to make the EIO more sticky so that there is a higher chance
> than it gets returned.  This will make your data much more safe,
> as it will cover all kinds of IO errors, not just the obscure memory
> errors.
>
> Or maybe have a panic knob on any IO error for any case if you don't
> trust your application to check IO syscalls. But I would rather
> have better EIO reporting than just giving up like this.
>
> The problem of tying it just to any dirty data for memory errors
> is that most anonymous data is dirty and it doesn't have this problem
> at all (because the signals handle this and they cannot be lost)
>
> And that is a far more common case than this relatively unlikely
> case of dirty IO data.
>
> So just doing it for "dirty" is not the right knob.
>
> Basically I'm saying if you worry about unreliable IO error reporting
> fix IO error reporting, don't add random unnecessary panics to
> the memory error handling.
>
> BTW my suspicion is that if you approach this from a data driven
> perspective: that is measure how much such dirty data is typically
> around in comparison to other data it will be unlikely. Such
> a study can be done with the "page-types" program in tools/vm
>
> -Andi
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
