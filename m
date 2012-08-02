Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 30BE96B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 12:47:41 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so5283654bkc.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 09:47:39 -0700 (PDT)
Message-ID: <501AAF47.3090708@gmail.com>
Date: Thu, 02 Aug 2012 18:48:07 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
References: <50197460.8010906@gmail.com> <20120801182749.GD15477@google.com> <50197E4A.7020408@gmail.com> <20120801202432.GE15477@google.com> <5019B0B4.1090102@gmail.com> <20120801224556.GF15477@google.com> <501A4FC1.8040907@gmail.com> <20120802103244.GA23318@leaf> <501A633B.3010509@gmail.com> <501A7AD3.7000008@gmail.com> <20120802161556.GA25572@leaf>
In-Reply-To: <20120802161556.GA25572@leaf>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On 08/02/2012 06:15 PM, Josh Triplett wrote:
> On Thu, Aug 02, 2012 at 03:04:19PM +0200, Sasha Levin wrote:
>> On 08/02/2012 01:23 PM, Sasha Levin wrote:
>>>> #define DEFINE_HASH_TABLE(name, length) struct hash_table name = { .count = length, .buckets = { [0 ... (length - 1)] = HLIST_HEAD_INIT } }
>>> The limitation of this approach is that the struct hash_table variable must be 'static', which is a bit limiting - see for example the use of hashtable in 'struct user_namespace'.
>>>
>>
>> What if we just use two possible decelerations? One of static structs and one for regular ones.
>>
>> struct hash_table {
>>         size_t bits;
>>         struct hlist_head buckets[];
>> };
>>
>> #define DEFINE_HASHTABLE(name, bits)                                    \
>>         union {                                                         \
>>                 struct hash_table name;                                 \
>>                 struct {                                                \
>>                         size_t bits;                                    \
> 
> This shouldn't use "bits", since it'll get expanded to the macro
> argument.
> 
>>                         struct hlist_head buckets[1 << bits];           \
>>                 } __name;                                               \
> 
> __##name
> 
>>         }
>>
>> #define DEFINE_STATIC_HASHTABLE(name, bit)                              \
>>         static struct hash_table name = { .bits = bit,                  \
>>                 .buckets = { [0 ... (bit - 1)] = HLIST_HEAD_INIT } }
> 
> You probably wanted to change that to [0 ... ((1 << bit) - 1)] , to
> match DEFINE_HASHTABLE.

I wrote it by hand and didn't compile test, will fix all of those.

> Since your definition of DEFINE_HASHTABLE would also work fine when used
> statically, why not just always use that?
> 
> #define DEFINE_STATIC_HASHTABLE(name, bits) static DEFINE_HASHTABLE(name, bits) = { .name.bits = bits }

It will get defined fine, but it will be awkward to use. We'd need to pass anonymous union to all the functions that handle this hashtable, which isn't pretty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
