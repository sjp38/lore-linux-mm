Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A662BC10F00
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 18:23:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75B6D2084B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 18:23:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75B6D2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17B266B0274; Tue,  2 Apr 2019 14:23:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12A4C6B0275; Tue,  2 Apr 2019 14:23:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 017086B0276; Tue,  2 Apr 2019 14:23:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D31E36B0274
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 14:23:17 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id q127so12360187qkd.2
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 11:23:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4GWH1cpRWxVDi4vzj16KXD1lt2mEoLocrOmTDCN/JdM=;
        b=DDSdG4GzBpouK+vMnFAN7/7K6IP6uJiMdo8pGfv5l/VsOdJzkNgifluz422IsyEGnJ
         Vk+Oqh+smle057A4Rv3YTo70x63tsZGGudNB084zVevzct6RV4OSwvPZevVmkBrpRF6P
         nX122DEC3BboCYL1XWtJ7NUbOUa32mMWMVUhemNSXGT217jaYogFeONAO+Lrcj7Rl4La
         8g8nhuEVUiy8uO5jf3YiigipAcwfHoPVDGzR8kDepvqRWJFgS3HXONilYiVf3Op763uQ
         NWlKM/WypghJvfSo6c0lp2CcXgtXU2NOXyiHyfNgzR8jy8xAMJB8TsVCuASUJmTxXDz6
         ZkJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVqKYMrkEln1buF5xOrJBaKW4/zmEs4Kq7KmlCcCV9Jhs2Pile+
	wjrAtkOqifvnRbLVZaYz7HFZa6tGwbkKosZsV0B5JZpfz+7hvFuyTDooU2ys/ZXhdv/xNTUaIB2
	EJ53bftrb/t1CS2Sarv3GgE8QvweHqU4r7WK3hxEe97QPigs259xudq4m+FH1vo+fWg==
X-Received: by 2002:a0c:e587:: with SMTP id t7mr35971858qvm.114.1554229397678;
        Tue, 02 Apr 2019 11:23:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUc8oS6KydwgcSL2rQQeadojgYIXOJvvlkDFX9mG06LLNMrc3CSYiJaIdaASBDfBhG17PZ
X-Received: by 2002:a0c:e587:: with SMTP id t7mr35971823qvm.114.1554229397124;
        Tue, 02 Apr 2019 11:23:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554229397; cv=none;
        d=google.com; s=arc-20160816;
        b=H0lIHWSU0OAMkOwhK1jNFk9ypplvu/p1ePgkYtxrXkdvKj0E6+5rA8LuqtZU3wi6EB
         BAoFyAq5YROjZAJLUHyToir9DdyowKrKxyq2dEPtaqZaig4YGPPhhZodJwLOcZ2VrQjd
         TX0Yh9Tm7ShTZEVSjwL3uXfl2TLdOlCLI6FEoKVB5LC9k8LACehz5Ts0XtDx1tIXW904
         HdiNn3gfgBLjkXXGlnVNq2MifrkPXmYip75Pzfrq0S3N/l0MglItz8k5XM+NC0N7/gQq
         Hvh7847lxTjmQYfi+dHN3FyNOjNB4jCnxFJ0qNpp/+l9zj89sNyJibgcKk3wOJwWLavQ
         oV/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4GWH1cpRWxVDi4vzj16KXD1lt2mEoLocrOmTDCN/JdM=;
        b=ELslzyDfJs9h5qpcPbGm5KV4HrUYPoGPcw18oIL/gVJpEU2RUQLCu6F8OD+CU/2ZON
         m1SKLY1Ul8SzIAqj05EZkJ03ldtfaRXu/RDldv4DBgWGcYpyKJ4puibqqgLY7w3ZSS5/
         MyGgdwfTG6SM2f9Ui0pH0LWPndS3r8Kjo1QjbXP7HCX3/kBOuJF2z6JzaIERG6+ZYjaf
         SDf7mIk3OqFA2IwcaxwdMabwlNaDdfV5ez7Rdvzv/5Itn+9XGRPshCBVJbwdIvp9Kz9Z
         RZc15qMpwo8eqf8iKvJgNt3qm26ZDZZc3drJ8Zm6bU8bmuu3IMUXugc10Xt85Uf54Sy1
         UzSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z23si2021315qth.12.2019.04.02.11.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 11:23:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 66C673082A4C;
	Tue,  2 Apr 2019 18:23:16 +0000 (UTC)
Received: from x230.aquini.net (dhcp-17-61.bos.redhat.com [10.18.17.61])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 96A41194AA;
	Tue,  2 Apr 2019 18:23:10 +0000 (UTC)
Date: Tue, 2 Apr 2019 14:23:07 -0400
From: Rafael Aquini <aquini@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>,
	Pankaj Gupta <pagupta@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Michael S . Tsirkin" <mst@redhat.com>, linux-mm@kvack.org
Subject: Re: [PATCH v1] mm: balloon: drop unused function stubs
Message-ID: <20190402182307.GA12529@x230.aquini.net>
References: <20190329122649.28404-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329122649.28404-1-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 02 Apr 2019 18:23:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 01:26:49PM +0100, David Hildenbrand wrote:
> These are leftovers from the pre-"general non-lru movable page" era.
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  include/linux/balloon_compaction.h | 15 ---------------
>  1 file changed, 15 deletions(-)
> 
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> index f111c780ef1d..f31521dcb09a 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -151,21 +151,6 @@ static inline void balloon_page_delete(struct page *page)
>  	list_del(&page->lru);
>  }
>  
> -static inline bool __is_movable_balloon_page(struct page *page)
> -{
> -	return false;
> -}
> -
> -static inline bool balloon_page_movable(struct page *page)
> -{
> -	return false;
> -}
> -
> -static inline bool isolated_balloon_page(struct page *page)
> -{
> -	return false;
> -}
> -
>  static inline bool balloon_page_isolate(struct page *page)
>  {
>  	return false;
> -- 
> 2.17.2
> 
Acked-by: Rafael Aquini <aquini@redhat.com>

