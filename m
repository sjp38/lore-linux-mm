Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 15637828E2
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:36:11 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 124so31001470pfg.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:36:11 -0800 (PST)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0083.outbound.protection.outlook.com. [65.55.169.83])
        by mx.google.com with ESMTPS id bs10si4196017pad.73.2016.02.29.05.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Feb 2016 05:36:10 -0800 (PST)
Subject: Re: [PATCH 17/18] drm/radeon: make radeon_mn_get wait for mmap_sem
 killable
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-18-git-send-email-mhocko@kernel.org>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <56D4493B.7010004@amd.com>
Date: Mon, 29 Feb 2016 14:35:55 +0100
MIME-Version: 1.0
In-Reply-To: <1456752417-9626-18-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org

[Dropping CCing the individual people, but adding the dri-devel mailing 
list as well instead].

Am 29.02.2016 um 14:26 schrieb Michal Hocko:
> From: Michal Hocko <mhocko@suse.com>
>
> radeon_mn_get which is called during ioct path relies on mmap_sem for
> write. If the waiting task gets killed by the oom killer it would block
> oom_reaper from asynchronous address space reclaim and reduce the
> chances of timely OOM resolving. Wait for the lock in the killable mode
> and return with EINTR if the task got killed while waiting.
>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: "Christian KA?nig" <christian.koenig@amd.com>
> Cc: David Airlie <airlied@linux.ie>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

This one and patch #18 in this series are Reviewed-by: Christian KA?nig 
<christian.koenig@amd.com>.

Nice to see some improvements on this side,
Christian.

> ---
>   drivers/gpu/drm/radeon/radeon_mn.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
> index eef006c48584..896f2cf51e4e 100644
> --- a/drivers/gpu/drm/radeon/radeon_mn.c
> +++ b/drivers/gpu/drm/radeon/radeon_mn.c
> @@ -186,7 +186,9 @@ static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
>   	struct radeon_mn *rmn;
>   	int r;
>   
> -	down_write(&mm->mmap_sem);
> +	if (down_write_killable(&mm->mmap_sem))
> +		return ERR_PTR(-EINTR);
> +
>   	mutex_lock(&rdev->mn_lock);
>   
>   	hash_for_each_possible(rdev->mn_hash, rmn, node, (unsigned long)mm)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
