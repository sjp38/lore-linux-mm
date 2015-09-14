Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0164F6B025C
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:27:38 -0400 (EDT)
Received: by lahg1 with SMTP id g1so56863629lah.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:27:37 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id or2si9722370lbb.38.2015.09.14.06.27.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 06:27:36 -0700 (PDT)
Date: Mon, 14 Sep 2015 16:27:16 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH  1/2] mm: Replace nr_node_ids for loop with for_each_node
 in list lru
Message-ID: <20150914132716.GJ30743@esperanza>
References: <1441737107-23103-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <1441737107-23103-2-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <20150914090010.GB30743@esperanza>
 <55F6B1F3.1010702@linux.vnet.ibm.com>
 <20150914120455.GD30743@esperanza>
 <55F6C637.6080807@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <55F6C637.6080807@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org, nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, zhong@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 14, 2015 at 06:35:59PM +0530, Raghavendra K T wrote:
> On 09/14/2015 05:34 PM, Vladimir Davydov wrote:
> >On Mon, Sep 14, 2015 at 05:09:31PM +0530, Raghavendra K T wrote:
> >>On 09/14/2015 02:30 PM, Vladimir Davydov wrote:
> >>>On Wed, Sep 09, 2015 at 12:01:46AM +0530, Raghavendra K T wrote:
> >>>>The functions used in the patch are in slowpath, which gets called
> >>>>whenever alloc_super is called during mounts.
> >>>>
> >>>>Though this should not make difference for the architectures with
> >>>>sequential numa node ids, for the powerpc which can potentially have
> >>>>sparse node ids (for e.g., 4 node system having numa ids, 0,1,16,17
> >>>>is common), this patch saves some unnecessary allocations for
> >>>>non existing numa nodes.
> >>>>
> >>>>Even without that saving, perhaps patch makes code more readable.
> >>>
> >>>Do I understand correctly that node 0 must always be in
> >>>node_possible_map? I ask, because we currently test
> >>>lru->node[0].memcg_lrus to determine if the list is memcg aware.
> >>>
> >>
> >>Yes, node 0 is always there. So it should not be a problem.
> >
> >I think it should be mentioned in the comment to list_lru_memcg_aware
> >then.
> >
> 
> Something like this: ?

Yeah, looks good to me.

Thanks,
Vladimir

> static inline bool list_lru_memcg_aware(struct list_lru *lru)
> {
>         /*
>          * This needs node 0 to be always present, even
>          * in the systems supporting sparse numa ids.
>          */
>         return !!lru->node[0].memcg_lrus;
> }
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
