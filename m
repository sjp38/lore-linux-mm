Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C52BECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 14:34:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30B89207FC
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 14:34:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gDzKMYbk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30B89207FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFCC06B0005; Wed, 11 Sep 2019 10:34:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AACB06B0006; Wed, 11 Sep 2019 10:34:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 974216B0007; Wed, 11 Sep 2019 10:34:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0058.hostedemail.com [216.40.44.58])
	by kanga.kvack.org (Postfix) with ESMTP id 700306B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:34:00 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 03E8519B32
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 14:34:00 +0000 (UTC)
X-FDA: 75922884240.10.loss15_3ff51f2597856
X-HE-Tag: loss15_3ff51f2597856
X-Filterd-Recvd-Size: 4942
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 14:33:59 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id g19so22717358otg.13
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:33:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=e7i1vpQoaz28lri8m0dOi8OheZbdU0yuzI5V0oHg1wI=;
        b=gDzKMYbkL2/UIIox7n9fF8nxWK0jM/5rkqz+fvqtwhYarL9SJ44xQDt/t33K9VIBEz
         jgma1b2JT6MCkvA0jq5vblNABt13d0t0hpoaNHGhp46fUzdNphFV7DuD9Irsfl5iZf5F
         N3iTDI+gdue+yMu/CcQS7GF3+BL+vSupn4EgCbSi3eDwA1NmuIkGDIaZuVFiiZmGHHug
         A/9VMetPrhM4Bt0fyJhBYs+lCgN3BySKPbFTvicbTfJNgb8UsyU06kLNd8iKBvxJjcJn
         FWdbzt+L12PE1Eybea/kLOR1QtScPArTMBAlAae8QsT7wa+GA4E9hYfy11OCPBdFZxTA
         T1gg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=e7i1vpQoaz28lri8m0dOi8OheZbdU0yuzI5V0oHg1wI=;
        b=qqkdkEPsmLw8iN9jfEtruusAw0OGIdctpRUrahyPmvr0dc8z4E9fnY7Q0CQLsKzNrC
         F+2XZwZHL8VC64Cmbpb/IrqxR/1hMdJAtEwAGZP/mjiBKolYl7ourALnJ8n92GKf5e5g
         t0+3aI1e0vIm8pPWvI8k07+lN0wrGeAX6O1WnOjlLZRqFDwcgbiorwLyG/MKoGwOFSS4
         Wpppb8N0jKq6kwEnOhKATqgDxDeMK+fPG25iMjMvlN5A1kut97Jis1iGAe532L3giVv3
         Ve+AkUfNu2J3I6phNCdGpIizokj9WM8D2MgwxrblTvN5KZ0Wq2YiuEBsPzxtEJTddORz
         pT8Q==
X-Gm-Message-State: APjAAAXMND44QF2Qr7W9eVG3xdDSSDKylDcuc+fk/YSrWp3KpYdbFlfG
	2de69ywp3G6T8QBRL8WvGV0E5Ik5//RbU1aTlB8=
X-Google-Smtp-Source: APXvYqx7hau3v+uUL+g+yMLToPsiUNB+5jnulxOrqfaNC3BhfhcsFq7YjuvJLUpWsz1nZ/u3gZ7F7QhT4t5YSD7DVws=
X-Received: by 2002:a9d:1ec:: with SMTP id e99mr25446946ote.173.1568212438718;
 Wed, 11 Sep 2019 07:33:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190910012652.3723-1-lpf.vector@gmail.com> <20190910012652.3723-5-lpf.vector@gmail.com>
 <23cb75f5-4a05-5901-2085-8aeabc78c100@suse.cz>
In-Reply-To: <23cb75f5-4a05-5901-2085-8aeabc78c100@suse.cz>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Wed, 11 Sep 2019 22:33:46 +0800
Message-ID: <CAD7_sbHZuy4VZJ1KrF6TXmihfxi91Fo0OJMjuET4dpk-F7g6jA@mail.gmail.com>
Subject: Re: [PATCH v3 4/4] mm, slab_common: Make the loop for initializing
 KMALLOC_DMA start from 1
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christopher Lameter <cl@linux.com>, penberg@kernel.org, 
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 6:26 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 9/10/19 3:26 AM, Pengfei Li wrote:
> > KMALLOC_DMA will be initialized only if KMALLOC_NORMAL with
> > the same index exists.
> >
> > And kmalloc_caches[KMALLOC_NORMAL][0] is always NULL.
> >
> > Therefore, the loop that initializes KMALLOC_DMA should start
> > at 1 instead of 0, which will reduce 1 meaningless attempt.
>
> IMHO the saving of one iteration isn't worth making the code more
> subtle. KMALLOC_SHIFT_LOW would be nice, but that would skip 1 + 2 which
> are special.
>

Yes, I agree with you.
This really makes the code more subtle.

> Since you're doing these cleanups, have you considered reordering
> kmalloc_info, size_index, kmalloc_index() etc so that sizes 96 and 192
> are ordered naturally between 64, 128 and 256? That should remove
> various special casing such as in create_kmalloc_caches(). I can't
> guarantee it will be possible without breaking e.g. constant folding
> optimizations etc., but seems to me it should be feasible. (There are
> definitely more places to change than those I listed.)
>

In the past two days, I am working on what you suggested.

So far, I have completed the coding work, but I need some time to make
sure there are no bugs and verify the impact on performance.

I will send v4 soon.

Thank you for your review and suggestions.

--
Pengfei

> > Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
> > ---
> >   mm/slab_common.c | 2 +-
> >   1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > index af45b5278fdc..c81fc7dc2946 100644
> > --- a/mm/slab_common.c
> > +++ b/mm/slab_common.c
> > @@ -1236,7 +1236,7 @@ void __init create_kmalloc_caches(slab_flags_t flags)
> >       slab_state = UP;
> >
> >   #ifdef CONFIG_ZONE_DMA
> > -     for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
> > +     for (i = 1; i <= KMALLOC_SHIFT_HIGH; i++) {
> >               struct kmem_cache *s = kmalloc_caches[KMALLOC_NORMAL][i];
> >
> >               if (s) {
> >
>

