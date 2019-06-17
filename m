Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74908C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:57:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C3E6208C0
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:57:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jL9LSwuQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C3E6208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBF7D8E0003; Mon, 17 Jun 2019 12:57:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B70428E0001; Mon, 17 Jun 2019 12:57:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A85EB8E0003; Mon, 17 Jun 2019 12:57:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 43B238E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:57:42 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id b13so1250073lfa.3
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:57:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uehbFKL1DtxLa2nl9V1qPHUSvv6mkzLbDy3FtI6IAQk=;
        b=sklXiXrKa5Gd4Lq+y8dVYhZ0AaJCBgJJQCrn5fQscpJDc+2jXF79FiM2EffTlT5MRw
         FlZFrt2hrO9oLUDyROiLObhzHhR1BwEv9P5YiD2XIZVuAJtTvX5BdQTMtEVbhq60Xpgz
         MVeE69fm76ZxEj2wxxmkFT9ZnCB8j7W1BYPAcXmrV/PqNS+ihiG2IUg8u1smxVoeGCdO
         f9VoAcHqIUS5QYLNlEQkVggoxYLn+55iEp1XHmWYTMWNi64RiHegAzp5sAppOWc3XNl+
         Sj1/Ud87IefBL6yzXW4qMtMf6rklmSI3LH0UrBlbXfHAMoCb3DUuUNxXrMV7VcmfczeQ
         oH0w==
X-Gm-Message-State: APjAAAWc4wroWvH7rgEfRHs4bDDACApRzUvPp6/GPTDZREjNBUhvVEvr
	6lQf3ZjwqpP6pJJbZAZ7fSfmUCBl71uNPsEEY+/QPV4n2ldN1r63OlSin72uz4FEcdp2Ia+rbko
	c/qU4VLoxJ1iA54nd2HgevsG+4vLQA/1L9E0HwfM7TjoumKJdMFpAQ04im9pzmKHMIA==
X-Received: by 2002:ac2:446b:: with SMTP id y11mr50855879lfl.158.1560790661492;
        Mon, 17 Jun 2019 09:57:41 -0700 (PDT)
X-Received: by 2002:ac2:446b:: with SMTP id y11mr50855851lfl.158.1560790660511;
        Mon, 17 Jun 2019 09:57:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560790660; cv=none;
        d=google.com; s=arc-20160816;
        b=01VzJ9Kt5WZyGNTMs3sbDjjbCQhUY8e0vIUBYhRki+TwNXmz/1P+mPdtoEehGFD8nL
         fqdAkgI90EgO6sr45opET0+IzoeUDyRq3VZdiiGeeMCKT+x9UU5xXhu2hkDHU/Av0PDH
         fYRLWbRjgL13C3+oSYO5smaPh5WlwqCVvrR8CLgnD5x0x1i4PB3rgBvpag1TjrUrwS6y
         FVbdXsnObjenWV5fxGeOsyGGfHZroNOTeXOzn74mvMHRA31BvHpFnT0qtPhpvSoFt1eK
         NRD4k/BC8x6PEYlAQNfEeDM9Moy80aSDiqsmF7n4WLQ+EWLuEBmYNk8u6qqs44tI/ZWl
         r5Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=uehbFKL1DtxLa2nl9V1qPHUSvv6mkzLbDy3FtI6IAQk=;
        b=Ie5oWKHsLxz3BpQmLPSqfY0ZNQet93JbOAGCVE1skQ37y3fqQTxL6kbWEySql+uOhh
         Q10AfK9hP9CR3Jmub/Ne23srS0FhGQoCT8/dwp+/LoLOR6HyU8aA+KpphMZfLU0l483g
         xA+X9ScodV/b0mX79Z945TlNcuTWmBod20GkfU+NJ7tN0wkogbj6MhVGlJTjo3WP/yUh
         zo2AMI11jUgcQ8PV+kg68NoFI/5DCQC5oAfYzy3n/Qqcjp5Top6BnznqT83+gOqOLyLa
         /SMchPzr3LLVk++VmPOX//qStYtsGtaGbJLtwxqM+g9J67c7N0PN4RQ9d7smn65gVpsw
         +oIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jL9LSwuQ;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5sor6373427lja.9.2019.06.17.09.57.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 09:57:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jL9LSwuQ;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=uehbFKL1DtxLa2nl9V1qPHUSvv6mkzLbDy3FtI6IAQk=;
        b=jL9LSwuQohV/9tClkUG/oVuCZeBdjbOcw9xBRe7rtSGIyTK1YLcmWUGHHaEi0SnFge
         rLkIFXy9a/v/FmfE++BaNmF4MHGSM6fWraE9+1nKcHvkCZReSDbgYf2++8EPwWNe88iM
         R22gUiDyD4G2kg/HAbU8M0Oze0b9cyc0OqBW+Tkk4rIBalMKMzq3c4dvGzi5po380p0k
         XsHmDlkTWsprGF33/pJfmJz3nHgGz2O+ffcYCQC59iU+naMow6ilS2zfzXKmN6MPvZ/O
         gMtRDlV4khPGvBFo3z9wTpo++6PNgweNGKaJdJeW6rb6KdhfUlkPuoj+L15TqOt2m33Y
         Yg/g==
X-Google-Smtp-Source: APXvYqzCYOdHUep/HW+G0w6/ul8i8d2lhkvJI1Kcg4OxRndsyB3MsJw8IyJbty+JD+R7H1fCHCtOiQ==
X-Received: by 2002:a2e:5d92:: with SMTP id v18mr52653870lje.9.1560790660091;
        Mon, 17 Jun 2019 09:57:40 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id v12sm2175804ljk.22.2019.06.17.09.57.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jun 2019 09:57:39 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 17 Jun 2019 18:57:30 +0200
To: Arnd Bergmann <arnd@arndb.de>
Cc: Uladzislau Rezki <urezki@gmail.com>, Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Roman Penyaev <rpenyaev@suse.de>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mike Rapoport <rppt@linux.ibm.com>, Linux-MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [BUG]: mm/vmalloc: uninitialized variable access in
 pcpu_get_vm_areas
Message-ID: <20190617165730.5l7z47n3vg73q7mp@pc636>
References: <20190617121427.77565-1-arnd@arndb.de>
 <20190617141244.5x22nrylw7hodafp@pc636>
 <CAK8P3a3sjuyeQBUprGFGCXUSDAJN_+c+2z=pCR5J05rByBVByQ@mail.gmail.com>
 <CAK8P3a0pnEnzfMkCi7Nb97-nG4vnAj7fOepfOaW0OtywP8TLpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a0pnEnzfMkCi7Nb97-nG4vnAj7fOepfOaW0OtywP8TLpw@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> I managed to un-confuse gcc-8 by turning the if/else if/else into
> a switch statement. If you all think this is an acceptable solution,
> I'll submit that after some more testing to ensure it addresses
> all configurations:
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index a9213fc3802d..5b7e50de008b 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -915,7 +915,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
>  {
>         struct vmap_area *lva;
> 
> -       if (type == FL_FIT_TYPE) {
> +       switch (type) {
> +       case FL_FIT_TYPE:
>                 /*
>                  * No need to split VA, it fully fits.
>                  *
> @@ -925,7 +926,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
>                  */
>                 unlink_va(va, &free_vmap_area_root);
>                 kmem_cache_free(vmap_area_cachep, va);
> -       } else if (type == LE_FIT_TYPE) {
> +               break;
> +       case LE_FIT_TYPE:
>                 /*
>                  * Split left edge of fit VA.
>                  *
> @@ -934,7 +936,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
>                  * |-------|-------|
>                  */
>                 va->va_start += size;
> -       } else if (type == RE_FIT_TYPE) {
> +               break;
> +       case RE_FIT_TYPE:
>                 /*
>                  * Split right edge of fit VA.
>                  *
> @@ -943,7 +946,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
>                  * |-------|-------|
>                  */
>                 va->va_end = nva_start_addr;
> -       } else if (type == NE_FIT_TYPE) {
> +               break;
> +       case NE_FIT_TYPE:
>                 /*
>                  * Split no edge of fit VA.
>                  *
> @@ -980,7 +984,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
>                  * Shrink this VA to remaining size.
>                  */
>                 va->va_start = nva_start_addr + size;
> -       } else {
> +               break;
> +       default:
>                 return -1;
>         }
> 
To me it is not clear how it would solve the warning. It sounds like
your GCC after this change is able to keep track of that variable
probably because of less generated code. But i am not sure about
other versions. For example i have:

gcc version 6.3.0 20170516 (Debian 6.3.0-18+deb9u1)

and it totally OK, i.e. it does not emit any related warning.

Another thing is that, if we add mode code there or change the function
prototype, we might run into the same warning. Therefore i proposed that
we just set the variable to NULL, i.e. Initialize it.

<snip>
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b1bb5fc6eb05..10cfb93aba1e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -913,7 +913,11 @@ adjust_va_to_fit_type(struct vmap_area *va,
        unsigned long nva_start_addr, unsigned long size,
        enum fit_type type)
 {
-       struct vmap_area *lva;
+       /*
+        * Some GCC versions can emit bogus warning that it
+        * may be used uninitialized, therefore set it NULL.
+        */
+       struct vmap_area *lva = NULL;
 
        if (type == FL_FIT_TYPE) {
                /*
<snip>

--
Vlad Rezki

