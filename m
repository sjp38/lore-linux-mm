Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0762FC5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 14:13:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C270420CC7
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 14:13:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="SzjNBnUd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C270420CC7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DB1C6B0005; Wed, 11 Sep 2019 10:13:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58CAB6B0006; Wed, 11 Sep 2019 10:13:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A2F26B0007; Wed, 11 Sep 2019 10:13:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0192.hostedemail.com [216.40.44.192])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5C76B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:13:38 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D3380180AD801
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 14:13:37 +0000 (UTC)
X-FDA: 75922832874.15.fold16_1f9df66edaf4e
X-HE-Tag: fold16_1f9df66edaf4e
X-Filterd-Recvd-Size: 3066
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 14:13:37 +0000 (UTC)
Received: from X1 (110.8.30.213.rev.vodafone.pt [213.30.8.110])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E09E120863;
	Wed, 11 Sep 2019 14:13:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1568211215;
	bh=q4Y7ST0eO607+g6D3aQth/Q9xrqwcsEEj2BO2x3fO1o=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=SzjNBnUdKKtkJJFXvj8EgFhIuIo+x5nsHdoFPTeBunWHAFnn33rDFDfZa1ZCsgwVc
	 VR+SWEBn5qcANGb827BXDvKsaC1mn6fPaAxkc8i7HgT+pevwoU8tfNEbEiooo12dYR
	 KyS32lBQGy/SXcZwJmFG9lywOs+WxyJFq/65dM+E=
Date: Wed, 11 Sep 2019 07:13:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: avoid slub allocation while holding list_lock
Message-Id: <20190911071331.770ecddff6a085330bf2b5f2@linux-foundation.org>
In-Reply-To: <20190909061016.173927-1-yuzhao@google.com>
References: <20190909061016.173927-1-yuzhao@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon,  9 Sep 2019 00:10:16 -0600 Yu Zhao <yuzhao@google.com> wrote:

> If we are already under list_lock, don't call kmalloc(). Otherwise we
> will run into deadlock because kmalloc() also tries to grab the same
> lock.
> 
> Instead, allocate pages directly. Given currently page->objects has
> 15 bits, we only need 1 page. We may waste some memory but we only do
> so when slub debug is on.
> 
>   WARNING: possible recursive locking detected
>   --------------------------------------------
>   mount-encrypted/4921 is trying to acquire lock:
>   (&(&n->list_lock)->rlock){-.-.}, at: ___slab_alloc+0x104/0x437
> 
>   but task is already holding lock:
>   (&(&n->list_lock)->rlock){-.-.}, at: __kmem_cache_shutdown+0x81/0x3cb
> 
>   other info that might help us debug this:
>    Possible unsafe locking scenario:
> 
>          CPU0
>          ----
>     lock(&(&n->list_lock)->rlock);
>     lock(&(&n->list_lock)->rlock);
> 
>    *** DEADLOCK ***
> 

It would be better if a silly low-level debug function like this
weren't to try to allocate memory at all.  Did you consider simply
using a statically allocated buffer?

{
	static char buffer[something large enough];
	static spinlock_t lock_to_protect_it;


Alternatively, do we need to call get_map() at all in there?  We could
simply open-code the get_map() functionality inside
list_slab_objects().  It would be slower, but printk is already slow. 
Potentially extremely slow.

