Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E583C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 13:58:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD61822DA7
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 13:58:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uXjwPjRZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD61822DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 685686B000C; Wed, 29 May 2019 09:58:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 636D46B000D; Wed, 29 May 2019 09:58:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5252C6B000E; Wed, 29 May 2019 09:58:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC6956B000C
	for <linux-mm@kvack.org>; Wed, 29 May 2019 09:58:30 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id a25so736429lfl.0
        for <linux-mm@kvack.org>; Wed, 29 May 2019 06:58:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FvnuOzvWWHxvWxRXVyec6ngD8uETWcADOgiOUZyOXOI=;
        b=GWDjrMfe8JGCfH5f1sJEy7TPwe1AfJIeDyTTvwq3poHxW0hXEx4TwqtV5r2qhy6cvx
         2VoPhKQX+Razt0jf4jf4ohHZ/mlYEKFIDqlLFRsnqkZzj3hPZfxiMJDYgGFUHY05waNT
         ZyVebqb95uc9MKrX2QCj96vElNi3GMOIfyuUtU0Anu+kAB5nQwletyeaEz7v/JorDTig
         MZ2CneRLE6OkEOLmJ0VwKZHc2qjPhB+cfkWK5R9CLQGaUB37wzrsdYxpygytceqUqw9f
         /wMOv+Px9pBKFXJayWbW9K7YqqrhzS/Su0SpOamaRzMoAyoYmauEYbnpD+1snOCDxX8N
         VRXQ==
X-Gm-Message-State: APjAAAXTi4eQgNPnqdlci4TXieYBDpyc7xnItOx005CBX87ivANztkkP
	FUXN1MZGU/WVuLa6a+xpygdcN+QkzdkgxTfMgyuutF3/N1lIq2A6PCljUe3wq1J7N6IF28IllG2
	Ftq3gR6BMu/o3xLk/mEcPA18C1arPDf2mOb8F/09Clz567Ah9feDZCTbBo3lCNBdRRA==
X-Received: by 2002:a19:521a:: with SMTP id m26mr18964906lfb.134.1559138310043;
        Wed, 29 May 2019 06:58:30 -0700 (PDT)
X-Received: by 2002:a19:521a:: with SMTP id m26mr18964768lfb.134.1559138307028;
        Wed, 29 May 2019 06:58:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559138307; cv=none;
        d=google.com; s=arc-20160816;
        b=WceY2yQAgddqQgUNDAfiPCJIKmMBYG3lkWH4S7nLZ8L30YjJBu77iBJU3OtN/IPFtE
         luBYZ/JGWUpVnPl0P9RYUWoBISUW6IY5Ka2Hj5yQE00G3+ogeSa4hUPFo8Maxfxsbgz8
         mSgOTl7VHnBcJ+51wmNjAtwYZpS63JkCHHgL2SEq8PDSWqDQ3G5DxQZ6/FSyXvMhYw/c
         yKrldF4LXRACaLKq9g/MG5hmmxVhBqSc1F8MM5ZxLaMxxYfueN9N9hCpX+6dqG811L/P
         9JMwZj7MupVHIHL3UZlzaHrp8m13qH2qbAsATiQG9+56dV4aIETvcZ6FBQ2mTmisO0Eo
         1IjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=FvnuOzvWWHxvWxRXVyec6ngD8uETWcADOgiOUZyOXOI=;
        b=DxqJTTtZSvzWHVLQEsed6Ph7D04Jk0p47D4sRdMoI0403br5dzAiPKI3xKb077fMPV
         7I0PidioMYuSDJAn9jSa3xo1vHTsgmFF+C7YwfND00IfA4tmNm04xNhNQtXwLQ6MEZTk
         JeQhRCJS+patkWkOcBN3aCa9lFN/FYucQDvYOClBUiOcUHlV5zI0wo8jeYmP7esCXK4w
         telk//SowkM0SK31j26MG6f6IZMw3Wk08pA60RvM9p0qDu5kP67zBkUbOvumVprty7G7
         yd9B8TH03K2IhXUavvCJxNL1P4zVBJIHJofXA35nIDXLTeX2plE5z82aEbefJ4FDk20x
         wsWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uXjwPjRZ;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a5sor2726047ljf.4.2019.05.29.06.58.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 06:58:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uXjwPjRZ;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=FvnuOzvWWHxvWxRXVyec6ngD8uETWcADOgiOUZyOXOI=;
        b=uXjwPjRZCt5+NzEnNPmdCCkF3iYjQdmKQjzHPmIBvcHk21+tVcQk6R/TffAC7mbzK7
         3OwgsrDjSkovmg4CpeCxkjLO/kQQvYs0pmQohCNI7L8gZdD8RGrfY4VGJdYTU4SoFB3v
         vxOJmH2NmOUBLSaEMsTV4T0d7uI//nBlM9nMZjIItiftF4IVJAOz7r5HkBkNRO1ocej9
         uSw6MboF7GCpcr9BVSt1oVeMNInBa+xY8WKUwIpqaSATf3Ri/vgGphqjpJDKCfIuJNPw
         2XVz/73HtiI5Ls00TDoUhrA2TsMBVDDDh2a2MIgaAD8+i7k63TUUX87Zz6QC0oBlSFQ1
         qdNA==
X-Google-Smtp-Source: APXvYqxJcXNy9tjvGvb6p0Lmjk07Ff52IXEus1xxpwJYnnL8XqCx75U51Gw9O4dVXAeZBa+45pmDaQ==
X-Received: by 2002:a2e:a0ca:: with SMTP id f10mr1708409ljm.113.1559138306581;
        Wed, 29 May 2019 06:58:26 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id d18sm3473580lfl.95.2019.05.29.06.58.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 06:58:25 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Wed, 29 May 2019 15:58:17 +0200
To: Roman Gushchin <guro@fb.com>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Message-ID: <20190529135817.tr7usoi2xwx5zl2s@pc636>
References: <20190527093842.10701-1-urezki@gmail.com>
 <20190527093842.10701-5-urezki@gmail.com>
 <20190528225001.GI27847@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528225001.GI27847@tower.DHCP.thefacebook.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Roman!

> > Move the BUG_ON()/RB_EMPTY_NODE() check under unlink_va()
> > function, it means if an empty node gets freed it is a BUG
> > thus is considered as faulty behaviour.
> 
> It's not exactly clear from the description, why it's better.
> 
It is rather about if "unlink" happens on unhandled node it is
faulty behavior. Something that clearly written in stone. We used
to call "unlink" on detached node during merge, but after:

[PATCH v3 3/4] mm/vmap: get rid of one single unlink_va() when merge

it is not supposed to be ever happened across the logic.

>
> Also, do we really need a BUG_ON() in either place?
> 
Historically we used to have the BUG_ON there. We can get rid of it
for sure. But in this case, it would be harder to find a head or tail
of it when the crash occurs, soon or later.

> Isn't something like this better?
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index c42872ed82ac..2df0e86d6aff 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1118,7 +1118,8 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
>  
>  static void __free_vmap_area(struct vmap_area *va)
>  {
> -       BUG_ON(RB_EMPTY_NODE(&va->rb_node));
> +       if (WARN_ON_ONCE(RB_EMPTY_NODE(&va->rb_node)))
> +               return;
>
I was thinking about WARN_ON_ONCE. The concern was about if the
message gets lost due to kernel ring buffer. Therefore i used that.
I am not sure if we have something like WARN_ONE_RATELIMIT that
would be the best i think. At least it would indicate if a warning
happens periodically or not.

Any thoughts?

Thanks for the comments!

--
Vlad Rezki

