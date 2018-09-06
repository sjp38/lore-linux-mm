Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 099476B7922
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 10:13:25 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 13-v6so13101595oiq.1
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 07:13:25 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j65-v6si3657972oiy.162.2018.09.06.07.13.23
        for <linux-mm@kvack.org>;
        Thu, 06 Sep 2018 07:13:23 -0700 (PDT)
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by
 sparse
References: <cover.1535629099.git.andreyknvl@google.com>
 <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <20180831081123.6mo62xnk54pvlxmc@ltop.local>
 <20180831134244.GB19965@ZenIV.linux.org.uk>
 <CAAeHK+w86m6YztnTGhuZPKRczb-+znZ1hiJskPXeQok4SgcaOw@mail.gmail.com>
 <01cadefd-c929-cb45-500d-7043cf3943f6@arm.com>
 <20180903151026.n2jak3e4yqusnogt@ltop.local>
 <a31d3400-4523-2bda-a429-f2a221e69ee8@arm.com>
 <20180905190316.a34yycthgbamx2t3@ltop.local>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <5074b9b6-2b8d-c410-f908-b4c17dacbb2c@arm.com>
Date: Thu, 6 Sep 2018 15:13:16 +0100
MIME-Version: 1.0
In-Reply-To: <20180905190316.a34yycthgbamx2t3@ltop.local>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, linux-kselftest@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, Jacob Bramley <Jacob.Bramley@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>


On 05/09/18 20:03, Luc Van Oostenryck wrote:
> On Tue, Sep 04, 2018 at 12:27:23PM +0100, Vincenzo Frascino wrote:
>> On 03/09/18 16:10, Luc Van Oostenryck wrote:
>>> On Mon, Sep 03, 2018 at 02:49:38PM +0100, Vincenzo Frascino wrote:
>>>> On 03/09/18 13:34, Andrey Konovalov wrote:
>>>>> On Fri, Aug 31, 2018 at 3:42 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>>>>> On Fri, Aug 31, 2018 at 10:11:24AM +0200, Luc Van Oostenryck wrote:
>>>>>>> On Thu, Aug 30, 2018 at 01:41:16PM +0200, Andrey Konovalov wrote:
>>>>>>>> This patch adds __force annotations for __user pointers casts detected by
>>>>>>>> sparse with the -Wcast-from-as flag enabled (added in [1]).
>>>>>>>>
>>>>>>>> [1] https://github.com/lucvoo/sparse-dev/commit/5f960cb10f56ec2017c128ef9d16060e0145f292
>>>>>>>
>>>>>>> Hi,
>>>>>>>
>>>>>>> It would be nice to have some explanation for why these added __force
>>>>>>> are useful.
>>>>>
>>>>> I'll add this in the next version, thanks!
>>>>>
>>>>>>         It would be even more useful if that series would either deal with
>>>>>> the noise for real ("that's what we intend here, that's what we intend there,
>>>>>> here's a primitive for such-and-such kind of cases, here we actually
>>>>>> ought to pass __user pointer instead of unsigned long", etc.) or left it
>>>>>> unmasked.
>>>>>>
>>>>>>         As it is, __force says only one thing: "I know the code is doing
>>>>>> the right thing here".  That belongs in primitives, and I do *not* mean the
>>>>>> #define cast_to_ulong(x) ((__force unsigned long)(x))
>>>>>> kind.
>>>>>>
>>>>>>         Folks, if you don't want to deal with that - leave the warnings be.
>>>>>> They do carry more information than "someone has slapped __force in that place".
>>>>>>
>>>>>> Al, very annoyed by that kind of information-hiding crap...
>>>>>
>>>>> This patch only adds __force to hide the reports I've looked at and
>>>>> decided that the code does the right thing. The cases where this is
>>>>> not the case are handled by the previous patches in the patchset. I'll
>>>>> this to the patch description as well. Is that OK?
>>>>>
>>>> I think as well that we should make explicit the information that
>>>> __force is hiding.
>>>> A possible solution could be defining some new address spaces and use
>>>> them where it is relevant in the kernel. Something like:
>>>>
>>>> # define __compat_ptr __attribute__((noderef, address_space(5)))
>>>> # define __tagged_ptr __attribute__((noderef, address_space(6)))
>>>>
>>>> In this way sparse can still identify the casting and trigger a warning.
>>>>
>>>> We could at that point modify sparse to ignore these conversions when a
>>>> specific flag is passed (i.e. -Wignore-compat-ptr, -Wignore-tagged-ptr)
>>>> to exclude from the generated warnings the ones we have already dealt
>>>> with.
>>>>
>>>> What do you think about this approach?
>>>
>>> I'll be happy to add such warnings to sparse if it is useful to detect
>>> (and correct!) problems. I'm also thinking to other possiblities, like
>>> having some weaker form of __force (maybe simply __force_as (which will
>>> 'only' force the address space) or even __force_as(TO, FROM) (with TO
>>> and FROM being a mask of the address space allowed).I believe we need something here to address this type of problems and I like
>> your proposal of adding a weaker force in the form of __force_as(TO, FROM)
>> because I think it provides the right level information. 
>>
>>> However, for the specific situation here, I'm not sure that using
>>> address spaces is the right choice because I suspect that the concept
>>> of tagged pointer is orthogonal to the one of (the usual) address space
>>> (it won't be possible for a pointer to be __tagged_ptr *and* __user).
>> I was thinking to address spaces because the information seems easily accessible
>> in sparse [1], but I am certainly open to any solution that can be semantically
>> more correct.
> 
> Yes, adding a new address space is easy (and doesn't need any modification
> to sparse). Here, I think adding a new 'modifier' __tagged (much like
> __nocast, __noderef, ...) would be much more appropriate.
> I think that at this point, it would be nice to have a clear description
> of the problem and what sort of checks are wanted.
>


The problem we are trying to address here is to identify when the user pointers
are cast to integer types and to sanitize (when required) the kernel, when this
happens.

The way on which we are trying to address this problem based on what Andrey
proposed in his patch-set is to use the Top Byte Ignore feature (which is a 64 bit
specific feature).

Based on what I said I think that we require 2 'modifiers':
- __compat (or __compat_ptr) used when the kernel is dealing with user compat 
pointers (32 bit, they can not be tagged). It should behave like force
(silence warnings), but having something separate IMO makes more clear the
intention of what we are trying to do.
- __tagged (or __tagged_ptr) used when the kernel is dealing with user normal
pointers (which can be tagged). In this case sparse should still be able to trigger
a warning (that can be disabled by default as I was proposing in my previous email).
When we put a tagged identifier we declare that we analyzed the code impacted by
the conversion and eventually sanitized it. Having the warning still there allows us
or whoever is looking at the code to always go back to the identified issue.  
  
>>>
>>> OTOH, when I see already the tons of warnings for concepts established
>>> since many years (I'm thinking especially at __bitwise, see [1]) I'm a
>>> bit affraid of adding new, more specialized ones that people will
>>> understand even less how/when they need to use them.
>> Thanks for providing this statistic, it is very interesting. I understand your
>> concern, but I think that in this case we need a more specialized option not only
>> to find potential problems but even to provide the right amount of information
>> to who reads the code. 
>>
>> A solution could be to let __force_as(TO, FROM) behave like __force and silence
>> the warning by default, but have an option in sparse to re-enable it 
>> (i.e. -Wshow-force-as). 
> 
> That would be, indeed, a simple solution but IMO even more dangerous than
> __force itself (since by readingthe code with this annotation  people would 
> naturally think it only involves the AS will in fact it would be the same
> as __force). I prefer to directly implement a plain __force_as, forcing
> only the AS).
>  

Agreed, even if we can't stop people from overlooking at things, I believe that
we will all benefit if they are clearer.

>> [1]
>> ---
>> commit ee7985f0c2b29c96aefe78df4139209eb4e719d8
>> Author: Vincenzo Frascino <vincenzo.frascino@arm.com>
>> Date:   Wed Aug 15 10:55:44 2018 +0100
>>
>>     print address space number for explicit cast to ulong
>>     
>>     This patch build on top of commit b34880d ("stricter warning
>>     for explicit cast to ulong") and prints the address space
>>     number when a "warning: cast removes address space of expression"
>>     is triggered.
>>     
>>     This makes easier to discriminate in between different address
>>     spaces.
>>     
>>     A validation example is provided as well as part of this patch.
>>     
>>     Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
>>
>> diff --git a/evaluate.c b/evaluate.c
>> index 6d5d479..2fc0ebc 100644
>> --- a/evaluate.c
>> +++ b/evaluate.c
>> @@ -3017,8 +3017,12 @@ static struct symbol *evaluate_cast(struct expression *expr)
>>  		sas = stype->ctype.as;
>>  	}
>>  
>> -	if (!tas && sas > 0)
>> -		warning(expr->pos, "cast removes address space of expression");
>> +	if (!tas && sas > 0) {
>> +		if (Wcast_from_as)
>> +			warning(expr->pos, "cast removes address space of expression (<asn:%d>)", sas);
>> +		else
>> +			warning(expr->pos, "cast removes address space of expression");
>> +	}
> 
> I think that the if (Wcast_from_as) is unneeded, the <asn:%d> can be added
> even if Wcast_from_as is false. Woukd it be OK for you?
> 

Yes, it is OK for me (I put it there because I did not know if we wanted to preserve the
original behavior). Feel free to hack my patch if you want to put it on your tree.
Thanks.

> -- Luc
> 

-- 
Regards,
Vincenzo
