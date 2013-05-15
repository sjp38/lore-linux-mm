Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 321DA6B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 10:48:53 -0400 (EDT)
Message-ID: <5193A085.3020309@parallels.com>
Date: Wed, 15 May 2013 18:49:41 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/2] return value from shrinkers
References: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com> <5192523B.7030805@parallels.com> <20130515141057.GA24072@caracas.corpusers.net> <51939948.3040307@parallels.com> <20130515144704.GC24072@caracas.corpusers.net>
In-Reply-To: <20130515144704.GC24072@caracas.corpusers.net>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oskar Andero <oskar.andero@sonymobile.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Lekanovic, Radovan" <Radovan.Lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>

On 05/15/2013 06:47 PM, Oskar Andero wrote:
> On 16:18 Wed 15 May     , Glauber Costa wrote:
>> On 05/15/2013 06:10 PM, Oskar Andero wrote:
>>> On 17:03 Tue 14 May     , Glauber Costa wrote:
>>>> On 05/13/2013 06:16 PM, Oskar Andero wrote:
>>>>> Hi,
>>>>>
>>>>> In a previous discussion on lkml it was noted that the shrinkers use the
>>>>> magic value "-1" to signal that something went wrong.
>>>>>
>>>>> This patch-set implements the suggestion of instead using errno.h values
>>>>> to return something more meaningful.
>>>>>
>>>>> The first patch simply changes the check from -1 to any negative value and
>>>>> updates the comment accordingly.
>>>>>
>>>>> The second patch updates the shrinkers to return an errno.h value instead
>>>>> of -1. Since this one spans over many different areas I need input on what is
>>>>> a meaningful return value. Right now I used -EBUSY on everything for consitency.
>>>>>
>>>>> What do you say? Is this a good idea or does it make no sense at all?
>>>>>
>>>>> Thanks!
>>>>>
>>>>
>>>> Right now me and Dave are completely reworking the way shrinkers
>>>> operate. I suggest, first of all, that you take a look at that cautiously.
>>>
>>> Sounds good. Where can one find the code for that?
>>>
>> linux-mm, linux-fsdevel
>>
>> Subject is "kmemcg shrinkers", but only the second part is memcg related.
>>
>>>> On the specifics of what you are doing here, what would be the benefit
>>>> of returning something other than -1 ? Is there anything we would do
>>>> differently for a return value lesser than 1?
>>>
>>> Firstly, what bugs me is the magic and unintuitiveness of using -1 rather than a
>>> more descriptive error code. IMO, even a #define SHRINK_ERROR -1 in some header
>>> file would be better.
>>>
>>> Expanding the test to <0 will open up for more granular error checks,
>>> like -EAGAIN, -EBUSY and so on. Currently, they would all be treated the same,
>>> but maybe in the future we would like to handle them differently?
>>>
>>
>> Then in the future we change it.
>> This is not a user visible API, we are free to change it at any time,
>> under any conditions. There is only value in supporting different error
>> codes if we intend to do something different about it. Otherwise, it is
>> just churn.
>>
>> Moreover, -1 does not necessarily mean error. It means "stop shrinking".
>> There are many non-error conditions in which it could happen.
>>
> 
> Sure, maybe errno.h is not the right way to go. So, why not add the #define
> instead? E.g. STOP_SHRINKING or something better than -1.
> 
>>> Finally, looking at the code:
>>>                         if (shrink_ret == -1)
>>>                                 break;
>>>                         if (shrink_ret < nr_before)
>>>                                 ret += nr_before - shrink_ret;
>>>
>>> This piece of code will only function if shrink_ret is either greater than zero
>>> or -1. If shrink_ret is -2 this will lead to undefined behaviour.
>>>
>> Except it never is. But since we are touching this code anyway, I see no
>> problems in expanding the test. What I don't see the point for, is the
>> other patch in your series in which you return error codes.
>>
>>>> So far, shrink_slab behaves the same, you are just expanding the test.
>>>> If you really want to push this through, I would suggest coming up with
>>>> a more concrete reason for why this is wanted.
>>>
>>> I don't know how well this patch is aligned with your current rework, but
>>> based on my comments above, I don't see a reason for not taking it.
>>>
>> I see no objections for PATCH #1 that expands the check, as a cautionary
>> measure. But I will oppose returning error codes from shrinkers without
>> a solid reason for doing so (meaning a use case in which we really
>> threat one of the errors differently)
> 
> Sorry for being over-zealous about the return codes and I understand
> that it is really a minor thing and possibly also a philosophical
> question. My only "solid" reasons are unintuiveness and readability.
> That is how I came across it in the first place.
> 
> If no-one backs me up on this I will drop the second patch and resend
> the first patch without RFC prefix.
> 
If you are willing to wait a bit until it finally gets merged, please
send it against my memcg.git in kernel.org (branch
kmemcg-lru-shrinkers). I can carry your patch in our series.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
