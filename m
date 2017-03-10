Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id F025A28093C
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 17:08:57 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id n62so31595164lfn.7
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 14:08:57 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id x8si5582651ljd.162.2017.03.10.14.08.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 14:08:56 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id v2so7795262lfi.2
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 14:08:56 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: z3fold: suspicious return with spinlock held
From: vitalywool@gmail.com
In-Reply-To: <82e268d4-22fa-3e33-8988-a3a367fae7b1@ispras.ru>
Date: Fri, 10 Mar 2017 23:08:53 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <2E74B250-1EE0-483A-ACA0-143C4F1ECD44@gmail.com>
References: <1489180932-13918-1-git-send-email-khoroshilov@ispras.ru> <20170310213419.GD16328@bombadil.infradead.org> <82e268d4-22fa-3e33-8988-a3a367fae7b1@ispras.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org

Hi Alexey,

> 10 mars 2017 kl. 22:54 skrev Alexey Khoroshilov <khoroshilov@ispras.ru>:
>=20
>> On 11.03.2017 00:34, Matthew Wilcox wrote:
>>> On Sat, Mar 11, 2017 at 12:22:12AM +0300, Alexey Khoroshilov wrote:
>>> Hello!
>>>=20
>>> z3fold_reclaim_page() contains the only return that may
>>> leave the function with pool->lock spinlock held.
>>>=20
>>> 669    spin_lock(&pool->lock);
>>> 670    if (kref_put(&zhdr->refcount, release_z3fold_page)) {
>>> 671        atomic64_dec(&pool->pages_nr);
>>> 672        return 0;
>>> 673    }
>>>=20
>>> May be we need spin_unlock(&pool->lock); just before return?
Looks so, thanks for the pointer. I'm currently commuting but will check it t=
horoughly tomorrow for sure.

~vitaly=20

>>=20
>> I would tend to agree.  sparse warns about this, and also about two
>> other locking problems ... which I'm not sure are really problems so
>> much as missing annotations?
>>=20
>> mm/z3fold.c:467:35: warning: context imbalance in 'z3fold_alloc' - unexpe=
cted unlock
>> mm/z3fold.c:519:26: warning: context imbalance in 'z3fold_free' - differe=
nt lock contexts for basic block
>> mm/z3fold.c:581:12: warning: context imbalance in 'z3fold_reclaim_page' -=
 different lock contexts for basic block
>>=20
>=20
> I also do not see problems in z3fold_alloc() and z3fold_free().
> But I am unaware of sparse annotations that can help here.
>=20
> --
> Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
