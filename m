Return-Path: <SRS0=HJeg=QJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AC58C282D8
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 01:13:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D25B22148D
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 01:13:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D25B22148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6ACF78E0011; Fri,  1 Feb 2019 20:13:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65C298E0001; Fri,  1 Feb 2019 20:13:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54ADE8E0011; Fri,  1 Feb 2019 20:13:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2978F8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 20:13:49 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w15so10436219qtk.19
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 17:13:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=fhuuF/1TJblxzF7+tEwXL1uL/HfX1tfgwA49XT+HUdg=;
        b=ft5CnXTP7K5seqPZ1pkG87D+R4D5XL/lo/8PgKHCoQr0t0TeT/uqDVBQLRUToLSxiQ
         FydtIJ8nvuJG6DNu9Ro30G96ulpWnICL+/Pt1e8hW4CL8uoX+7NJciPjVeo//6JlEkNV
         HOcQPSVAcdCKq3sFvSy+xkMEHXKb3sFeB8hfEkQVxYXur769IFk8/ionjGvGrpO3HwrB
         8sEd0OtsUm3PCdZz2X9IjS89OG8rOaXxuvKlnyXWqkLgB2CsEnTKR0+P8tzyZHlej4BB
         m8rL9GKlvIHdzpFBPi8dZW6qvWzbemEssqRy4rDU81eNLMmrGiCyABRYLZhxX/h9ChVk
         bQ+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUuke+4Lb2pg0mLybRORArEut+XtL4wkeYt1Fsum2rE2enhV6S64gd
	TAc+hzdS+QLi3vkRteZsFIbQhwNdSIpH2oc6OtGH+qJUwVbBCGFRg0SAIZ4A8kqsi0hb9PAVuCb
	KlkwZ0z1idHtr6ctKYAMJqw3xFg4DYpauMJ1rSUn0VOhO5Wy7umch82KvLIRGaZ0WXQ==
X-Received: by 2002:a0c:91e8:: with SMTP id r37mr38567147qvr.141.1549070028885;
        Fri, 01 Feb 2019 17:13:48 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4S6S7/cukw/V+b9YZ/6bFSCNq7WhGBDPnUkkDH4LnO8c5BlPmBLCts9VIKzwWliNOs1j8C
X-Received: by 2002:a0c:91e8:: with SMTP id r37mr38567112qvr.141.1549070028268;
        Fri, 01 Feb 2019 17:13:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549070028; cv=none;
        d=google.com; s=arc-20160816;
        b=dWAEwtbIeFghK1r/5nLBkPykBQcC1OqTfCZNp82Ws3hyQMcRlUa3xpMm9hGqktRI4U
         CU7cn/hEG3dZUceIr/DVdZ1jKs4IBpN3ViazUqb2tlMSFItg/PqiycATFEx9mWp0M+1L
         l+74mWT9YTj+ZmNv21SZIXq6r3kFCOT+TqpYyzZoDHXArnUgZdeiIQzxq0vFzU51ozlu
         l9Mavr0ho3wdj/Gwye5SXkupYUH9/Sq/e1Ll6iNjtj8TM299cetJzcwET8misnmWk66K
         GTiR+EKPP71cugY3cc2flABqx5Z9m09t41UgWLRWV0S+cibBWeDt+47pbqyroNUwOy1i
         9PtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=fhuuF/1TJblxzF7+tEwXL1uL/HfX1tfgwA49XT+HUdg=;
        b=k8M8Df1YmkXDdmWy+qtvMmzOWb54HWS+1voXvQZwqYVKrvAvl7NJYx2DBjUpS2cK7K
         2tuwUlw/KO51fuinw+++VCHhlEB8PCpjMlk8Ug6NuCVjQLzFMAj6vbgQ9awcsC7FdpFm
         s7KxR9GeIoTdKi9nz3AjA4Pn0ynANEHFG7hdK0kmTuUHiiHtP+RCyoImzEGU/nrYqtuu
         NikWYeq24Las51tAUQtTEnJUTpDyChKTGMG2S9Wj2Y305PrlgW7mcmN/oKvmZiGWWk7L
         PRdmTkRYuzv3U4OcwvAHWJfbX3p2Jp052KbEOdsBdqaCNu13czR8uoaaKzTB4SF74XHc
         lfwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q4si602389qkj.161.2019.02.01.17.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 17:13:48 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 521F57F771;
	Sat,  2 Feb 2019 01:13:47 +0000 (UTC)
Received: from sky.random (ovpn-121-14.rdu2.redhat.com [10.10.121.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2486460C62;
	Sat,  2 Feb 2019 01:13:41 +0000 (UTC)
Date: Fri, 1 Feb 2019 20:13:40 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Peter Xu <peterx@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	kvm@vger.kernel.org
Subject: Re: [RFC PATCH 2/4] mm/mmu_notifier: use unsigned for event field in
 range struct
Message-ID: <20190202011340.GD12463@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
 <20190131183706.20980-3-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190131183706.20980-3-jglisse@redhat.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Sat, 02 Feb 2019 01:13:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 01:37:04PM -0500, Jerome Glisse wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> Use unsigned for event field in range struct so that we can also set
> flags with the event. This patch change the field and introduce the
> helper.
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Peter Xu <peterx@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Krčmář <rkrcmar@redhat.com>
> Cc: kvm@vger.kernel.org
> ---
>  include/linux/mmu_notifier.h | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index be873c431886..d7a35975c2bd 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -6,6 +6,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/mm_types.h>
>  #include <linux/srcu.h>
> +#include <linux/log2.h>
>  
>  struct mmu_notifier;
>  struct mmu_notifier_ops;
> @@ -38,8 +39,11 @@ enum mmu_notifier_event {
>  	MMU_NOTIFY_PROTECTION_VMA,
>  	MMU_NOTIFY_PROTECTION_PAGE,
>  	MMU_NOTIFY_SOFT_DIRTY,
> +	MMU_NOTIFY_EVENT_MAX
>  };
>  
> +#define MMU_NOTIFIER_EVENT_BITS order_base_2(MMU_NOTIFY_EVENT_MAX)
> +
>  #ifdef CONFIG_MMU_NOTIFIER
>  
>  /*
> @@ -60,7 +64,7 @@ struct mmu_notifier_range {
>  	struct mm_struct *mm;
>  	unsigned long start;
>  	unsigned long end;
> -	enum mmu_notifier_event event;
> +	unsigned event;
>  	bool blockable;
>  };

This is only allocated in the stack, so saving RAM by mixing bitfields
with enum in the same 4 bytes to save 4 bytes isn't of maximum
priority.

A possibly cleaner way to save those 4 bytes without mixing enum with
bitfields by hand, is to add a "unsigned short flags" which will make
"event/flags/blockable" fit in the same 8 bytes (bool only needs 1
byte) as before the patch (the first bitfield can start from 0 then).

Yet another way is to drop blockable and convert it to a flag in
"unsigned int flags".

