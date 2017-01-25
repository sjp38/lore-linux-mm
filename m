Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00B306B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 06:16:09 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d140so36758904wmd.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 03:16:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f66si21951970wmh.81.2017.01.25.03.16.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 03:16:07 -0800 (PST)
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
 <CAGXu5jKhYP=5YNuntzmG64WL92F59VKhByOh9nqaGP7-LBEnng@mail.gmail.com>
 <20170112173745.GC31509@dhcp22.suse.cz>
 <7c109e9e-e28b-3ddb-42b6-902f46bf0572@suse.cz>
 <20170124150004.GM6867@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a4b4e2f4-f730-4f1d-7f41-36ba0d34f1a6@suse.cz>
Date: Wed, 25 Jan 2017 12:15:59 +0100
MIME-Version: 1.0
In-Reply-To: <20170124150004.GM6867@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Network Development <netdev@vger.kernel.org>

On 01/24/2017 04:00 PM, Michal Hocko wrote:
>> > Well, I am not opposed to kvmalloc_array but I would argue that this
>> > conversion cannot introduce new overflow issues. The code would have
>> > to be broken already because even though kmalloc_array checks for the
>> > overflow but vmalloc fallback doesn't...
>>
>> Yeah I agree, but if some of the places were really wrong, after the
>> conversion we won't see them anymore.
>>
>> > If there is a general interest for this API I can add it.
>>
>> I think it would be better, yes.
>
> OK, fair enough. I will fold the following into the original patch. I
> was little bit reluctant to create kvcalloc so I've made the original
> callers more talkative and added | __GFP_ZERO.

Fair enough,

> To be honest I do not
> really like how kcalloc...

how kcalloc what?

[...]
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index cdc55d5ee4ad..eca16612b1ae 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -712,10 +712,7 @@ EXPORT_SYMBOL(xt_check_entry_offsets);
>   */
>  unsigned int *xt_alloc_entry_offsets(unsigned int size)
>  {
> -	if (size < (SIZE_MAX / sizeof(unsigned int)))
> -		return kvzalloc(size * sizeof(unsigned int), GFP_KERNEL);
> -
> -	return NULL;
> +	return kvmalloc_array(size * sizeof(unsigned int), GFP_KERNEL | __GFP_ZERO);

This one wouldn't compile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
