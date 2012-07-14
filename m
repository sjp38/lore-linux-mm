Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 61C5A6B005A
	for <linux-mm@kvack.org>; Sat, 14 Jul 2012 08:01:41 -0400 (EDT)
Received: by obhx4 with SMTP id x4so7890875obh.14
        for <linux-mm@kvack.org>; Sat, 14 Jul 2012 05:01:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com>
References: <1342221125.17464.8.camel@lorien2>
	<alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com>
Date: Sat, 14 Jul 2012 15:01:40 +0300
Message-ID: <CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Shuah Khan <shuah.khan@hp.com>, cl@linux.com, glommer@parallels.com, js1304@gmail.com, shuahkhan@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Jul 14, 2012 at 12:18 PM, David Rientjes <rientjes@google.com> wrote:
> On Fri, 13 Jul 2012, Shuah Khan wrote:
>
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index 12637ce..aa3ca5b 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -98,7 +98,9 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
>>
>>       s = __kmem_cache_create(name, size, align, flags, ctor);
>>
>> +#ifdef CONFIG_DEBUG_VM
>>  oops:
>> +#endif
>>       mutex_unlock(&slab_mutex);
>>       put_online_cpus();
>>
>
> Tip: gcc allows label attributes so you could actually do
>
> oops: __maybe_unused
>
> to silence the warning and do the same for the "out" label later in the
> function.

I'm not exactly loving that either.

It'd probably be better to reshuffle the code so that the debug checks
end up in separate functions that are no-op for !CONFIG_DEBUG_VM. That
way the _labels_ are used unconditionally although there's no actual
code generated.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
