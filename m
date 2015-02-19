Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 083E26B00B5
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 00:38:37 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id uz6so10758020obc.9
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 21:38:36 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id z4si4733564oew.26.2015.02.18.21.38.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 21:38:36 -0800 (PST)
Message-ID: <1424324307.18191.5.camel@stgolabs.net>
Subject: Re: [PATCH 3/3] tomoyo: robustify handling of mm->exe_file
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 18 Feb 2015 21:38:27 -0800
In-Reply-To: <1424304641-28965-4-git-send-email-dbueso@suse.de>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	 <1424304641-28965-4-git-send-email-dbueso@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, takedakn@nttdata.co.jp, penguin-kernel@I-love.SAKURA.ne.jp, linux-security-module@vger.kernel.org

On Wed, 2015-02-18 at 16:10 -0800, Davidlohr Bueso wrote:
> +static const char *tomoyo_get_exe(struct mm_struct *mm)
> +{
> +	struct file *exe_file;
> +	const char *cp = NULL;
> +
> +	if (!mm)
> +		return NULL;
> +	exe_file = get_mm_exe_file(mm);
> +	if (!exe_file)
> +		return NULL;
> +
> +	cp = tomoyo_realpath_from_path(&exe_file->f_path);

tomoyo_realpath_from_path can return NULL here, thus we'd leak the
f_path in the caller... I guess this should be:

> +	path_get(&exe_file->f_path);

	if (cp)
		path_get(&exe_file->f_path);

> +	fput(exe_file);
> +	return cp;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
