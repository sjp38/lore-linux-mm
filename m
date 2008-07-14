Subject: Re: [PATCH][RFC] dirty balancing for cgroups
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080709060034.0CB2D5A29@siro.lan>
References: <20080709060034.0CB2D5A29@siro.lan>
Content-Type: text/plain
Date: Mon, 14 Jul 2008 15:37:17 +0200
Message-Id: <1216042637.12595.76.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, menage@google.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-07-09 at 15:00 +0900, YAMAMOTO Takashi wrote:
> hi,
> 
> the following patch is a simple implementation of
> dirty balancing for cgroups.  any comments?
> 
> it depends on the following fix:
> 	http://lkml.org/lkml/2008/7/8/428
> 
> YAMAMOTO Takashi
> 
> 
> Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
> ---

Yamamoto-san,

> @@ -408,7 +412,11 @@ get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
>  
>  		*pbdi_dirty = bdi_dirty;
>  		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
> -		task_dirty_limit(current, pbdi_dirty);
> +		task_dirty = *pbdi_dirty;
> +		task_dirty_limit(current, &task_dirty);
> +		cgroup_dirty = *pbdi_dirty;
> +		memdirtylimitcgroup_dirty_limit(current, &cgroup_dirty);
> +		*pbdi_dirty = min(task_dirty, cgroup_dirty);
>  	}
>  }

I think this is wrong - is basically breaks task dirty throttling within
groups. You'd need a multiplicative operation, something like:

  bdi_dirty = dirty * p(bdi) * p(cgroup) * (1 - p(task))

However then we still have problems... see the next email further down
the thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
