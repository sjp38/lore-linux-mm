Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 852986B0268
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:06:16 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so5756568wms.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:06:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p26si7639289wrp.311.2017.01.12.08.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 08:06:15 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CG42ag119163
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:06:14 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 27xb1cwjyk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:06:13 -0500
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 12 Jan 2017 09:06:13 -0700
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Thu, 12 Jan 2017 17:05:58 +0100
MIME-Version: 1.0
In-Reply-To: <20170112153717.28943-6-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1a293278-63ab-c54d-0872-0bed42e9710e@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org

On 01/12/2017 04:37 PM, Michal Hocko wrote:
> diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
> index 4f74511015b8..e6bbb33d2956 100644
> --- a/arch/s390/kvm/kvm-s390.c
> +++ b/arch/s390/kvm/kvm-s390.c
> @@ -1126,10 +1126,7 @@ static long kvm_s390_get_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
>  	if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
>  		return -EINVAL;
> 
> -	keys = kmalloc_array(args->count, sizeof(uint8_t),
> -			     GFP_KERNEL | __GFP_NOWARN);
> -	if (!keys)
> -		keys = vmalloc(sizeof(uint8_t) * args->count);
> +	keys = kvmalloc(args->count * sizeof(uint8_t), GFP_KERNEL);
>  	if (!keys)
>  		return -ENOMEM;
> 
> @@ -1171,10 +1168,7 @@ static long kvm_s390_set_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
>  	if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
>  		return -EINVAL;
> 
> -	keys = kmalloc_array(args->count, sizeof(uint8_t),
> -			     GFP_KERNEL | __GFP_NOWARN);
> -	if (!keys)
> -		keys = vmalloc(sizeof(uint8_t) * args->count);
> +	keys = kvmalloc(sizeof(uint8_t) * args->count, GFP_KERNEL);
>  	if (!keys)
>  		return -ENOMEM;

KVM/s390 parts

Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
