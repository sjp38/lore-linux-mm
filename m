Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 258DE8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 21:21:32 -0500 (EST)
Message-ID: <4D5DD7F9.30202@cn.fujitsu.com>
Date: Fri, 18 Feb 2011 10:22:49 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] cpuset: Remove unneeded NODEMASK_ALLOC() in cpuset_sprintf_memlist()
References: <4D5C7EA7.1030409@cn.fujitsu.com> <AANLkTinsj4OagOQhaPL=6-3awQo9ssh06NgwTg1kOsYh@mail.gmail.com>
In-Reply-To: <AANLkTinsj4OagOQhaPL=6-3awQo9ssh06NgwTg1kOsYh@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

Paul Menage wrote:
> On Wed, Feb 16, 2011 at 5:49 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>> It's not necessary to copy cpuset->mems_allowed to a buffer
>> allocated by NODEMASK_ALLOC(). Just pass it to nodelist_scnprintf().
>>
>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> 
> Acked-by: Paul Menage <menage@google.com>
> 
> The only downside is that we're now doing more work (and more complex
> work) inside callback_mutex, but I guess that's OK compared to having
> to do a memory allocation. (I poked around in lib/vsprintf.c and I
> couldn't see any cases where it might allocate memory, but it would be
> particularly bad if there was any way to trigger an Oops.)
> 
>> ---
>>  kernel/cpuset.c |   10 +---------
>>  1 files changed, 1 insertions(+), 9 deletions(-)
>>
>> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
>> index 10f1835..f13ff2e 100644
>> --- a/kernel/cpuset.c
>> +++ b/kernel/cpuset.c
>> @@ -1620,20 +1620,12 @@ static int cpuset_sprintf_cpulist(char *page, struct cpuset *cs)
>>
>>  static int cpuset_sprintf_memlist(char *page, struct cpuset *cs)
>>  {
>> -       NODEMASK_ALLOC(nodemask_t, mask, GFP_KERNEL);
>>        int retval;
>>
>> -       if (mask == NULL)
>> -               return -ENOMEM;
>> -
> 
> And this was particularly broken since the only caller of
> cpuset_sprintf_memlist() doesn't handle a negative error response
> anyway and would then overwrite byte 4083 on the preceding page with a
> '\n'. And then since the (size_t)(s-page) that's passed to
> simple_read_from_buffer() would be a very large number, it would write
> arbitrary (user-controlled) amounts of kernel data to the userspace
> buffer.
> 
> Maybe we could also rename 'retval' to 'count' in this function (and
> cpuset_sprintf_cpulist()) to make it clearer that callers don't expect
> negative error values?
> 

Good spot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
