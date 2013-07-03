Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id C97636B0037
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 09:10:57 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id a12so101044wgh.28
        for <linux-mm@kvack.org>; Wed, 03 Jul 2013 06:10:56 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <CA+icZUV0bCUDxd8qtzS-zNGwM+JKEqC4uTCxmsOH8jbNVddPXA@mail.gmail.com>
References: <1372853998-15353-1-git-send-email-sedat.dilek@gmail.com>
	<51D41E34.5010802@huawei.com>
	<CA+icZUV0bCUDxd8qtzS-zNGwM+JKEqC4uTCxmsOH8jbNVddPXA@mail.gmail.com>
Date: Wed, 3 Jul 2013 15:10:56 +0200
Message-ID: <CA+icZUWR4AXDfRXXhhq0UHnn7Q7r=WY7XpShS7YWOiKLuy30PA@mail.gmail.com>
Subject: Re: [PATCH next-20130703] net: sock: Add ifdef CONFIG_MEMCG_KMEM for mem_cgroup_sockets_{init,destroy}
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: akpm@linux-foundation.org, davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, linux-mm@kvack.org

On Wed, Jul 3, 2013 at 3:09 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> On Wed, Jul 3, 2013 at 2:51 PM, Li Zefan <lizefan@huawei.com> wrote:
>> On 2013/7/3 20:19, Sedat Dilek wrote:
>>> When "CONFIG_MEMCG_KMEM=n" I see this in my build-log:
>>>
>>>  LD      init/built-in.o
>>> mm/built-in.o: In function `mem_cgroup_css_free':
>>> memcontrol.c:(.text+0x5caa6): undefined reference to `mem_cgroup_sockets_destroy'
>>> make[2]: *** [vmlinux] Error 1
>>>
>>> Inspired by the ifdef for mem_cgroup_sockets_{init,destroy} here...
>>>
>>> [ net/core/sock.c ]
>>>
>>>  #ifdef CONFIG_MEMCG_KMEM
>>>  int mem_cgroup_sockets_init()
>>>  ...
>>>  void mem_cgroup_sockets_destroy()
>>>  ...
>>>  #endif
>>>
>>> ...I did the the same for both in "include/net/sock.h".
>>>
>>> This fixes the issue for me in next-20130703.
>>>
>>> Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>
>>
>> Maybe it's better to add memcg_destroy_kmem(), to pair with
>> memcg_init_kmem().
>>
>> This patch can be folded into "memcg: use css_get/put when charging/uncharging kmem"
>>
>
> Hi Li Zefan,
>
> Can you or a guru from netdev explain me why there exists
> mem_cgroup_sockets_init() and mem_cgroup_sockets_destroy() in
>
> 1. net/core/sock.c <--- AFAICS this includes below sock.h, too.
> 2. net/core/sock.h <--- mm/memcontrol.c is including this one.
>

*** include/net/sock.h ***

- Sedat -

> Make me less confused.
>
> And can you explain why your approach is "better" to do the change in
> memcontrol.c than in sock.h (see sock.c).
>
> Thanks in advance.
>
> - Sedat -
>
>> =======================
>>
>> [PATCH] memcg: fix build error if CONFIG_MEMCG_KMEM=n
>>
>> Fix this build error:
>>
>> mm/built-in.o: In function `mem_cgroup_css_free':
>> memcontrol.c:(.text+0x5caa6): undefined reference to
>> 'mem_cgroup_sockets_destroy'
>>
>> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
>> Signed-off-by: Li Zefan <lizefan@huawei.com>
>> ---
>>  mm/memcontrol.c | 12 ++++++++++--
>>  1 file changed, 10 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 234f311..59ea6f9 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -5876,6 +5876,11 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>>         return mem_cgroup_sockets_init(memcg, ss);
>>  }
>>
>> +static void memcg_destroy_kmem(struct mem_cgroup *memcg)
>> +{
>> +       mem_cgroup_sockets_destroy(memcg);
>> +}
>> +
>>  static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
>>  {
>>         if (!memcg_kmem_is_active(memcg))
>> @@ -5915,6 +5920,10 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>>         return 0;
>>  }
>>
>> +static void memcg_destroy_kmem(struct mem_cgroup *memcg)
>> +{
>> +}
>> +
>>  static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
>>  {
>>  }
>> @@ -6312,8 +6321,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
>>  {
>>         struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>>
>> -       mem_cgroup_sockets_destroy(memcg);
>> -
>> +       memcg_destroy_kmem(memcg);
>>         __mem_cgroup_free(memcg);
>>  }
>>
>> --
>> 1.8.0.2
>>
>>
>>> ---
>>> [ v2: git dislikes lines beginning with hash ('#'). ]
>>>
>>>  include/net/sock.h | 4 +++-
>>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/net/sock.h b/include/net/sock.h
>>> index ea6206c..ad4bf7f 100644
>>> --- a/include/net/sock.h
>>> +++ b/include/net/sock.h
>>> @@ -71,6 +71,7 @@
>>>  struct cgroup;
>>>  struct cgroup_subsys;
>>>  #ifdef CONFIG_NET
>>> +#ifdef CONFIG_MEMCG_KMEM
>>
>> #if defined(CONFIG_NET) && defined(CONFIG_MEMCG_KMEM)
>>
>>>  int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
>>>  void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg);
>>>  #else
>>> @@ -83,7 +84,8 @@ static inline
>>>  void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg)
>>>  {
>>>  }
>>> -#endif
>>> +#endif /* CONFIG_NET */
>>> +#endif /* CONFIG_MEMCG_KMEM */
>>>  /*
>>>   * This structure really needs to be cleaned up.
>>>   * Most of it is for TCP, and not used by any of
>>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
