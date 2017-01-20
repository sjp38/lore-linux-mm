Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE876B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 08:41:45 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id yr2so14967717wjc.4
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 05:41:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si3487090wma.140.2017.01.20.05.41.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 05:41:44 -0800 (PST)
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
 <CAGXu5jKhYP=5YNuntzmG64WL92F59VKhByOh9nqaGP7-LBEnng@mail.gmail.com>
 <20170112173745.GC31509@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7c109e9e-e28b-3ddb-42b6-902f46bf0572@suse.cz>
Date: Fri, 20 Jan 2017 14:41:37 +0100
MIME-Version: 1.0
In-Reply-To: <20170112173745.GC31509@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Network Development <netdev@vger.kernel.org>

On 01/12/2017 06:37 PM, Michal Hocko wrote:
> On Thu 12-01-17 09:26:09, Kees Cook wrote:
>> On Thu, Jan 12, 2017 at 7:37 AM, Michal Hocko <mhocko@kernel.org> wrote:
> [...]
>>> diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
>>> index 4f74511015b8..e6bbb33d2956 100644
>>> --- a/arch/s390/kvm/kvm-s390.c
>>> +++ b/arch/s390/kvm/kvm-s390.c
>>> @@ -1126,10 +1126,7 @@ static long kvm_s390_get_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
>>>         if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
>>>                 return -EINVAL;
>>>
>>> -       keys = kmalloc_array(args->count, sizeof(uint8_t),
>>> -                            GFP_KERNEL | __GFP_NOWARN);
>>> -       if (!keys)
>>> -               keys = vmalloc(sizeof(uint8_t) * args->count);
>>> +       keys = kvmalloc(args->count * sizeof(uint8_t), GFP_KERNEL);
>>
>> Before doing this conversion, can we add a kvmalloc_array() API? This
>> conversion could allow for the reintroduction of integer overflow
>> flaws. (This particular situation isn't at risk since ->count is
>> checked, but I'd prefer we not create a risky set of examples for
>> using kvmalloc.)
> 
> Well, I am not opposed to kvmalloc_array but I would argue that this
> conversion cannot introduce new overflow issues. The code would have
> to be broken already because even though kmalloc_array checks for the
> overflow but vmalloc fallback doesn't...

Yeah I agree, but if some of the places were really wrong, after the
conversion we won't see them anymore.

> If there is a general interest for this API I can add it.

I think it would be better, yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
