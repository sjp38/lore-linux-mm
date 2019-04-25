Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A18CC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 13:30:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C0BB216E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 13:30:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C0BB216E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42AE06B000C; Thu, 25 Apr 2019 09:30:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DA8E6B000D; Thu, 25 Apr 2019 09:30:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CA986B000E; Thu, 25 Apr 2019 09:30:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDFA6B000C
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 09:30:48 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c25so18698695qkl.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 06:30:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=43OmQrnFkrEwz12O626kd+5shZ0DD1D/a1O+89ISq6Y=;
        b=jo66QBywFbYidzf578uzw/IdDmRVOT8Hw00Ge3CqeVfwnC82LToTl2kxgu1qi6go1Y
         LPq+9I656mPwX6VKSb48up2/pakz2PerT+KqiKPEkOnDe0W1LAqmP+mHeU2iL5CADFhd
         4MLAFnEw7JHjR9ftUGLhxhzAHyijpgVW1LxW5bd0XHGfvRYfoL94Zf2yIyMJNPgGOIYV
         CFKY975Tk07VuzaPRdwIRlUVfnjsH7RaaWAeXFZGSsoXdRasznFVvFAR6XtxJcVTn15G
         OdPkUd5U75KDoYentE8I2gkGJI4e+tNUW1fi7K9zU5X3FdEdZE4L15royfmYU83CoVnC
         YrZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXpKsCI1K/pDiUpx9qcA3FAAIyD4AHJbqArOYHcUB8bXMYS9fOz
	hm3KOYyL6XAdsVIP5TlEZ9K9s+fw47q/YR9Ermdc0KJ4nD8Q3qLTjFxIrX1T86wiB4P8lTUjp60
	nnFTdOkdIC/9C2ToCnNS4OIW777NMpUDdKIOzoQHlBzSHgWcXGiT/TEaFFwyuuHW4+A==
X-Received: by 2002:ae9:e8c3:: with SMTP id a186mr20161523qkg.346.1556199047799;
        Thu, 25 Apr 2019 06:30:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYE+VQjBJkZesZtCQVJuiTFFv3r87DYD8l9/EtJXuIAqMR6QDNrWIuPXMGNtnjYObgQFXQ
X-Received: by 2002:ae9:e8c3:: with SMTP id a186mr20161479qkg.346.1556199047204;
        Thu, 25 Apr 2019 06:30:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556199047; cv=none;
        d=google.com; s=arc-20160816;
        b=eZ5Po781cQjB/MHS3WbEIJs9ntmDA+XfleeVfZCwbJOn87vJRx9iVw8jTfNSfhxNr8
         IkiPe5NtHK+QL8UvDf6Ma1bvwzOaqmILaNScyl5YDl050mI4Jom+V9RpwnIsF1MykmYz
         Ztpqcp881Gl9m/vZbJ4JA3mATooBbnXjOzk7BbCrUZbIO9TDkP+As/LUv+Kz4eP9iNzR
         xuJqyP3qhd07jchVzZRsWIZNryXGdOklot/AJFqTDjQp2e7eu+HVtHLoJ4TwbdM8AuRh
         e1Jdlpyx83d/hKeXJ1BVqoM3FH7ShlTf9cwW6g05cC5k1pnkNe0kBfdYujBcdEC3QODO
         p1PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=43OmQrnFkrEwz12O626kd+5shZ0DD1D/a1O+89ISq6Y=;
        b=T4jLsaK+DmbOhCqln9aOk9CuQ7jXpgH7bYx2zMG5At7nncngO5eRsGPcnjnqr/mlIF
         14gonBGyPigyzT+/72Mm7kIQmztCtLKcWf+qJCQLoaTetnGyQiUEbQcqWK2Q6NP4A+o5
         xGP/NATEt0xU83seqz/BIdRgB41tusmszEKHDJymzjff6BSwGL0f0hadMIh9wwS3wnWt
         bKJ86+++mBCS7apvSoxvr9KgG4upwV9Ve8nSdJYZJiRwjaGf4DFKuEph07JSZ7rdZcdJ
         7OCL/TMHaFXCWvjJrHTSDG0zYsysFh0r9efNGdKav145F8jonzRfa74n4GIC2Zo8ITOM
         NnUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q65si4414947qke.268.2019.04.25.06.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 06:30:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1C46B30BCE5A;
	Thu, 25 Apr 2019 13:30:46 +0000 (UTC)
Received: from treble (ovpn-123-99.rdu2.redhat.com [10.10.123.99])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 73C7760923;
	Thu, 25 Apr 2019 13:30:34 +0000 (UTC)
Date: Thu, 25 Apr 2019 08:30:32 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	linux-mm@kvack.org, David Rientjes <rientjes@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, Daniel Vetter <daniel@ffwll.ch>,
	intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Miroslav Benes <mbenes@suse.cz>, linux-arch@vger.kernel.org
Subject: Re: [patch V3 24/29] tracing: Remove the last struct stack_trace
 usage
Message-ID: <20190425133032.ds27oje6nxswvdji@treble>
References: <20190425094453.875139013@linutronix.de>
 <20190425094803.340000461@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190425094803.340000461@linutronix.de>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 25 Apr 2019 13:30:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 11:45:17AM +0200, Thomas Gleixner wrote:
> Simplify the stack retrieval code by using the storage array based
> interface.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
> ---
>  kernel/trace/trace_stack.c |   37 ++++++++++++++++---------------------
>  1 file changed, 16 insertions(+), 21 deletions(-)
> 
> --- a/kernel/trace/trace_stack.c
> +++ b/kernel/trace/trace_stack.c
> @@ -23,11 +23,7 @@
>  static unsigned long stack_dump_trace[STACK_TRACE_ENTRIES];
>  static unsigned stack_trace_index[STACK_TRACE_ENTRIES];
>  
> -struct stack_trace stack_trace_max = {
> -	.max_entries		= STACK_TRACE_ENTRIES,
> -	.entries		= &stack_dump_trace[0],
> -};
> -
> +static unsigned int stack_trace_entries;

"stack_trace_entries" -> "nr_stack_trace_entries"

-- 
Josh

