Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id F085F6B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 09:09:58 -0500 (EST)
Message-ID: <4F44F6C6.8060302@parallels.com>
Date: Wed, 22 Feb 2012 18:08:06 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] per-cgroup slab caches
References: <1329824079-14449-1-git-send-email-glommer@parallels.com> <1329824079-14449-4-git-send-email-glommer@parallels.com> <CABCjUKAmjGS1j6kNgj8it_QZSPKJiCmgpme6BTxAGkoJ=DSR7w@mail.gmail.com>
In-Reply-To: <CABCjUKAmjGS1j6kNgj8it_QZSPKJiCmgpme6BTxAGkoJ=DSR7w@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, Paul
 Turner <pjt@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Pekka
 Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On 02/22/2012 03:50 AM, Suleiman Souhlal wrote:
> On Tue, Feb 21, 2012 at 3:34 AM, Glauber Costa<glommer@parallels.com>  wrote:
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 26fda11..2aa35b0 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> +struct kmem_cache *
>> +kmem_cache_dup(struct mem_cgroup *memcg, struct kmem_cache *base)
>> +{
>> +       struct kmem_cache *s;
>> +       unsigned long pages;
>> +       struct res_counter *fail;
>> +       /*
>> +        * TODO: We should use an ida-like index here, instead
>> +        * of the kernel address
>> +        */
>> +       char *kname = kasprintf(GFP_KERNEL, "%s-%p", base->name, memcg);
>
> Would it make more sense to use the memcg name instead of the pointer?

Well, yes. But at this point in creation time, we still don't have this 
all setup. The css pointer is NULL, so I could not derive the name from 
it. Instead of keep fighting what seemed to be a minor issue, I opted to 
kick the patches out and be clear with a comment that this is not what I 
intend in the way.

Do you know about any good way to grab the cgroup name at create() time ?

>> +
>> +       WARN_ON(mem_cgroup_is_root(memcg));
>> +
>> +       if (!kname)
>> +               return NULL;
>> +
>> +       s = kmem_cache_create_cg(memcg, kname, base->size,
>> +                                base->align, base->flags, base->ctor);
>> +       if (WARN_ON(!s))
>> +               goto out;
>> +
>> +
>> +       pages = slab_nr_pages(s);
>> +
>> +       if (res_counter_charge(memcg_kmem(memcg), pages<<  PAGE_SHIFT,&fail)) {
>> +               kmem_cache_destroy(s);
>> +               s = NULL;
>> +       }
>
> What are we charging here? Does it ever get uncharged?

We're charging the slab initial pages, that comes from allocations 
outside allocate_slab(). But in this sense, it is not very different 
than tin foil hats to protect against mind reading. Probably works, but 
I am not sure the threat is real (also remembering we can probably want 
to port it to the original slab allocator later - and let me be honest - 
I know 0 about how that works).

So if the slab starts with 0 pages, this is a nop. If in any case it 
does not, it gets uncharged when the cgroup is destroyed.

In all my tests, this played no role. If we can be sure that this won't 
be an issue, I'll be happy to remove it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
