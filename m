Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94D7DC43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 22:22:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F6AA214AE
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 22:22:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F6AA214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EC938E0008; Wed, 26 Dec 2018 17:22:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79AE98E0001; Wed, 26 Dec 2018 17:22:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 615468E0008; Wed, 26 Dec 2018 17:22:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33C7F8E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 17:22:41 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a199so21608763qkb.23
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 14:22:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=6cAzG43IZW0KiebFxUSi6Wqm1nJEyZbTnx1VlBSSCk4=;
        b=t08yLfRij6xyhtso0cCsMPw2kzd2f2qpesQssfOsyIviRpXqq/xDcFlSfX2NnBWc8j
         9qUKWKxnxYztHfycqgArQ93wWvymnnt2DtUWP0YYdNNJ7WiK64+HKSeesee1WkQDd7US
         VIrQN7ItBEDoVlNIDovDrb2m8tLEO/N2senDAAqVDz3CouxFMYtHtcohTwBP2pnXHl3a
         Yg7jrGeSUDdgk0DV2gBgE+ykFeqiqdnBYzQ1Ix8t2zryXZ6w8oXNxTPjmn/ap83JlcKM
         Z/2gPmY0Es4USDzL6jUQNO9weWFyEWhyz8tJ5aXcMFsb3AbQYJAlwa4O2NuHibzTKTdl
         0Phw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUuke3N+eJqRv067bh4gM2Ua7+rFTZxZWeiMROoInAZfgHF1LArAaG
	2J6MdaJp+c6urzfvpqejyThaXDgHSZnNKMVq7wqFzfX3C1hXOSvsD5PdV465RWgiDUTcYvh6f/o
	yAtqcT4ig8p7/hoi9uCfFzTEjn2Y9z4PGb2ZZck8nBibiaBThxjmOmVWH4xSGpkbeqg==
X-Received: by 2002:a0c:9292:: with SMTP id b18mr20258324qvb.187.1545862960975;
        Wed, 26 Dec 2018 14:22:40 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5Yu4LW/LNJkdu/6k21D/6ytsACdpQU8W6vQDWSOz69XnHyJTw3I6jeJ69+yfJdpXBUofxl
X-Received: by 2002:a0c:9292:: with SMTP id b18mr20258302qvb.187.1545862960349;
        Wed, 26 Dec 2018 14:22:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545862960; cv=none;
        d=google.com; s=arc-20160816;
        b=t2MRi/f/vUlsS1Jo5Jj7mJhOsP30/QRbai+Rj94yhBaIX8Gj/lQ4JnkOwcW2BmwIoI
         BjTmQ62wzG5pUoxwTOHWa40rop2LY6lrbfVFAWidbCXKTZmZLHAtrYi6iRSi2TCk4q4L
         R4j+D92QgdyDkjtVPoaeUvmVFyZtCJEiGWy/tcBaHhwlElssVTXIN5D0znbU4/n8ydY1
         HnZ/5Z5ZSRt+g37f0pd0W5HmTYt12y5co0uvIiRLgLemoRFzFcFrchzA7gMESe5zfY4a
         eIkUjyL7aZIRNQXQFYyWhZPyNwSHvdRnHTPt6wHNPBGBBLk4axoOwq8aRHBw9FYuNYnn
         4Faw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=6cAzG43IZW0KiebFxUSi6Wqm1nJEyZbTnx1VlBSSCk4=;
        b=AGxWj9TqLf9nKiTXqddI29f+sDLTJK+bLbDh5oNz/rX0q9dc5sAdascGWPUFxM7753
         gzw6uwR1y2swiN4HIRjRgnFY216bhwgzPanRAdtC7A+ocQqoWEGisBcoIbQkNWFeXhbU
         /zrclghJYAI7xRgmgo4WxYekDV2BpeZDHN7ezirU5c9pAwYRfUabCuXNVyW4PIo0UmGQ
         YwyC3vhv2eBNE5kV8yPj71TwfJxzxZNc4CNxMTPAOZkgDOkNOD+yPbUeR5Iqt0r5RCqE
         paU0f16u34zJbwuUrUTtTdPxLoLyj7G4PVyDxzHvyxsJT0DH2T5zbCSCA9T4ZhRIkeKZ
         4Z2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r63si12972191qkb.132.2018.12.26.14.22.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 14:22:40 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 62F7E155E4;
	Wed, 26 Dec 2018 22:22:39 +0000 (UTC)
Received: from redhat.com (ovpn-120-211.rdu2.redhat.com [10.10.120.211])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 92119608E2;
	Wed, 26 Dec 2018 22:22:38 +0000 (UTC)
Date: Wed, 26 Dec 2018 17:22:36 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Aditya Pakki <pakki001@umn.edu>
Cc: kjlu@umn.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] hmm: Warn on devres_release failure
Message-ID: <20181226222236.GA4931@redhat.com>
References: <20181226180904.8193-1-pakki001@umn.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181226180904.8193-1-pakki001@umn.edu>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 26 Dec 2018 22:22:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226222236.cCH81BSQO23jiwKiYaI_jjBa4x9C-VUoKfhaTnCol9k@z>

On Wed, Dec 26, 2018 at 12:09:04PM -0600, Aditya Pakki wrote:
> devres_release can return -ENOENT if the device is not freed. The fix
> throws a warning consistent with other invocations.
> 
> Signed-off-by: Aditya Pakki <pakki001@umn.edu>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  mm/hmm.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 90c34f3d1243..b06e3f092fbf 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -1183,8 +1183,12 @@ static int hmm_devmem_match(struct device *dev, void *data, void *match_data)
>  
>  static void hmm_devmem_pages_remove(struct hmm_devmem *devmem)
>  {
> -	devres_release(devmem->device, &hmm_devmem_release,
> -		       &hmm_devmem_match, devmem->resource);
> +	int rc;
> +
> +	rc = devres_release(devmem->device, &hmm_devmem_release,
> +				&hmm_devmem_match, devmem->resource);
> +	if (rc)
> +		WARN_ON(rc);
>  }
>  
>  /*
> -- 
> 2.17.1
> 

