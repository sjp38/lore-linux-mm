Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id EF76D6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 06:41:08 -0500 (EST)
Received: by pabkx10 with SMTP id kx10so4739486pab.0
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 03:41:08 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id aa3si4135048pbc.163.2015.02.25.03.41.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 03:41:08 -0800 (PST)
Subject: Re: [PATCH v3 3/3] tomoyo: reduce mmap_sem hold for mm->exe_file
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1424370153.18191.12.camel@stgolabs.net>
	<201502200711.EIH87066.HSOJLFFOtFVOQM@I-love.SAKURA.ne.jp>
	<1424449696.2317.0.camel@stgolabs.net>
	<201502242035.GCI75431.LHQFOOJMFVSFtO@I-love.SAKURA.ne.jp>
	<1424806966.6539.84.camel@stgolabs.net>
In-Reply-To: <1424806966.6539.84.camel@stgolabs.net>
Message-Id: <201502252040.IHB78651.OQFSLtFFHOOJMV@I-love.SAKURA.ne.jp>
Date: Wed, 25 Feb 2015 20:40:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@stgolabs.net, jmorris@namei.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, takedakn@nttdata.co.jp, linux-security-module@vger.kernel.org, tomoyo-dev-en@lists.sourceforge.jp

Davidlohr Bueso wrote:
> The mm->exe_file is currently serialized with mmap_sem (shared) in order
> to both safely (1) read the file and (2) compute the realpath by calling
> tomoyo_realpath_from_path, making it an absolute overkill. Good users will,
> on the other hand, make use of the more standard get_mm_exe_file(), requiring
> only holding the mmap_sem to read the value, and relying on reference
> 
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>

Acked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

James, will you apply to linux-security.git#next ?
I'm not using publicly accessible git tree for sending pull requests.

> ---
> 
> Changes from v2: remove cleanups and cp initialization.
> 
>  security/tomoyo/util.c | 21 ++++++++++++---------
>  1 file changed, 12 insertions(+), 9 deletions(-)
> 
> diff --git a/security/tomoyo/util.c b/security/tomoyo/util.c
> index 2952ba5..29f3b65 100644
> --- a/security/tomoyo/util.c
> +++ b/security/tomoyo/util.c
> @@ -948,16 +948,19 @@ bool tomoyo_path_matches_pattern(const struct tomoyo_path_info *filename,
>   */
>  const char *tomoyo_get_exe(void)
>  {
> -	struct mm_struct *mm = current->mm;
> -	const char *cp = NULL;
> +       struct file *exe_file;
> +       const char *cp;
> +       struct mm_struct *mm = current->mm;
>  
> -	if (!mm)
> -		return NULL;
> -	down_read(&mm->mmap_sem);
> -	if (mm->exe_file)
> -		cp = tomoyo_realpath_from_path(&mm->exe_file->f_path);
> -	up_read(&mm->mmap_sem);
> -	return cp;
> +       if (!mm)
> +	       return NULL;
> +       exe_file = get_mm_exe_file(mm);
> +       if (!exe_file)
> +	       return NULL;
> +
> +       cp = tomoyo_realpath_from_path(&exe_file->f_path);
> +       fput(exe_file);
> +       return cp;
>  }
>  
>  /**
> -- 
> 2.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
