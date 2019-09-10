Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46783C49ED6
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:26:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14F4C20872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:26:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14F4C20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 827D86B0006; Tue, 10 Sep 2019 06:26:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D8296B0007; Tue, 10 Sep 2019 06:26:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EF666B0008; Tue, 10 Sep 2019 06:26:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0141.hostedemail.com [216.40.44.141])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5C86B0006
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:26:18 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E1EC91260
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:26:17 +0000 (UTC)
X-FDA: 75918631194.18.box22_19d4c10280740
X-HE-Tag: box22_19d4c10280740
X-Filterd-Recvd-Size: 2802
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:26:17 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CF761AF59;
	Tue, 10 Sep 2019 10:26:15 +0000 (UTC)
Subject: Re: [PATCH v3 4/4] mm, slab_common: Make the loop for initializing
 KMALLOC_DMA start from 1
To: Pengfei Li <lpf.vector@gmail.com>, akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 guro@fb.com
References: <20190910012652.3723-1-lpf.vector@gmail.com>
 <20190910012652.3723-5-lpf.vector@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <23cb75f5-4a05-5901-2085-8aeabc78c100@suse.cz>
Date: Tue, 10 Sep 2019 12:26:14 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190910012652.3723-5-lpf.vector@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/10/19 3:26 AM, Pengfei Li wrote:
> KMALLOC_DMA will be initialized only if KMALLOC_NORMAL with
> the same index exists.
> 
> And kmalloc_caches[KMALLOC_NORMAL][0] is always NULL.
> 
> Therefore, the loop that initializes KMALLOC_DMA should start
> at 1 instead of 0, which will reduce 1 meaningless attempt.

IMHO the saving of one iteration isn't worth making the code more 
subtle. KMALLOC_SHIFT_LOW would be nice, but that would skip 1 + 2 which 
are special.

Since you're doing these cleanups, have you considered reordering 
kmalloc_info, size_index, kmalloc_index() etc so that sizes 96 and 192 
are ordered naturally between 64, 128 and 256? That should remove 
various special casing such as in create_kmalloc_caches(). I can't 
guarantee it will be possible without breaking e.g. constant folding 
optimizations etc., but seems to me it should be feasible. (There are 
definitely more places to change than those I listed.)

> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
> ---
>   mm/slab_common.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index af45b5278fdc..c81fc7dc2946 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1236,7 +1236,7 @@ void __init create_kmalloc_caches(slab_flags_t flags)
>   	slab_state = UP;
>   
>   #ifdef CONFIG_ZONE_DMA
> -	for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
> +	for (i = 1; i <= KMALLOC_SHIFT_HIGH; i++) {
>   		struct kmem_cache *s = kmalloc_caches[KMALLOC_NORMAL][i];
>   
>   		if (s) {
> 


