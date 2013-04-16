Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 5D64C6B0006
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 03:30:16 -0400 (EDT)
Received: by mail-bk0-f46.google.com with SMTP id je9so89532bkc.33
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 00:30:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130416102938.e52fdf864f6991b960b8b055@mxp.nes.nec.co.jp>
References: <1365748763-4350-1-git-send-email-handai.szj@taobao.com>
	<20130412171108.d3ef3e2d66e9c1bfcf69467c@mxp.nes.nec.co.jp>
	<20130415135805.c552511917b0dbe113388acb@linux-foundation.org>
	<20130416102938.e52fdf864f6991b960b8b055@mxp.nes.nec.co.jp>
Date: Tue, 16 Apr 2013 15:30:14 +0800
Message-ID: <CAFj3OHXLw+FAQsdbMDLt5EayGkgs2qsc9VVw16uA_c_-32kqrg@mail.gmail.com>
Subject: Re: [PATCH] memcg: Check more strictly to avoid ULLONG overflow by PAGE_ALIGN
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jeff.liu@oracle.com, Sha Zhengju <handai.szj@taobao.com>

On Tue, Apr 16, 2013 at 9:29 AM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> On Mon, 15 Apr 2013 13:58:05 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Fri, 12 Apr 2013 17:11:08 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>>
>> > > --- a/include/linux/res_counter.h
>> > > +++ b/include/linux/res_counter.h
>> > > @@ -54,7 +54,7 @@ struct res_counter {
>> > >   struct res_counter *parent;
>> > >  };
>> > >
>> > > -#define RESOURCE_MAX (unsigned long long)LLONG_MAX
>> > > +#define RESOURCE_MAX (unsigned long long)ULLONG_MAX
>> > >
>> >
>> > I don't think it's a good idea to change a user-visible value.
>>
>> The old value was a mistake, surely.
>>
>
> I introduced 'RESOURCE_MAX' in commit:c5b947b2, but I just used the
> default value of the res_counter.limit. I'm not sure why it had been
> initialized to (unsigned long long)LLONG_MAX.

Then let's correct it now.

>
>> RESOURCE_MAX shouldn't be in this header file - that is far too general
>> a name.  I suggest the definition be moved to res_counter.c.  And the
>> (unsigned long long) cast is surely unneeded if we're to use
>> ULLONG_MAX.
>>
>
> Hmm, RESOUCE_MAX is now used outside of res_counter.c(e.g. tcp_memcontrol.c).

Yeah, and another mm/memcontrol.c used it too.

> Adding Glauber Costa to the cc list.
> Just changing the name to RES_COUNTER_MAX might be the choice.
>
>> > >  /**
>> > >   * Helpers to interact with userspace
>> > > diff --git a/kernel/res_counter.c b/kernel/res_counter.c
>> > > index ff55247..6c35310 100644
>> > > --- a/kernel/res_counter.c
>> > > +++ b/kernel/res_counter.c
>> > > @@ -195,6 +195,12 @@ int res_counter_memparse_write_strategy(const char *buf,
>> > >   if (*end != '\0')
>> > >           return -EINVAL;
>> > >
>> > > - *res = PAGE_ALIGN(*res);
>> > > + /* Since PAGE_ALIGN is aligning up(the next page boundary),
>> > > +  * check the left space to avoid overflow to 0. */
>> > > + if (RESOURCE_MAX - *res < PAGE_SIZE - 1)
>> > > +         *res = RESOURCE_MAX;
>> > > + else
>> > > +         *res = PAGE_ALIGN(*res);
>> > > +
>> >
>> > Current interface seems strange because we can set a bigger value than
>> > the value which means "unlimited".
>>
>> I'm not sure what you mean by this?
>>
> 9223372036854775807(LLONG_MAX) means "unlimited" now. But we can set a bigger
> value than that.
>
> # cat /cgroup/memory/A/memory.memsw.limit_in_bytes
> 9223372036854775807
> # echo 9223372036854775808 >/cgroup/memory/A/memory.memsw.limit_in_bytes
> # cat /cgroup/memory/A/memory.memsw.limit_in_bytes
> 9223372036854775808
>
> I feel "bigger than unlimited" is strange.
>
>> > So, how about some thing like:
>> >
>> >     if (*res > RESOURCE_MAX)
>> >             return -EINVAL;
>> >     if (*res > PAGE_ALIGN(RESOURCE_MAX) - PAGE_SIZE)
>> >             *res = RESOURCE_MAX;
>> >     else
>> >             *res = PAGE_ALIGN(*res);
>> >
>>
>> The first thing I'd do to res_counter_memparse_write_strategy() is to
>> rename its second arg to `resp' then add a local called `res'.  Because
>> that function dereferences res far too often.
>>
>> Then,
>>
>> -     *res = PAGE_ALIGN(*res);
>>       if (PAGE_ALIGN(res) >= res)
>>               res = PAGE_ALIGN(res);
>>       else
>>               res = RESOURCE_MAX;     /* PAGE_ALIGN wrapped to zero */
>>
>>       *resp = res;
>>       return 0;
>>
>>
> Good idea :)
>
>
> Thanks,
> Daisuke Nishimura.



--
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
