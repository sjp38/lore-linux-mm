Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33C7F8E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 17:22:41 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a199so21608763qkb.23
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 14:22:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r63si12972191qkb.132.2018.12.26.14.22.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 14:22:40 -0800 (PST)
Date: Wed, 26 Dec 2018 17:22:36 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] hmm: Warn on devres_release failure
Message-ID: <20181226222236.GA4931@redhat.com>
References: <20181226180904.8193-1-pakki001@umn.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181226180904.8193-1-pakki001@umn.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aditya Pakki <pakki001@umn.edu>
Cc: kjlu@umn.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 26, 2018 at 12:09:04PM -0600, Aditya Pakki wrote:
> devres_release can return -ENOENT if the device is not freed. The fix
> throws a warning consistent with other invocations.
> 
> Signed-off-by: Aditya Pakki <pakki001@umn.edu>

Reviewed-by: J�r�me Glisse <jglisse@redhat.com>

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
