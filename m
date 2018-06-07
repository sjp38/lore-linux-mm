Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4911B6B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 13:29:53 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w74-v6so10565041qka.4
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 10:29:53 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id u15-v6si5159783qvi.15.2018.06.07.10.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 10:29:51 -0700 (PDT)
Subject: Re: [PATCH 6/6] Convert intel uncore to struct_size
References: <20180607145720.22590-1-willy@infradead.org>
 <20180607145720.22590-7-willy@infradead.org>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <03d9addb-9c68-c6e5-d7db-57468fc3950c@nvidia.com>
Date: Thu, 7 Jun 2018 10:29:49 -0700
MIME-Version: 1.0
In-Reply-To: <20180607145720.22590-7-willy@infradead.org>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 06/07/2018 07:57 AM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Need to do a bit of rearranging to make this work.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>   arch/x86/events/intel/uncore.c | 19 ++++++++++---------
>   1 file changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/x86/events/intel/uncore.c b/arch/x86/events/intel/uncore.c
> index 15b07379e72d..e15cfad4f89b 100644
> --- a/arch/x86/events/intel/uncore.c
> +++ b/arch/x86/events/intel/uncore.c
> @@ -865,8 +865,6 @@ static void uncore_types_exit(struct intel_uncore_type **types)
>   static int __init uncore_type_init(struct intel_uncore_type *type, bool setid)
>   {
>   	struct intel_uncore_pmu *pmus;
> -	struct attribute_group *attr_group;
> -	struct attribute **attrs;
>   	size_t size;
>   	int i, j;
>   
> @@ -891,21 +889,24 @@ static int __init uncore_type_init(struct intel_uncore_type *type, bool setid)
>   				0, type->num_counters, 0, 0);
>   
>   	if (type->event_descs) {
> +		struct {
> +			struct attribute_group group;
> +			struct attribute *attrs[];
> +		} *attr_group;
>   		for (i = 0; type->event_descs[i].attr.attr.name; i++);

What does this for loop do?
Looks like nothing given the semicolon at the end.

> -		attr_group = kzalloc(sizeof(struct attribute *) * (i + 1) +
> -					sizeof(*attr_group), GFP_KERNEL);
> +		attr_group = kzalloc(struct_size(attr_group, attrs, i + 1),
> +								GFP_KERNEL);
>   		if (!attr_group)
>   			goto err;
>   
> -		attrs = (struct attribute **)(attr_group + 1);
> -		attr_group->name = "events";
> -		attr_group->attrs = attrs;
> +		attr_group->group.name = "events";
> +		attr_group->group.attrs = attr_group->attrs;
>   
>   		for (j = 0; j < i; j++)
> -			attrs[j] = &type->event_descs[j].attr.attr;
> +			attr_group->attrs[j] = &type->event_descs[j].attr.attr;
>   
> -		type->events_group = attr_group;
> +		type->events_group = &attr_group->group;
>   	}
>   
>   	type->pmu_group = &uncore_pmu_attr_group;
> 
