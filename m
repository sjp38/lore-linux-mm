Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83ECAC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:19:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2499B217F9
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:19:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2499B217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACF7B6B0005; Thu, 18 Apr 2019 18:19:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7B9E6B0006; Thu, 18 Apr 2019 18:19:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F94A6B0007; Thu, 18 Apr 2019 18:19:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 529FB6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:19:46 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s22so2271151plq.1
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:19:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PjZi58gVreWv5Iuxlzjg5s/x6NQFE2omkHjhJQ21L0Y=;
        b=m/UbhIoVTDqfjiNFpIriqoxEILHv6DIniERZaMNjsvgHnRrEVMI1CNeWyQCYU1hDqt
         K4IhIPexh5jjgtoVngQNdIRQJ9NC/Zl+YW8wZxzO5QDozXLNTHLvjPjMa4koH3iKR7n9
         o1qebr6rTzg9zHYq9Epym+8ZxvmgNhY31xSqrSjdMdZ2Cwl6eTIBRhKw1kBnq6Ywosv+
         RpuSDADlZeKGVUZzgfQYj4ZxsPEpVJIqTozFWJ6MrsnvpvyOayhaFKn4Tw0UvlaqLiij
         q3tF8/SpTSiZKN1/Pcnmspzcvf5I2aLrTbdcEDuzzgkNEbvJ+Jk2MPtqBVCposc5uEpU
         0xgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAVVO2d/SsDpnSe9ccu84Uj9YJCeFvre2aeSk6UGODcgnrTam4rO
	BceBnE0qxye7wGv1vT9Y7CgFNFjQ1ienw/dZhHmiboJN0tY5t+2hwX8N/18hHfZM8rrp+5PMvOv
	cq4oVHjIuPixVe2PkW1vClQzq/dTKaI9HYNP0YSEgOXJqWtDnsm8uqjNf1IzJp+M=
X-Received: by 2002:a65:5687:: with SMTP id v7mr351806pgs.299.1555625985933;
        Thu, 18 Apr 2019 15:19:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5ZKw78dkVaqDbNBjt/M7LwtQvqJ0KLjy87TGub1WNAlgCRCCB0lFdMmaWnMAlUjdicxYg
X-Received: by 2002:a65:5687:: with SMTP id v7mr351739pgs.299.1555625985081;
        Thu, 18 Apr 2019 15:19:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555625985; cv=none;
        d=google.com; s=arc-20160816;
        b=sS3J/80QtqBgx1CpPaLJPj+NbUdehXm7SVkjY3z75iqj94H5QUCDIeIVUiz2tK7arm
         kD/ZFqMqxljX+gfIe0DdqRxNlOdHPy71b44O3wWx/+sJkd5PdAmZeA7CIdsAH/wok1wg
         /30iGao+z5AGasuw1M5Ws4hb/RN6usaSb01P4RfV4xX7rRbX0iTAyslSK2cZ2rilYMHq
         qzb+UZzu7/xfTXnGwF5JrHFZSiDmoIopNSPelZrF24Gcj+51/luovWFKHCAo7BWJS0dX
         awhwORExcg7HaJFDJCpBIiiVVoMiTCwgZV1oLLzlt3SWxNWkZd1fJYZtOb/O/BCePVyQ
         CBMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=PjZi58gVreWv5Iuxlzjg5s/x6NQFE2omkHjhJQ21L0Y=;
        b=bmZZnMTGV6tLS6xkbgTf3Yi98tTM+RoG3k8IlVTBhX5LG8vJsU21q2GxzWjuqVNqV5
         fYimcDrjfHKSOBbVrrwA2aNW7KEdy1RkGLy95LkEGkfkRZEvNaQwwSup6EisIf/AFyA9
         FKD9cPqKuJ3nVSETMyuGcD5jH0iPKfE/VtzrC2o0DfryD0SoPsUAhT2GCLG5Ab11Ttam
         tmwllIu8CQbADzf39wmn87WAI4ybNyFDQIXTmpuFlbAzIDZVKV5laqFMjWYC1MnWeet7
         xFNs+hZZcdTnmKXMP03bob690uKTqMxOj/bNpjOVGECOO9RbR8vh2ABdZuikulkkY/8e
         dmOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b23si3260256pls.430.2019.04.18.15.19.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 15:19:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 509352064A;
	Thu, 18 Apr 2019 22:19:41 +0000 (UTC)
Date: Thu, 18 Apr 2019 18:19:38 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf
 <jpoimboe@redhat.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>,
 Alexander Potapenko <glider@google.com>, Alexey Dobriyan
 <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka
 Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes
 <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey
 Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, Mike
 Rapoport <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Johannes Thumshirn <jthumshirn@suse.de>, David
 Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, Josef Bacik
 <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 linux-arch@vger.kernel.org
Subject: Re: [patch V2 01/29] tracing: Cleanup stack trace code
Message-ID: <20190418181938.2e2a9a04@gandalf.local.home>
In-Reply-To: <20190418084253.142712304@linutronix.de>
References: <20190418084119.056416939@linutronix.de>
	<20190418084253.142712304@linutronix.de>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 10:41:20 +0200
Thomas Gleixner <tglx@linutronix.de> wrote:


> @@ -412,23 +404,20 @@ stack_trace_sysctl(struct ctl_table *tab
>  		   void __user *buffer, size_t *lenp,
>  		   loff_t *ppos)
>  {
> -	int ret;
> +	int ret, was_enabled;

One small nit. Could this be:

	int was_enabled;
	int ret;

I prefer only joining variables that are related on the same line.
Makes it look cleaner IMO.

>  
>  	mutex_lock(&stack_sysctl_mutex);
> +	was_enabled = !!stack_tracer_enabled;
>  

Bah, not sure why I didn't do it this way to begin with. I think I
copied something else that couldn't do it this way for some reason and
didn't put any brain power behind the copy. :-/ But that was back in
2008 so I blame it on being "young and stupid" ;-)

Other then the above nit and removing the unneeded +1 in max_entries:

Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve


>  	ret = proc_dointvec(table, write, buffer, lenp, ppos);
>  
> -	if (ret || !write ||
> -	    (last_stack_tracer_enabled == !!stack_tracer_enabled))
> +	if (ret || !write || (was_enabled == !!stack_tracer_enabled))
>  		goto out;
>  
> -	last_stack_tracer_enabled = !!stack_tracer_enabled;
> -
>  	if (stack_tracer_enabled)
>  		register_ftrace_function(&trace_ops);
>  	else
>  		unregister_ftrace_function(&trace_ops);
> -
>   out:
>  	mutex_unlock(&stack_sysctl_mutex);
>  	return ret;
> @@ -444,7 +433,6 @@ static __init int enable_stacktrace(char
>  		strncpy(stack_trace_filter_buf, str + len, COMMAND_LINE_SIZE);
>  
>  	stack_tracer_enabled = 1;
> -	last_stack_tracer_enabled = 1;
>  	return 1;
>  }
>  __setup("stacktrace", enable_stacktrace);
> 

