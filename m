Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97F1A6B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 10:33:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id j72so829822wmi.6
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 07:33:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u76si395887wmf.69.2017.08.28.07.33.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 07:33:08 -0700 (PDT)
Date: Mon, 28 Aug 2017 16:33:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/hmm: fix build when HMM is disabled
Message-ID: <20170828143307.GC17080@dhcp22.suse.cz>
References: <3c9df006-0cc5-3a32-b715-1fbb43cb9ea8@infradead.org>
 <20170826002149.20919-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170826002149.20919-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

I have only now noticed this patch and it fixes allnoconfig failure
I saw earlier this day and tried to address by
http://lkml.kernel.org/r/20170828075931.GC17097@dhcp22.suse.cz

On Fri 25-08-17 20:21:49, jglisse@redhat.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> Combinatorial Kconfig is painfull. Withi this patch all below combination
> build.
> 
> 1)
> 
> 2)
> CONFIG_HMM_MIRROR=y
> 
> 3)
> CONFIG_DEVICE_PRIVATE=y
> 
> 4)
> CONFIG_DEVICE_PUBLIC=y
> 
> 5)
> CONFIG_HMM_MIRROR=y
> CONFIG_DEVICE_PUBLIC=y
> 
> 6)
> CONFIG_HMM_MIRROR=y
> CONFIG_DEVICE_PRIVATE=y
> 
> 7)
> CONFIG_DEVICE_PRIVATE=y
> CONFIG_DEVICE_PUBLIC=y
> 
> 8)
> CONFIG_HMM_MIRROR=y
> CONFIG_DEVICE_PRIVATE=y
> CONFIG_DEVICE_PUBLIC=y
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> ---
>  include/linux/hmm.h | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 9583d9a15f9c..96d6b1232c07 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -498,7 +498,7 @@ struct hmm_device {
>  struct hmm_device *hmm_device_new(void *drvdata);
>  void hmm_device_put(struct hmm_device *hmm_device);
>  #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
> -
> +#endif /* IS_ENABLED(CONFIG_HMM) */
>  
>  /* Below are for HMM internal use only! Not to be used by device driver! */
>  #if IS_ENABLED(CONFIG_HMM_MIRROR)
> @@ -513,6 +513,4 @@ static inline void hmm_mm_destroy(struct mm_struct *mm) {}
>  static inline void hmm_mm_init(struct mm_struct *mm) {}
>  #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
>  
> -
> -#endif /* IS_ENABLED(CONFIG_HMM) */
>  #endif /* LINUX_HMM_H */
> -- 
> 2.13.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
