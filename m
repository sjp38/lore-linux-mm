Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 521F5C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:59:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0902620883
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:59:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0902620883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 907E06B027F; Mon, 27 May 2019 08:59:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 891766B0280; Mon, 27 May 2019 08:59:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7599E6B0281; Mon, 27 May 2019 08:59:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3286F6B027F
	for <linux-mm@kvack.org>; Mon, 27 May 2019 08:59:32 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d9so13315386pfo.13
        for <linux-mm@kvack.org>; Mon, 27 May 2019 05:59:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wLiBt/t/UjkGi1BhdUme/ZAvgvM1qy5UCuVgCoqAn3g=;
        b=ZS3REJ8kxUz9OF22n8gzlNLLPdaS3na+Bwjfk7Z4H0A6oZYeEScUPWq1zuusKzAFxt
         3DBfFxZpz3PV4zM9PagFi5T0C9ZA8a4MQ5VKZix7qZq2mpUpHs2OMQKNk1IPGj1HSwXl
         w7owJlPSRz9lfXoujIeQrk6xPEU3ryZ7gWu4unSLVSHEygRdf+VBq8xBbs8Hp1QrWHuo
         gfJdJW3qNNWlKOEZGSENoHaPs6karb9BK8v5RZJX+SLC6hSfJLyxBtkACqFmWnrpqev8
         0Qpjez3ernvmMzYyNGjGbetyGHVQVuMjG9rHaxZFtoSgWKEALhivuIPHeooyNrVYb8cR
         /uoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=gqbm=t3=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=GqBM=T3=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAUNmxsudg/ORhDD5B497GGhQQRZWslX9HV31tfhTvwI88jfi2gS
	/TEySMCLlHkkgo1+RRTUT3CKVDwN9iBCCN2ZUFIjmhf81VnIV0NVmujjt3aXOF58ZfX1WvGd6zH
	kvkOZEqONQ0k8npYR2YdKmVdHH0m5MSaHKNQeyOeG9SnPwirWX+yswq/hZZtQfTQ=
X-Received: by 2002:a63:b1d:: with SMTP id 29mr126030090pgl.103.1558961971802;
        Mon, 27 May 2019 05:59:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzkl/p9e2l+Hzn3U3Mak2U8A7c+rWhw6KsI+jtgFQoxa5C8lf3nHiuIvVqmi141/+Ch4Ql
X-Received: by 2002:a63:b1d:: with SMTP id 29mr126030055pgl.103.1558961971059;
        Mon, 27 May 2019 05:59:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558961971; cv=none;
        d=google.com; s=arc-20160816;
        b=xZvDc+VcILVZ8eGnz3ASwjy1EXbA0GTA9vn+j3DyB7O9pHxqk4oXLda0Q8QuJTABoh
         EaTyetD2EOsPTde5J35WLTbK0JAGsIKdLFM8n0sOXUpdYFvfWcspMYdl9miizpDfOB5i
         XN9ODtiF5yZz4mMs2iC7rNsFJynbf7zotjaikmcfjfkVlOXThMC8vqj/g9GTFsBiiuq3
         OTokpurz2tjw9jPqyYel9yzqbzydFsrP1S5A3EVtts8BocDRNA1IpmHdLgLIB8ZqcxwF
         YciktWSItVWPe0LJ9CaBB/pORr4mOImHTGqGQUBL2JTsP8eviLgBhveMmVHbSd6gDFeS
         ppPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=wLiBt/t/UjkGi1BhdUme/ZAvgvM1qy5UCuVgCoqAn3g=;
        b=qMIQwh63J3tgP+zFvy8beLc5447rbdjiuFl6E0R4Wjg6ECfLif4cnru25COYNqlbky
         Tr0W52HNZVjxYodxADkMVig6UDbDwqhfuO0Xg4dRzoa0l5/45urqpTsXAR4E6sxdBOYp
         5SfbbrkkQvT5vS7kNl6rM4Nnh/hghZaO/sM4MQRndohd5uK8gXDNzikjwzwZqqC6tQtT
         v0NAx5OQjkQOVouNiQAVK1VSFuJV/HvV8x8s4Q/FBWSe4vUpKMuOtYvIMGrdsvLCZm2e
         R48G5SRePIGlzx95khfmqRxNAVVZGAnmrPgtHAQwupP3gZ0Ivun5uMqYp1++sLZFCSjd
         vwxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=gqbm=t3=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=GqBM=T3=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s16si17030072plr.292.2019.05.27.05.59.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 05:59:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=gqbm=t3=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=gqbm=t3=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=GqBM=T3=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 733AE20859;
	Mon, 27 May 2019 12:59:29 +0000 (UTC)
Date: Mon, 27 May 2019 08:59:27 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Roman
 Gushchin <guro@fb.com>, Hillf Danton <hdanton@sina.com>, Michal Hocko
 <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, LKML
 <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>,
 Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Joel Fernandes
 <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@elte.hu>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Message-ID: <20190527085927.19152502@gandalf.local.home>
In-Reply-To: <20190527093842.10701-5-urezki@gmail.com>
References: <20190527093842.10701-1-urezki@gmail.com>
	<20190527093842.10701-5-urezki@gmail.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 May 2019 11:38:42 +0200
"Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:

> Move the BUG_ON()/RB_EMPTY_NODE() check under unlink_va()
> function, it means if an empty node gets freed it is a BUG
> thus is considered as faulty behaviour.

Can we switch it to a WARN_ON(). We are trying to remove all BUG_ON()s.
If a user wants to crash on warning, there's a sysctl for that. But
crashing the system can make it hard to debug. Especially if it is hit
by someone without a serial console, and the machine just hangs in X.
That is very annoying.

With a WARN_ON, you at least get a chance to see the crash dump.

-- Steve


> 
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> ---
>  mm/vmalloc.c | 24 +++++++++---------------
>  1 file changed, 9 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 371aba9a4bf1..340959b81228 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -533,20 +533,16 @@ link_va(struct vmap_area *va, struct rb_root *root,
>  static __always_inline void
>  unlink_va(struct vmap_area *va, struct rb_root *root)
>  {
> -	/*
> -	 * During merging a VA node can be empty, therefore
> -	 * not linked with the tree nor list. Just check it.
> -	 */
> -	if (!RB_EMPTY_NODE(&va->rb_node)) {
> -		if (root == &free_vmap_area_root)
> -			rb_erase_augmented(&va->rb_node,
> -				root, &free_vmap_area_rb_augment_cb);
> -		else
> -			rb_erase(&va->rb_node, root);
> +	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
>  
> -		list_del(&va->list);
> -		RB_CLEAR_NODE(&va->rb_node);
> -	}
> +	if (root == &free_vmap_area_root)
> +		rb_erase_augmented(&va->rb_node,
> +			root, &free_vmap_area_rb_augment_cb);
> +	else
> +		rb_erase(&va->rb_node, root);
> +
> +	list_del(&va->list);
> +	RB_CLEAR_NODE(&va->rb_node);
>  }
>  
>  #if DEBUG_AUGMENT_PROPAGATE_CHECK
> @@ -1187,8 +1183,6 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
>  
>  static void __free_vmap_area(struct vmap_area *va)
>  {
> -	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
> -
>  	/*
>  	 * Remove from the busy tree/list.
>  	 */

