Date: Tue, 17 Jul 2007 12:32:43 -0400
From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: [PATCH 05/17] lib: percpu_count_sum_signed()
Message-ID: <20070717163243.GA15421@filer.fsl.cs.sunysb.edu>
References: <20070614215817.389524447@chello.nl> <20070614220446.659716697@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070614220446.659716697@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, andrea@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, Jun 14, 2007 at 11:58:22PM +0200, Peter Zijlstra wrote:
> Provide an accurate version of percpu_counter_read.
> 
> Should we go and replace the current use of percpu_counter_sum()
> with percpu_counter_sum_positive(), and call this new primitive
> percpu_counter_sum() instead?
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  include/linux/percpu_counter.h |   18 +++++++++++++++++-
>  lib/percpu_counter.c           |    6 +++---
>  2 files changed, 20 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6/include/linux/percpu_counter.h
> ===================================================================
> --- linux-2.6.orig/include/linux/percpu_counter.h	2007-05-23 20:37:54.000000000 +0200
> +++ linux-2.6/include/linux/percpu_counter.h	2007-05-23 20:38:09.000000000 +0200
> @@ -35,7 +35,18 @@ void percpu_counter_destroy(struct percp
>  void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
>  void __percpu_counter_mod(struct percpu_counter *fbc, s32 amount, s32 batch);
>  void __percpu_counter_mod64(struct percpu_counter *fbc, s64 amount, s32 batch);
> -s64 percpu_counter_sum(struct percpu_counter *fbc);
> +s64 __percpu_counter_sum(struct percpu_counter *fbc);
> +
> +static inline s64 percpu_counter_sum(struct percpu_counter *fbc)
> +{
> +	s64 ret = __percpu_counter_sum(fbc);
> +	return ret < 0 ? 0 : ret;

max(0, ret) maybe?

Josef 'Jeff' Sipek.

-- 
Real Programmers consider "what you see is what you get" to be just as bad a
concept in Text Editors as it is in women. No, the Real Programmer wants a
"you asked for it, you got it" text editor -- complicated, cryptic,
powerful, unforgiving, dangerous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
