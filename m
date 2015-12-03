Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 521C76B0253
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 17:10:13 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so75562072pac.3
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 14:10:13 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id u84si14461713pfi.160.2015.12.03.14.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 14:10:12 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so77848396pab.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 14:10:12 -0800 (PST)
Message-ID: <5660BDC2.5060400@linaro.org>
Date: Thu, 03 Dec 2015 14:10:10 -0800
From: "Shi, Yang" <yang.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH V2 2/7] mm/gup: add gup trace points
References: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>	<1449096813-22436-3-git-send-email-yang.shi@linaro.org>	<565F8092.7000001@intel.com>	<20151202231348.7058d6e2@grimm.local.home>	<56608BA2.2050300@linaro.org> <20151203140614.75f49aad@gandalf.local.home>
In-Reply-To: <20151203140614.75f49aad@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Dave Hansen <dave.hansen@intel.com>, akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 12/3/2015 11:06 AM, Steven Rostedt wrote:
> On Thu, 03 Dec 2015 10:36:18 -0800
> "Shi, Yang" <yang.shi@linaro.org> wrote:
>
>>> called directly that calls these functions internally and the tracepoint
>>> can trap the return value.
>>
>> This will incur more changes in other subsystems (futex, kvm, etc), I'm
>> not sure if it is worth making such changes to get return value.
>
> No, it wouldn't require any changes outside of this.
>
> -long __get_user_pages(..)
> +static long __get_user_pages_internal(..)
> {
>    [..]
> }
> +
> +long __get_user_pages(..)
> +{
> +	long ret;
> +	ret = __get_user_pages_internal(..);
> +	trace_get_user_pages(.., ret)
> +}

Thanks for this. I just checked the fast version, it looks it just has 
single return path, so this should be just needed by slow version.

>
>>
>>> I can probably make function_graph tracer give return values, although
>>> it will give a return value for void functions as well. And it may give
>>> long long returns for int returns that may have bogus data in the
>>> higher bits.
>>
>> If the return value requirement is not limited to gup, the approach
>> sounds more reasonable.
>>
>
> Others have asked about it. Maybe I should do it.

If you are going to add return value in common trace code, I won't do 
the gup specific one in V3.

Thanks,
Yang

>
> -- Steve
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
