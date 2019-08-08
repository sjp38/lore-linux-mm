Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66FDDC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:43:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E06E02171F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:43:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E06E02171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46A3B6B0003; Thu,  8 Aug 2019 03:43:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41B9D6B0006; Thu,  8 Aug 2019 03:43:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BC496B0007; Thu,  8 Aug 2019 03:43:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E823A6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 03:43:10 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 71so55014527pld.1
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 00:43:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=J9phvYeL4FEfFLUCKkycdIePfKSt/FXlggKfdJujWns=;
        b=ed8lSxF+KgF9KOXMFgKUeY2sGR/A5xv7B9i6iNTQ2Njv+KXXcEywFwHX/xZd4fYNZW
         kHYn+XSS1ksX6cqG+MPZlz9FLKM5R5pnjPr7EIB/mkb+3MfUkGPYQC62/Kfnvz7K1+It
         J4ELTPYyhSUYICwppn474Rq3vG/TqUY70dy7ZXX4p3riiBcGOuN/6gx+ufknA9E3SIHW
         qeoT2WFE13AXnWBYML4n+4qKHnhr/ITHws7hyUy6llUBDkXo1B68OLoPPdrINLkI6zht
         L32hFQqptYV6oHliy9/ELcMiPj7XCZC2UQ5tFyDIecAHmobD5gKP1AkYHqU2u53sMpoS
         s2Ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAX2rKuCKpZCacvsIoQDVTOmVOp3EMSRZPunab/fqGYmHslEyqu6
	p3u6ooWDww9AQmgMhY4jv3Joxb1on9rVMNn+4RmVYWowTJCcEbPrkYkRi2vWjReI7CYQbeQQayk
	okmTO+ie/ZIgrxG16RZm+hKUb6txMPcEzA7POgeF27sicluvq01HYa/cnl6HQdlTYpg==
X-Received: by 2002:a63:f926:: with SMTP id h38mr11495699pgi.80.1565250190391;
        Thu, 08 Aug 2019 00:43:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwokH5JU5XUgpkm6yRgat2cXDlatkCcGUQ4KGd9KFwGJBU+cpIqQpAWuxfbH1aRbYu3sBMm
X-Received: by 2002:a63:f926:: with SMTP id h38mr11495636pgi.80.1565250189420;
        Thu, 08 Aug 2019 00:43:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565250189; cv=none;
        d=google.com; s=arc-20160816;
        b=UmAikvANTFzrKZIlgQMJJYLZT2dOse2qPZXLVzWfzJq11GDGoyJcELn4Leow56Gjum
         9Rdz5QGurpKi5+MEGE8bwz4xIxsybSKHB3EIiXCNHrcl0cO9t0Bs2GtPrwdlR5rWwLNC
         beDXCROAAMPhcTt/cZ34tMYIlscmAgOW0Yb6RhShl1Rm8/W8kI0zc7YeWD8vNY2c7VF0
         PVIxySYz3I8Swjo/kQ9Ny62K9hwz4Mb/n8XqiLS1/0TLHmtEDCMEIlrob/s7bcGn3fRY
         OjlZ62PTF1eGR/zcCLsKhAq5eZgAh79lG3sUGaX0SzX861xWVPp5z06ekhxYaDY4fP9L
         VRGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=J9phvYeL4FEfFLUCKkycdIePfKSt/FXlggKfdJujWns=;
        b=l9EaLDJhOBIi3MQzoCdo68KtQJ+PYULwz/1txh99foN3cFFuy8nY9lLybGNYrZ5Wei
         D4ND9WW2NqKbiP2YG/aAvWFOaqJVsbC3WU9sX/uPuV8j7A5GTBIzzk9JbPd/3ZYxRHmb
         3OsvGR+DV0b84eQaqAcj7fGhbRARjBnyY8awQslS/HIplC90N0wg9nFoVSKGY7WdP96t
         rw+U2zR7YCI/xaV7jK0MROBZGD8ZKY8nM8tczeMUUIFGPbhzXKLj7Y6VLIERCTx80FKJ
         Rq0GAIHQrX216W/QDNn3a642FCbnggG9xkh8s/qLKnjHnMMurh6XntbjB+wLIJGpuPDT
         A2CA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-162.sinamail.sina.com.cn (mail3-162.sinamail.sina.com.cn. [202.108.3.162])
        by mx.google.com with SMTP id d9si52706272pgv.577.2019.08.08.00.43.08
        for <linux-mm@kvack.org>;
        Thu, 08 Aug 2019 00:43:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) client-ip=202.108.3.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([114.253.230.179])
	by sina.com with ESMTP
	id 5D4BD2870003564E; Thu, 8 Aug 2019 15:43:06 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 30895649291193
From: Hillf Danton <hdanton@sina.com>
To: Alex Deucher <alexdeucher@gmail.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Dave Airlie <airlied@gmail.com>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	amd-gfx list <amd-gfx@lists.freedesktop.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	dri-devel <dri-devel@lists.freedesktop.org>,
	"Deucher, Alexander" <Alexander.Deucher@amd.com>,
	Harry Wentland <harry.wentland@amd.com>,
	"Koenig, Christian" <Christian.Koenig@amd.com>
Subject: Re: The issue with page allocation 5.3 rc1-rc2 (seems drm culprit here)
Date: Thu,  8 Aug 2019 15:42:52 +0800
Message-Id: <20190808074252.6864-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 8 Aug 2019 13:32:06 +0800 Alex Deucher wrote:
> 
> On Wed, Aug 7, 2019 at 11:49 PM Mikhail Gavrilov wrote:
> >
> > Unfortunately error "gnome-shell: page allocation failure: order:4,
> > mode:0x40cc0(GFP_KERNEL|__GFP_COMP),
> > nodemask=(null),cpuset=/,mems_allowed=0" still happens even with
> > applying this patch.

Thanks Mikhail.

No surpring to see the warning because of kvmalloc on top of the current
kmalloc. Any other difference observed?

> I think we can just drop the kmalloc altogether.

Dropping kmalloc altogether OTOH makes the reason for the vmalloc
fallback IMO, Sir?

> How about this patch?
> 
> From: Alex Deucher <alexander.deucher@amd.com>
> Date: Thu, 8 Aug 2019 00:29:23 -0500
> Subject: [PATCH] drm/amd/display: use kvmalloc for dc_state
> 
> It's large and doesn't need contiguous memory.
> 
> Signed-off-by: Alex Deucher <alexander.deucher@amd.com>
> ---

Looks good to me if with a kvfree added.

>  drivers/gpu/drm/amd/display/dc/core/dc.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/gpu/drm/amd/display/dc/core/dc.c b/drivers/gpu/drm/amd/display/dc/core/dc.c
> index 252b621d93a9..ef780a4e484a 100644
> --- a/drivers/gpu/drm/amd/display/dc/core/dc.c
> +++ b/drivers/gpu/drm/amd/display/dc/core/dc.c
> @@ -23,6 +23,7 @@
>   */
>  
>  #include <linux/slab.h>
> +#include <linux/mm.h>
>  
>  #include "dm_services.h"
>  
> @@ -1183,8 +1184,8 @@ bool dc_post_update_surfaces_to_stream(struct dc *dc)
>  
>  struct dc_state *dc_create_state(struct dc *dc)
>  {
> -	struct dc_state *context = kzalloc(sizeof(struct dc_state),
> -					   GFP_KERNEL);
> +	struct dc_state *context = kvzalloc(sizeof(struct dc_state),
> +					    GFP_KERNEL);
>  
>  	if (!context)
>  		return NULL;
> @@ -1204,11 +1205,11 @@ struct dc_state *dc_create_state(struct dc *dc)
>  struct dc_state *dc_copy_state(struct dc_state *src_ctx)
>  {
>  	int i, j;
> -	struct dc_state *new_ctx = kmemdup(src_ctx,
> -			sizeof(struct dc_state), GFP_KERNEL);
> +	struct dc_state *new_ctx = kvmalloc(sizeof(struct dc_state), GFP_KERNEL);
>  
>  	if (!new_ctx)
>  		return NULL;
> +	memcpy(new_ctx, src_ctx, sizeof(struct dc_state));
>  
>  	for (i = 0; i < MAX_PIPES; i++) {
>  			struct pipe_ctx *cur_pipe = &new_ctx->res_ctx.pipe_ctx[i];
> -- 
> 2.20.1
> 

