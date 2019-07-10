Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13C45C74A21
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 15:02:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D007B2084B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 15:02:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QfWu2USi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D007B2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E8C08E007B; Wed, 10 Jul 2019 11:02:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6725A8E0032; Wed, 10 Jul 2019 11:02:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 560EF8E007B; Wed, 10 Jul 2019 11:02:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36EBB8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 11:02:01 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id e20so3112725ioe.12
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 08:02:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TmbEkkK+CqBlu5lf4ZqLqOZNHYRlqw/lrYYIdmqXv58=;
        b=TCoekLKwLIXaZa19KIODStLUejZ2fVxyedNNEibf6WwQnB2Q6M7CS39GhCiNPG9VT+
         BrV6yEQVd91/320W3galBNcRAR7Jnqg0km0lMoMZxQgJgmM7nqgsd5mtTe5EzMNIOWBp
         3t6mDpc9yubzQlgpIv6YPZ5wz4jNJPQiSE0x7x8RYNjfq2JnTkaylL+4dluraH4I2i5O
         fM92JniRXzAzDmUgpT8wtwkG3ADIPxig63dIlpAkYuvIE/KmFCSsVSEPhX7RdWxeRm3G
         02Q8yiK4lY6bkxDtb6tsCHOAGLwIM6Zp5B5a6Vc2QDR2GKa1yPhtBG0Q2YAgayOaLzdl
         SFVw==
X-Gm-Message-State: APjAAAWn1dGMV+DbMZuHw1pFNRGnpBLde6rf89M49ptDcL6vtf2RvBKQ
	MbDFQDZboXgbqYxvA2u9wDfxls79lyIotLJRBPBZJEivjkvHjEmYgYDypsWai90p5vcHeMJ0k1q
	Enu2bn9ddPYuBEzoAy4x1zBaOeROtAXRbshGWQ3n+NB17jBT3DwZx4rdGZ0BRwfSDSg==
X-Received: by 2002:a6b:4e1a:: with SMTP id c26mr7602013iob.178.1562770920924;
        Wed, 10 Jul 2019 08:02:00 -0700 (PDT)
X-Received: by 2002:a6b:4e1a:: with SMTP id c26mr7601852iob.178.1562770919011;
        Wed, 10 Jul 2019 08:01:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562770919; cv=none;
        d=google.com; s=arc-20160816;
        b=bpI4RAscjMbNG9NqLoCQL0dEl+rno7dEla72qKMQ0/z6nyu0qlsbFMIqHh1p+UcCG+
         m2z9/MGKQWS2fuDZSiO1YlsJclCsXGlN51Lvxf9c5i0Zvhe4qnq75yULXOnSeGQO5qEO
         YWFhM4oTi08JzCDeWFHcgQy06Vrn5JC3+F5r6x2y4SG4SkBZZJV7zDU7K4/HCWFQzhtj
         1vEP2RbEZhue30JANdLGq4FE2w8QLDikYybQPlsiFzDKR2aQB0D6a+8WCksZefwU5DCt
         yo4wOmzPBJPQpqJNE2UH1pKLMm1YDV0IyxIf1UGppO7kpX4w6O8DCbrmd/3aPCcYalXO
         Qydg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TmbEkkK+CqBlu5lf4ZqLqOZNHYRlqw/lrYYIdmqXv58=;
        b=SsGtFpLUU0J+7f6fGkOJYLBa6mGpW3ta9ToKWyXWOrTw29Iw3i5jndHGxxlOMxDRwf
         DaHeNRLqdPGWWpTQxqhPCXb+vvSrQKhp9w/MwAgh5CmK7dHFnivivb95BHJJjPbX+bP8
         kQoYcc3K8BZz+bNnKc0YbjzjEXOK6+XngXClm11vh9KKmeo4Kj4BUFNGZVpcuq5QNWcd
         LyJtEIBzfaEKIImI7TenPS4fuqUrZ/3FYLRUQsVpiT812L1A2jrlgv4s85sxTVTibzmJ
         qKUEI8T9mBsXUhIu8I77NfOgsrLWCEwRipzuC4btYi3w0Qs38fDh7G2iiW0MHczl8E5D
         AKAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QfWu2USi;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15sor2140385iol.1.2019.07.10.08.01.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 08:01:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QfWu2USi;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TmbEkkK+CqBlu5lf4ZqLqOZNHYRlqw/lrYYIdmqXv58=;
        b=QfWu2USizXC0KMquGV6dlMozA5qcpBgq1amcr3rHc7cEtoUQECUgVzRW8Qq8x1sDXe
         w0ikGjCOHuz/O1gaNu8oGvnGTgVYevxkyQuKMPJ6wO06+l/FynPjON7iYc/tspNmvNOz
         ky34RkznwLTqbpcGq3d9BLv9Np6FGkFlUznc2TARp/gYf7Zfxw36itbJvjah8YLymzOA
         EF2LyLae+WWb2jkBb3Wqumf9lmhH87+v8pGWgYZrugoUdo41g9R7+a/TIyDuPux9Lmsy
         vHWoTcI2YZENwCQLMVcIC2i9dd4OkwoeinTto4LivZFZYVXm4DxfI6hCKAh5QzPB8hx4
         4jhg==
X-Google-Smtp-Source: APXvYqzQ2BXQGKlhlJlFKcKu40msLPfp+OtgWnM+vycaJvB2v/zLtDVOzF2EixuDwdQhuDNs+g4WF4Ev2d9vagou+Lw=
X-Received: by 2002:a6b:5106:: with SMTP id f6mr4531622iob.15.1562770918520;
 Wed, 10 Jul 2019 08:01:58 -0700 (PDT)
MIME-Version: 1.0
References: <1562754389-29217-1-git-send-email-bsauce00@gmail.com>
In-Reply-To: <1562754389-29217-1-git-send-email-bsauce00@gmail.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 10 Jul 2019 08:01:47 -0700
Message-ID: <CAKgT0UcWy9kpwhkk9zPbdgj896GzqLV0P7dGMQAUAPr9rURApw@mail.gmail.com>
Subject: Re: [PATCH] fs/seq_file.c: Fix a UAF vulnerability in seq_release()
To: bsauce <bsauce00@gmail.com>
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Mel Gorman <mgorman@suse.de>, h <l.stach@pengutronix.de>, vdavydov.dev@gmail.com, 
	Andrew Morton <akpm@linux-foundation.org>, alex@ghiti.fr, adobriyan@gmail.com, 
	mike.kravetz@oracle.com, David Rientjes <rientjes@google.com>, rppt@linux.vnet.ibm.com, 
	Michal Hocko <mhocko@suse.com>, ksspiers@google.com, linux-mm <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2019 at 3:26 AM bsauce <bsauce00@gmail.com> wrote:
>
> In seq_release(), 'm->buf' points to a chunk. It is freed but not cleared to null right away. It can be reused by seq_read() or srm_env_proc_write().
> For example, /arch/alpha/kernel/srm_env.c provide several interfaces to userspace, like 'single_release', 'seq_read' and 'srm_env_proc_write'.
> Thus in userspace, one can exploit this UAF vulnerability to escape privilege.
> Even if 'm->buf' is cleared by kmem_cache_free(), one can still create several threads to exploit this vulnerability.
> And 'm->buf' should be cleared right after being freed.
>
> Signed-off-by: bsauce <bsauce00@gmail.com>

So I am pretty sure this "Signed-off-by" line is incorrect. Take a
look in Documentation/process/submitting-patches.rst for more
information. It specifically it calls out that you need to use your
real name, no pseudonyms.

> ---
>  fs/seq_file.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/fs/seq_file.c b/fs/seq_file.c
> index abe27ec..de5e266 100644
> --- a/fs/seq_file.c
> +++ b/fs/seq_file.c
> @@ -358,6 +358,7 @@ int seq_release(struct inode *inode, struct file *file)
>  {
>         struct seq_file *m = file->private_data;
>         kvfree(m->buf);
> +       m->buf = NULL;
>         kmem_cache_free(seq_file_cache, m);
>         return 0;
>  }

As has already been pointed out we are calling kmem_cache_free on m in
the very next line. As such setting m->buf to NULL would have no
effect as m will be freed and could be reused/overwritten at that
point.

