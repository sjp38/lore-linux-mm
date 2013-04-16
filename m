Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 0FE936B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 03:29:26 -0400 (EDT)
Received: by mail-bk0-f50.google.com with SMTP id jg1so88440bkc.9
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 00:29:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130415135805.c552511917b0dbe113388acb@linux-foundation.org>
References: <1365748763-4350-1-git-send-email-handai.szj@taobao.com>
	<20130412171108.d3ef3e2d66e9c1bfcf69467c@mxp.nes.nec.co.jp>
	<20130415135805.c552511917b0dbe113388acb@linux-foundation.org>
Date: Tue, 16 Apr 2013 15:29:25 +0800
Message-ID: <CAFj3OHX3XZf85F7161jp8KT30fCLFmpAYCx7J-PHx7cKOkTrQA@mail.gmail.com>
Subject: Re: [PATCH] memcg: Check more strictly to avoid ULLONG overflow by PAGE_ALIGN
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jeff.liu@oracle.com, Sha Zhengju <handai.szj@taobao.com>

On Tue, Apr 16, 2013 at 4:58 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 12 Apr 2013 17:11:08 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>
>> > --- a/include/linux/res_counter.h
>> > +++ b/include/linux/res_counter.h
>> > @@ -54,7 +54,7 @@ struct res_counter {
>> >     struct res_counter *parent;
>> >  };
>> >
>> > -#define RESOURCE_MAX (unsigned long long)LLONG_MAX
>> > +#define RESOURCE_MAX (unsigned long long)ULLONG_MAX
>> >
>>
>> I don't think it's a good idea to change a user-visible value.
>
> The old value was a mistake, surely.
>
> RESOURCE_MAX shouldn't be in this header file - that is far too general
> a name.  I suggest the definition be moved to res_counter.c.  And the
> (unsigned long long) cast is surely unneeded if we're to use
> ULLONG_MAX.
>
>> >  /**
>> >   * Helpers to interact with userspace
>> > diff --git a/kernel/res_counter.c b/kernel/res_counter.c
>> > index ff55247..6c35310 100644
>> > --- a/kernel/res_counter.c
>> > +++ b/kernel/res_counter.c
>> > @@ -195,6 +195,12 @@ int res_counter_memparse_write_strategy(const char *buf,
>> >     if (*end != '\0')
>> >             return -EINVAL;
>> >
>> > -   *res = PAGE_ALIGN(*res);
>> > +   /* Since PAGE_ALIGN is aligning up(the next page boundary),
>> > +    * check the left space to avoid overflow to 0. */
>> > +   if (RESOURCE_MAX - *res < PAGE_SIZE - 1)
>> > +           *res = RESOURCE_MAX;
>> > +   else
>> > +           *res = PAGE_ALIGN(*res);
>> > +
>>
>> Current interface seems strange because we can set a bigger value than
>> the value which means "unlimited".
>
> I'm not sure what you mean by this?
>
>> So, how about some thing like:
>>
>>       if (*res > RESOURCE_MAX)
>>               return -EINVAL;
>>       if (*res > PAGE_ALIGN(RESOURCE_MAX) - PAGE_SIZE)
>>               *res = RESOURCE_MAX;
>>       else
>>               *res = PAGE_ALIGN(*res);
>>
>
> The first thing I'd do to res_counter_memparse_write_strategy() is to
> rename its second arg to `resp' then add a local called `res'.  Because
> that function dereferences res far too often.
>
> Then,
>
> -       *res = PAGE_ALIGN(*res);
>         if (PAGE_ALIGN(res) >= res)
>                 res = PAGE_ALIGN(res);
>         else
>                 res = RESOURCE_MAX;     /* PAGE_ALIGN wrapped to zero */
>
>         *resp = res;
>         return 0;
>

Okay, this one is better.


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
