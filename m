Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BBDFC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:29:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49C43216C8
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:29:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="MJZge7m/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49C43216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E81486B0008; Thu,  8 Aug 2019 17:29:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0A806B000A; Thu,  8 Aug 2019 17:29:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD31D6B000C; Thu,  8 Aug 2019 17:29:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 985DD6B0008
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 17:29:39 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so51531156pgv.0
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 14:29:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=PhGH3Fz3U6BG9IYzpAywsfQn2QaZDVfO/PlIuALj3rM=;
        b=tgvdoa0Q1iX5Hopb3aQq9zH33eBUpEWdYfMpFxldFSX+gb42Ra0AShHM1cEewCDD/P
         H4eN0C9QK+uynrt4jbRY3u6C6w68DF98vPX0xjrQ4bUtRZb4PmP2NceVVTN7xvXisKnE
         9xVNPQaDqYgLIiedoLw/XTIGVK4m+9hrjoLQb4clIOVgmnZYer7bSEFEQzzo0EIcD9rE
         QbVKt1G2XPfJSH0PIwp3U3IDq7Kkl8ZWpoOTYlIXBhUKT8xIfWb0pqa6aEFjPntUYFar
         hRKVdJe5SDzgsNzeK+LajZfbLigK1aOtb6PrCw0lzOyXQz1db4+DjZ7spU9mOvHPoHYY
         eCcA==
X-Gm-Message-State: APjAAAVIyL//3i7EgSDrNrpTkvzCaFTsgXUDMzLp01YllfQgqMQs8pOs
	jK+ypssb/UWfcWZfkZPcb19aadYB+m07pLWxeVo7YUZbF8aASu57PwhUlr1/wLU8YpGtcIvX1Z3
	LGr/ScGJWCg0vOWH9uTaslSvRCppbbm9OfN2ZvvhvPceXDjrJ/5N4bpBvFBY7yEZAKQ==
X-Received: by 2002:a63:124a:: with SMTP id 10mr14531264pgs.254.1565299779164;
        Thu, 08 Aug 2019 14:29:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykpRd6quTT705ZinvWZzWGbFQL20rUGwuS6Y0Jmh4dqBaAapas2hiZWaxqwGVLQO+AqjbY
X-Received: by 2002:a63:124a:: with SMTP id 10mr14531227pgs.254.1565299778212;
        Thu, 08 Aug 2019 14:29:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565299778; cv=none;
        d=google.com; s=arc-20160816;
        b=wfT8Ou3JpS9lqf947+5bldcRv34eAazBCmzviJ4zOxk5EOuGdB5WbsW6RPtF3fm+A7
         sozMxildqebRNcbYobsvJNHcaJc/52sjXmB8rSEYT44SCiUYqlXBcm0tBXRtiBYEQBEp
         KvxnoKViBkMhmNsZusU5Ss0m4SrkcR+WkBrAwvqHzwyGpSQoWVmIQGE67xp8YoGDryo4
         0p5lqoDPCOCkC/4qvBdjMnH+69wevflVImtQ7RysCE5EJEAiIo+f98ZG7l+3EcLvywGl
         hnm4C1DamDlfRYA8W4XfGUbfkhmJzvo1I+TOLUmc+fhZINYpzL0wKmdkcEzVheWUVH3m
         tBeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=PhGH3Fz3U6BG9IYzpAywsfQn2QaZDVfO/PlIuALj3rM=;
        b=aur02uD0MLeE9fJT+FhZBPC1/42w2e7b515yiLPbJFZecFdAGct88xZb7zJimgwCVY
         DadoagYqwnqqi+Sn2Quu1JxEdMVwB4ZUtdJ6l705cEnOV5AoDmccHfQevCosrt8O58S2
         OSW6hIQWl49YdnR10tVD6HgYzX+cPjmMLCsHqczd8I0clDUkUculTr2t4HwvUhbjDR8m
         Aw7y+FvWaXmPivO7XniXkpz2itShwQUXRCDjr/jpcECWsLY+qNOEyd8E5LIYJ7Gkm1Je
         jmaJRuegBGIXq+ahPUFttjMI1UTGtfzQaoHh4aiXXpmdX9dqT7pXelufZhmTUYzAi09m
         /2WA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="MJZge7m/";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id cb11si52657877plb.100.2019.08.08.14.29.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 14:29:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="MJZge7m/";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4c944b0002>; Thu, 08 Aug 2019 14:29:47 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 08 Aug 2019 14:29:37 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 08 Aug 2019 14:29:37 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 8 Aug
 2019 21:29:35 +0000
Subject: Re: [PATCH] nouveau/hmm: map pages after migration
To: Christoph Hellwig <hch@lst.de>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<amd-gfx@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<nouveau@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>
References: <20190807150214.3629-1-rcampbell@nvidia.com>
 <20190808070701.GC29382@lst.de>
From: Ralph Campbell <rcampbell@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <0b96a8d8-86b5-3ce0-db95-669963c1f8a7@nvidia.com>
Date: Thu, 8 Aug 2019 14:29:34 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190808070701.GC29382@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565299787; bh=PhGH3Fz3U6BG9IYzpAywsfQn2QaZDVfO/PlIuALj3rM=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=MJZge7m/9mkhZU4etBnQu2xchsH9bJVmIBhjlhBUSEeMEVfNkuCDij6bxrmYac4g9
	 9l00U+eic6gmLzXQPVqAn8j019mz/QqxOeYW/JKoLsBdEaVKz9RLkiSkpT8P2/nyQY
	 dJY3ZCzRLOOHHVCKzT1PdhiSUdG6plqyGdTnWLRTmmvPZ9RbteRLOLtOtrEFZ9RIKB
	 GzTGB8MM7HtJk/XeAG4akQYZ8yLwq74YHxldhk5dOYfCxGuneF/GePqweBWsMaiObR
	 Tzk5KikVIGjzbxE8Sq3t0NvbeP7bOgXH/SLMeMxad6ZhJxTHatunatImUt79RWsrWT
	 66U0nG6r9iVXA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/8/19 12:07 AM, Christoph Hellwig wrote:
> On Wed, Aug 07, 2019 at 08:02:14AM -0700, Ralph Campbell wrote:
>> When memory is migrated to the GPU it is likely to be accessed by GPU
>> code soon afterwards. Instead of waiting for a GPU fault, map the
>> migrated memory into the GPU page tables with the same access permission=
s
>> as the source CPU page table entries. This preserves copy on write
>> semantics.
>>
>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>> Cc: Christoph Hellwig <hch@lst.de>
>> Cc: Jason Gunthorpe <jgg@mellanox.com>
>> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
>> Cc: Ben Skeggs <bskeggs@redhat.com>
>> ---
>>
>> This patch is based on top of Christoph Hellwig's 9 patch series
>> https://lore.kernel.org/linux-mm/20190729234611.GC7171@redhat.com/T/#u
>> "turn the hmm migrate_vma upside down" but without patch 9
>> "mm: remove the unused MIGRATE_PFN_WRITE" and adds a use for the flag.
>=20
> This looks useful.  I've already dropped that patch for the pending
> resend.

Thanks.

>=20
>>   static unsigned long nouveau_dmem_migrate_copy_one(struct nouveau_drm =
*drm,
>> -		struct vm_area_struct *vma, unsigned long addr,
>> -		unsigned long src, dma_addr_t *dma_addr)
>> +		struct vm_area_struct *vma, unsigned long src,
>> +		dma_addr_t *dma_addr, u64 *pfn)
>=20
> I'll pick up the removal of the not needed addr argument for the patch
> introducing nouveau_dmem_migrate_copy_one, thanks,
>=20
>>   static void nouveau_dmem_migrate_chunk(struct migrate_vma *args,
>> -		struct nouveau_drm *drm, dma_addr_t *dma_addrs)
>> +		struct nouveau_drm *drm, dma_addr_t *dma_addrs, u64 *pfns)
>>   {
>>   	struct nouveau_fence *fence;
>>   	unsigned long addr =3D args->start, nr_dma =3D 0, i;
>>  =20
>>   	for (i =3D 0; addr < args->end; i++) {
>>   		args->dst[i] =3D nouveau_dmem_migrate_copy_one(drm, args->vma,
>> -				addr, args->src[i], &dma_addrs[nr_dma]);
>> +				args->src[i], &dma_addrs[nr_dma], &pfns[i]);
>=20
> Nit: I find the &pfns[i] way to pass the argument a little weird to read.
> Why not "pfns + i"?

OK, will do in v2.
Should I convert to "dma_addrs + nr_dma" too?

>> +u64 *
>> +nouveau_pfns_alloc(unsigned long npages)
>> +{
>> +	struct nouveau_pfnmap_args *args;
>> +
>> +	args =3D kzalloc(sizeof(*args) + npages * sizeof(args->p.phys[0]),
>=20
> Can we use struct_size here?

Yes, good suggestion.

>=20
>> +	int ret;
>> +
>> +	if (!svm)
>> +		return;
>> +
>> +	mutex_lock(&svm->mutex);
>> +	svmm =3D nouveau_find_svmm(svm, mm);
>> +	if (!svmm) {
>> +		mutex_unlock(&svm->mutex);
>> +		return;
>> +	}
>> +	mutex_unlock(&svm->mutex);
>=20
> Given that nouveau_find_svmm doesn't take any kind of reference, what
> gurantees svmm doesn't go away after dropping the lock?

I asked Ben and Jerome about this too.
I'm still looking into it.

>=20
>> @@ -44,5 +49,19 @@ static inline int nouveau_svmm_bind(struct drm_device=
 *device, void *p,
>>   {
>>   	return -ENOSYS;
>>   }
>> +
>> +u64 *nouveau_pfns_alloc(unsigned long npages)
>> +{
>> +	return NULL;
>> +}
>> +
>> +void nouveau_pfns_free(u64 *pfns)
>> +{
>> +}
>> +
>> +void nouveau_pfns_map(struct nouveau_drm *drm, struct mm_struct *mm,
>> +		      unsigned long addr, u64 *pfns, unsigned long npages)
>> +{
>> +}
>>   #endif /* IS_ENABLED(CONFIG_DRM_NOUVEAU_SVM) */
>=20
> nouveau_dmem.c and nouveau_svm.c are both built conditional on
> CONFIG_DRM_NOUVEAU_SVM, so there is no need for stubs here.
>=20

Good point. I'll remove them in v2.

