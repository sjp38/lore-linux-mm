Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36AA7C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:20:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0DAB2084B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:20:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0DAB2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BCC46B0005; Tue, 26 Mar 2019 05:20:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76CAD6B0006; Tue, 26 Mar 2019 05:20:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65AAF6B0007; Tue, 26 Mar 2019 05:20:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AEB56B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:20:51 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id x125so146713oix.17
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:20:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=zemCmibtaoX3q0w9wSy5V2h50Omizvur52zLBvlN87Y=;
        b=YZKHGw2qcaxdQ0Y66Ot5wVLUW4ccZcf/egAEziQKauNstWG4z5xbOKAq6TcwIBcOnB
         OTHWlr4vF89fINlbC8VZaYjxbQjZuA2xf1WnpodbR8MmpVitsSQrKv4Uc9HkoN8IQ6YW
         TnGMwhVYPkIjj2Dh6S3iDvdhdlHYnpr1McreovigQscOiaz8Kocguat2xgue9qkT4byp
         6BHKw4rapV0+9eccN+JyGrdXPUE9ySt4STQJaiw00rv9GOyaAJtDvR2CFlouJ0JrR+v4
         sYX9YQgT8mlz4MO9YNh/gG84YtxOOSHzAGaCB6veoDhUJZ0ECvTtJHyhFypouQbkeMsx
         E0YQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX5YD1eVi/P5YzOpEDPzFg7ds4U7kGoaNaLZ47VAcaf9YBJTHdH
	xHeGW0HsVAIYDZ3MNfOyDGKj3epFjwQBesIDO4WfdopojXxznlo+RvTgqhYK4CK+nYwzKuZ0qz4
	5QWGTutXJazCmhhKVtpUBQFQqo548z2BFUkqclNQP65EqpCBqhQpVURqrwbhkC+Y=
X-Received: by 2002:aca:407:: with SMTP id 7mr13757205oie.90.1553592050706;
        Tue, 26 Mar 2019 02:20:50 -0700 (PDT)
X-Received: by 2002:aca:407:: with SMTP id 7mr13757175oie.90.1553592049922;
        Tue, 26 Mar 2019 02:20:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553592049; cv=none;
        d=google.com; s=arc-20160816;
        b=KDHBpGPSPkGXCJxARhE32UP0LSN5f1ie7J2rlh9u7WeWvslq9+EJXgRdRi361kWf3T
         TByEWWl60EgTfGwOhhmGCjPMuJgQHH/fbFEFITS7wDeclQrY5N1w7NXmb2J9dILd61Ow
         JQKJHQ0jz37pbaGOMfglEvw95TAD5YyNU/iaR0riiWwrq7aYZtpwzI2yeWEXYfosXeiB
         P2SiQcZb/Nbzb6yHgNIi00hG4YBt4S+hkJGSZmPQ5VA2YuSVajBpU3AvIeqsGcjiqRu7
         97H1ch7xfAcF/03wiQZ/nPP8TVClimYKuHoH0aFFdr/7yHuIHcIWEfK/CB60LacWKtGj
         Y6zQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=zemCmibtaoX3q0w9wSy5V2h50Omizvur52zLBvlN87Y=;
        b=aRYmQlv1e5+Pc6IGWOiziLBWGv37jwHPABYhCgdLKtmuJ14S7GP5NeqHVKd603BSLF
         tVxEY9FrRxHbEvPvd0IB4tAlH/kdJ2qnU88ldAbksS9/2F8Mxd6aMAIaqVLbgzRBzwPK
         bV8ThvJWF7cdnIxkno4xy1B3NABlTla9n3PzRdRV/zlBYhXxlFOzClqofAScIqr+XbRw
         q/4U2i13O6Izf0fvL42aOIE6aNarNxPs2aq3WVf1OA3QHAzwOhyOw/t4moqv7cJYGyhq
         YZuiPgzNuxLFy6e87ISRh/REHlK3mEmDNH9hkfOQt+JNRSW1IFUV+RjhxnwCtxzk8UCL
         TF2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l17sor10917341oih.159.2019.03.26.02.20.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Mar 2019 02:20:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqwWiVNkUg0kQnllObtpc5oZuAO/qHdzOMWzDEo7vVIYb/NTFDa/3nyuSCLamnpkTKiDNR14xV1HQ6RPuDHgViY=
X-Received: by 2002:aca:5c55:: with SMTP id q82mr15015032oib.95.1553592049441;
 Tue, 26 Mar 2019 02:20:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190326090227.3059-1-bhe@redhat.com> <20190326090227.3059-5-bhe@redhat.com>
In-Reply-To: <20190326090227.3059-5-bhe@redhat.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 26 Mar 2019 10:20:38 +0100
Message-ID: <CAJZ5v0gcweDzkmYPFB3zVE8Np4ptMy1nuB0=HLuWHbHKZuuhrw@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] drivers/base/memory.c: Rename the misleading parameter
To: Baoquan He <bhe@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, rppt@linux.ibm.com, osalvador@suse.de, 
	Matthew Wilcox <willy@infradead.org>, william.kucharski@oracle.com, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 10:02 AM Baoquan He <bhe@redhat.com> wrote:
>
> The input parameter 'phys_index' of memory_block_action() is actually
> the section number, but not the phys_index of memory_block. Fix it.
>
> Signed-off-by: Baoquan He <bhe@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  drivers/base/memory.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index cb8347500ce2..184f4f8d1b62 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -231,13 +231,13 @@ static bool pages_correctly_probed(unsigned long start_pfn)
>   * OK to have direct references to sparsemem variables in here.
>   */
>  static int
> -memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
> +memory_block_action(unsigned long sec, unsigned long action, int online_type)
>  {
>         unsigned long start_pfn;
>         unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
>         int ret;
>
> -       start_pfn = section_nr_to_pfn(phys_index);
> +       start_pfn = section_nr_to_pfn(sec);
>
>         switch (action) {
>         case MEM_ONLINE:
> @@ -251,7 +251,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
>                 break;
>         default:
>                 WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
> -                    "%ld\n", __func__, phys_index, action, action);
> +                    "%ld\n", __func__, sec, action, action);
>                 ret = -EINVAL;
>         }
>
> --
> 2.17.2
>

