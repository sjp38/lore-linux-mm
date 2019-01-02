Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81461C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 15:51:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36FC6218DE
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 15:51:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="E+ay9z6r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36FC6218DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C31308E0027; Wed,  2 Jan 2019 10:51:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE0148E0002; Wed,  2 Jan 2019 10:51:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD19D8E0027; Wed,  2 Jan 2019 10:51:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 833D58E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 10:51:13 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w19so39495958qto.13
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 07:51:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=rEkE6Caj2p88PSsCUc8oU/jhCd4SVEFpbmMGCBsImRk=;
        b=a6TDzzhZvgxumA1s9qg8s2lxfyabYp6snToGPCWkBdeI+GjvffaL4UndVpx4TO3z6s
         sDLfjHS7jBylA3C3VXw8faBLVzwuoIoxC+R/AyTKov2Nockc7kObU+ioDzoy6xqBfm7B
         bAfe5KR3mmjRRJCGYIUWfHsLr7twDF1dmJWi9EyZFJZ5KsyXTjkv6vmiuMe873M+acXa
         TsulARw/6TSJzgCJDdPjHmDc+uKGDZsq2earLuXjH8Yfp6fmEiJz4Vy+5emQTEKMh9+G
         p2EOnM9BRDBRQtzX9EK6fmsYSio/Kh7Yh5RFNevCwsvRSfWj62E/7fXXY0SartrioWit
         SUIQ==
X-Gm-Message-State: AJcUukf2eiuNtfhTismJL3/Z1AzljScNoT3gbHbv8wKVqJwI0mIfyU3U
	zzAyeJW+59MLJlshF6sAl2a2QDc2iovuQbl05THZeyo3r1Bbum3K8PX7YE1HRgDhKaxKZrP6i43
	D9sCLwPYlsci4fN6g9ZZq6cpPI0ioVMJLf2FCavHFA4e4YpAuSIWCA22yTx/CpsY=
X-Received: by 2002:a0c:cc8c:: with SMTP id f12mr43502430qvl.102.1546444273255;
        Wed, 02 Jan 2019 07:51:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6KcU/ZdhoZMAonm0TVGKpzMcxT+ABrd5bM4QZcQKQADGKFoaTya1odR+60n0oObAhp5MLa
X-Received: by 2002:a0c:cc8c:: with SMTP id f12mr43502400qvl.102.1546444272685;
        Wed, 02 Jan 2019 07:51:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546444272; cv=none;
        d=google.com; s=arc-20160816;
        b=QB+Sa2JR0qyM2mtDKJcX26oAgCRgxcfp48YNYVYF1hnUMewUlCbFls1WiqRj7lGgzL
         w4LkDMaEAoZu5JTp6GazbniryMYikAfDSWHdn/vEmxbfmbrfz/eC+jBm5XbToywOKAAV
         /NP+vRULf3SBwJfWoWSU1qthqAm497WyO8AZfVtlqs5dxtEo/xjT9LgYVzrnSii6PtZi
         xgCjbRpAjtCDI8SRAi/kwFoxFfY0AP5kvqvRbCT/5Omcpe7XAgADyy3fUvOwWJ590AFG
         U7j3ZveqigsK/f77DMcvLDA0QzxVg1zIi1BtVNX+TSwsaFYCOfmTnXQw86uHRSMa+cUF
         eXjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=rEkE6Caj2p88PSsCUc8oU/jhCd4SVEFpbmMGCBsImRk=;
        b=xDxu533f3AL7Sbcf+waX8VZH2/1Xr4mWyr4SPA3i1JBEgmo3HuTmMqgLKYe+SILqcZ
         v8qmb83U4n9SUByA1H+QiFvmI1lnbcB3YNkPj2DmjhYgpqV4lX36GYTnxPot1vLM5nVk
         ZfayvL+6cBFXLuXgVa69o7hBB6nFGmIfWLXwwBlVBylFgJSGlBDEiP6u/ssZngc8gdl1
         YpcbeUGCWs0Lz3t8HviXsoKpdRr0EKWEzi7CZc+pU9jUnApFy5DlnyGQHx21azvvVQzu
         R++yASBumFuPW+6vTQTlObbzdUp1rn1JhfBZ8gAmOR0mBRZkFk+V0ArCNv9i/re7DH0P
         pNjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=E+ay9z6r;
       spf=pass (google.com: domain of 010001680f42f192-82b4e12e-1565-4ee0-ae1f-1e98974906aa-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=010001680f42f192-82b4e12e-1565-4ee0-ae1f-1e98974906aa-000000@amazonses.com
Received: from a9-31.smtp-out.amazonses.com (a9-31.smtp-out.amazonses.com. [54.240.9.31])
        by mx.google.com with ESMTPS id a24si624776qvd.18.2019.01.02.07.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Jan 2019 07:51:12 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001680f42f192-82b4e12e-1565-4ee0-ae1f-1e98974906aa-000000@amazonses.com designates 54.240.9.31 as permitted sender) client-ip=54.240.9.31;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=E+ay9z6r;
       spf=pass (google.com: domain of 010001680f42f192-82b4e12e-1565-4ee0-ae1f-1e98974906aa-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=010001680f42f192-82b4e12e-1565-4ee0-ae1f-1e98974906aa-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1546444272;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=QrUfP2uIZHKXzgqGsLcs1smTdC8d+WI0qnJh55aBLBQ=;
	b=E+ay9z6r2ElMB3D6TaKMceeFTQChZVSdJ/tI015jziOWfgTHqD8pIvknKXq8bhCO
	OzAN+3av/7KCiiN5Ms+prXwen9ym67IxOnCFTJDogUhCVKdgPN6nSpFyCZSNbUWeVxF
	wQl+HZo6yvoqyQx5pu0jR4MFs4/N5YaPY/Rfulac=
Date: Wed, 2 Jan 2019 15:51:12 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Dmitry Vyukov <dvyukov@google.com>
cc: syzbot <syzbot+d6ed4ec679652b4fd4e4@syzkaller.appspotmail.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    David Miller <davem@davemloft.net>, Eric Van Hensbergen <ericvh@gmail.com>, 
    LKML <linux-kernel@vger.kernel.org>, Latchesar Ionkov <lucho@ionkov.net>, 
    netdev <netdev@vger.kernel.org>, 
    syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
    v9fs-developer@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 setup_kmem_cache_node
In-Reply-To: <CACT4Y+ZECp8Ymq=0QUNfwmfpQvWkBpoMgyUCuz0M=peehEeCHw@mail.gmail.com>
Message-ID:
 <010001680f42f192-82b4e12e-1565-4ee0-ae1f-1e98974906aa-000000@email.amazonses.com>
References: <0000000000000f35c6057e780d36@google.com> <CACT4Y+ZECp8Ymq=0QUNfwmfpQvWkBpoMgyUCuz0M=peehEeCHw@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-SES-Outgoing: 2019.01.02-54.240.9.31
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102155112.tTiD6jWYgIkFqQYfLUCV2SfvUIqHGxw7lJmT7HpusYM@z>

On Wed, 2 Jan 2019, Dmitry Vyukov wrote:

> Am I missing something or __alloc_alien_cache misses check for
> kmalloc_node result?
>
> static struct alien_cache *__alloc_alien_cache(int node, int entries,
>                                                 int batch, gfp_t gfp)
> {
>         size_t memsize = sizeof(void *) * entries + sizeof(struct alien_cache);
>         struct alien_cache *alc = NULL;
>
>         alc = kmalloc_node(memsize, gfp, node);
>         init_arraycache(&alc->ac, entries, batch);
>         spin_lock_init(&alc->lock);
>         return alc;
> }
>


True _alloc_alien_cache() needs to check for NULL


From: Christoph Lameter <cl@linux.com>
Subject: slab: Alien caches must not be initialized if the allocation of the alien cache failed

Callers of __alloc_alien() check for NULL.
We must do the same check in __alloc_alien_cache to avoid NULL pointer dereferences
on allocation failures.

Signed-off-by: Christoph Lameter <cl@linux.com>


Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c
+++ linux/mm/slab.c
@@ -666,8 +666,10 @@ static struct alien_cache *__alloc_alien
 	struct alien_cache *alc = NULL;

 	alc = kmalloc_node(memsize, gfp, node);
-	init_arraycache(&alc->ac, entries, batch);
-	spin_lock_init(&alc->lock);
+	if (alc) {
+		init_arraycache(&alc->ac, entries, batch);
+		spin_lock_init(&alc->lock);
+	}
 	return alc;
 }

