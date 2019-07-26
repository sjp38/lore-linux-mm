Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 031CDC76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:20:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA33922BEF
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:20:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kEGHfnb+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA33922BEF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 762C16B0005; Fri, 26 Jul 2019 19:20:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 713F18E0003; Fri, 26 Jul 2019 19:20:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DA5C8E0002; Fri, 26 Jul 2019 19:20:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 399046B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:20:23 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x10so48733285qti.11
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 16:20:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WuNOArHZs/CiCRyKyjlclGYC7Ncl5iJJmT+ESUl6jAA=;
        b=LjFzdjvy7n1bNmTS4I3cgE1uwcUvuRL/wvS/n+fAOqeK7x/Z5B+/62ocvwcXZhGb+y
         PfRNLApXHnonX3fOhEBdrtWAMMBh+xCiaVel5LuvxyMJEAU9lbrBl7HCjw+P3S/Rqvh+
         KZtBG2HFkZDBQk74ni42qS6y/axev6lPZjOQxo6YVfJObc1j1SkBzqZG5GukNPCqfY2n
         9HdMDvWFrIpt9K2LzNzAaRweGkfgXkPtVhqnAuNXCeI1+elgdAZdnHlTcW8rvHPg/JkA
         MmgtwvOLbYSwISSjDlK3DODs7yrMdL8LIL9sa2qQqVumZRZspOufEokGXQdk7XAjHzaL
         LRzw==
X-Gm-Message-State: APjAAAVoNbhIjIeqPVLJUfXvrKltJ1MaIHywzlVfq1mXQxojzZGZN0m+
	7wEUlN7lHizRZYlWqFuyplwFnizAFsh7dTmHdqF7K/sNA6sH9EPcXt0mh5P1LDHgKtZNAKzGbW4
	nkElpXDl86kWIZaSUXEkvSNnYFs014NZcOJ217vo3v2IUxjxEJf2f1Vq1GaJXRcOS8Q==
X-Received: by 2002:a0c:f20e:: with SMTP id h14mr69045141qvk.246.1564183222965;
        Fri, 26 Jul 2019 16:20:22 -0700 (PDT)
X-Received: by 2002:a0c:f20e:: with SMTP id h14mr69045115qvk.246.1564183222457;
        Fri, 26 Jul 2019 16:20:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564183222; cv=none;
        d=google.com; s=arc-20160816;
        b=kmouGhJ6jj0RSapUSq+2QRukPqVtKDXMU3S1B7R+3rgAhJKbk/hSBKeXt+GWdjdbYa
         9HeFvDDn9PcS9MABWFL/ZISSTSvv0ynleELdFnESCmo7WcD81BpugCitF9O+OYUNoT7X
         2M+Eo6MrqKUgTK+9+DGJ1sfJOwZD3RT7QX19vLfll4s40vq1qkPAEgNx+5xWBMIJljOl
         oIIlR8G4QL97BoG3VjQwp8GWJ6WEYr0HSljAxilWyYZ4HHv4rvo3WXSoXjfe+nhfKYzb
         l/iKMD/6KIlfwCmWWZAEWk2Yvb3dHhD1+kOg/Veo0CbdJKaIqQGB5AjfHYvCQYZjKu4a
         Eczg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WuNOArHZs/CiCRyKyjlclGYC7Ncl5iJJmT+ESUl6jAA=;
        b=ZELQ+xFOIEDSE57TV43HGmcUdIhW8HPh5xdNNXPkM9Ey7+zT/DALXIZTAgrS3ExQQa
         JiORA/d+o+ob9J5eZKLvNMZkJZa89vUuyvFAWy72zZHHWONMGvo5gc/+OkKhx+MFzrra
         ta3g8PY2IeGk3mwsYQOb2gble6l687Z0bIp7iHlx/7RcSWrvLOflFqH/gAWYllYpkhoz
         USxVW3DQKkHnTYmPv0j8w3/uJhpsbMrq/z16OTvovc7M6pIAiUqbK3X26cR+61LvNNmA
         DszISBgcvDpnWEE4X8prfBJpRqt0I3bJ4lfRa+F/MxqIa86jHE9nYRFrfy0WhL2mkbQp
         8zyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kEGHfnb+;
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x26sor45770984qvh.63.2019.07.26.16.20.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 16:20:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kEGHfnb+;
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WuNOArHZs/CiCRyKyjlclGYC7Ncl5iJJmT+ESUl6jAA=;
        b=kEGHfnb+ky7mAtpgS94T1BlDhXrjAF9XMpWdm7fL5wWt0lI7aJD3/bimEU3aictx5/
         /FVoxvjWSJOsaau/ArFWCvjl3UvCYt0UKuqbV3FAYijG3r3NaxbYAKdIv1U91mIBuOWl
         kovT+dhR3I24/oGuwK8rnhXVMwHQc2af+OjHNTY8E16Znr5UlJcLtWNs1/2WObenCUL6
         0XF23LaWT12L30puEcM9OgpjsfeZcqTR9sQGgi8O0ELN4Rr38CxkxB+JwiB78TG4CrBN
         8pld23xKRXm20Xxzwcz/LE4LBTuO3cSd5KZ05jAqnl4jlavcMrtBsfAUmwQu1m8TlvJn
         qLYg==
X-Google-Smtp-Source: APXvYqz0xh0QBYyY/zS/kJUsfUUaNRgWxOlmqjlpIVRroO/0xl0eD/u8MIKEBwL+baTN5sYIunTa2DIgnA074DTtHAM=
X-Received: by 2002:a0c:b12b:: with SMTP id q40mr71961348qvc.0.1564183221451;
 Fri, 26 Jul 2019 16:20:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190726224810.79660-1-henryburns@google.com>
In-Reply-To: <20190726224810.79660-1-henryburns@google.com>
From: Jonathan Adams <jwadams@google.com>
Date: Fri, 26 Jul 2019 16:19:45 -0700
Message-ID: <CA+VK+GM4AXrmZtv_narEU6pHO+NGrTc74iSSUNNbutZySfXjRw@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Fix z3fold_destroy_pool() ordering
To: Henry Burns <henryburns@google.com>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Shakeel Butt <shakeelb@google.com>, David Howells <dhowells@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 3:48 PM Henry Burns <henryburns@google.com> wrote:
>
> The constraint from the zpool use of z3fold_destroy_pool() is there are no
> outstanding handles to memory (so no active allocations), but it is possible
> for there to be outstanding work on either of the two wqs in the pool.
>
> If there is work queued on pool->compact_workqueue when it is called,
> z3fold_destroy_pool() will do:
>
>    z3fold_destroy_pool()
>      destroy_workqueue(pool->release_wq)
>      destroy_workqueue(pool->compact_wq)
>        drain_workqueue(pool->compact_wq)
>          do_compact_page(zhdr)
>            kref_put(&zhdr->refcount)
>              __release_z3fold_page(zhdr, ...)
>                queue_work_on(pool->release_wq, &pool->work) *BOOM*
>
> So compact_wq needs to be destroyed before release_wq.
>
> Fixes: 5d03a6613957 ("mm/z3fold.c: use kref to prevent page free/compact race")
>
> Signed-off-by: Henry Burns <henryburns@google.com>

Reviewed-by: Jonathan Adams <jwadams@google.com>

> Cc: <stable@vger.kernel.org>
> ---
>  mm/z3fold.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 1a029a7432ee..43de92f52961 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -818,8 +818,15 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
>  {
>         kmem_cache_destroy(pool->c_handle);
>         z3fold_unregister_migration(pool);
> -       destroy_workqueue(pool->release_wq);
> +
> +       /*
> +        * We need to destroy pool->compact_wq before pool->release_wq,
> +        * as any pending work on pool->compact_wq will call
> +        * queue_work(pool->release_wq, &pool->work).
> +        */
> +
>         destroy_workqueue(pool->compact_wq);
> +       destroy_workqueue(pool->release_wq);
>         kfree(pool);
>  }
>
> --
> 2.22.0.709.g102302147b-goog
>

