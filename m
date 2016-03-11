Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2B26B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 10:23:16 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id n186so23339049wmn.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:23:16 -0800 (PST)
Subject: Re: [PATCH 16/18] drm/i915: make i915_gem_mmap_ioctl wait for
 mmap_sem killable
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-17-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E2E2DC.9010806@suse.cz>
Date: Fri, 11 Mar 2016 16:23:08 +0100
MIME-Version: 1.0
In-Reply-To: <1456752417-9626-17-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

On 02/29/2016 02:26 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> i915_gem_mmap_ioctl relies on mmap_sem for write. If the waiting
> task gets killed by the oom killer it would block oom_reaper from
> asynchronous address space reclaim and reduce the chances of timely OOM
> resolving. Wait for the lock in the killable mode and return with EINTR
> if the task got killed while waiting.
>
> Cc: Daniel Vetter <daniel.vetter@intel.com>
> Cc: David Airlie <airlied@linux.ie>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   drivers/gpu/drm/i915/i915_gem.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
> index f68f34606f2f..a50136cbd332 100644
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -1754,7 +1754,10 @@ i915_gem_mmap_ioctl(struct drm_device *dev, void *data,
>   		struct mm_struct *mm = current->mm;
>   		struct vm_area_struct *vma;
>
> -		down_write(&mm->mmap_sem);
> +		if (down_write_killable(&mm->mmap_sem)) {
> +			drm_gem_object_unreference_unlocked(obj);
> +			return -EINTR;
> +		}
>   		vma = find_vma(mm, addr);
>   		if (vma)
>   			vma->vm_page_prot =
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
