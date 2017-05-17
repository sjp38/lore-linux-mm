Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 498836B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 03:39:11 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id a46so1540566qte.3
        for <linux-mm@kvack.org>; Wed, 17 May 2017 00:39:11 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id r32si1355169qta.155.2017.05.17.00.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 00:39:10 -0700 (PDT)
Date: Wed, 17 May 2017 08:38:09 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH 1/2] drm: replace drm_[cm]alloc* by kvmalloc alternatives
Message-ID: <20170517073809.GJ26693@nuc-i3427.alporthouse.com>
References: <20170517065509.18659-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170517065509.18659-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>, Michal Hocko <mhocko@suse.com>

On Wed, May 17, 2017 at 08:55:08AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> drm_[cm]alloc* has grown their own kvmalloc with vmalloc fallback
> implementations. MM has grown kvmalloc* helpers in the meantime. Let's
> use those because it a) reduces the code and b) MM has a better idea
> how to implement fallbacks (e.g. do not vmalloc before kmalloc is tried
> with __GFP_NORETRY).
> 
> drm_calloc_large needs to get __GFP_ZERO explicitly but it is the same
> thing as kvmalloc_array in principle.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Just a little surprised that calloc_large users still exist.

Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>

One more feature request from mm, can we have the 
	if (size != 0 && n > SIZE_MAX / size)
check exported by itself. It is used by both kvmalloc_array and
kmalloc_array, and in my ioctls I have it open-coded as well to
differentiate between the -EINVAL (for bogus user values) and 
genuine -ENOMEM.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
