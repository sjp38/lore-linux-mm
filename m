Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 275BC900015
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 06:07:35 -0500 (EST)
Received: by padet14 with SMTP id et14so8657133pad.11
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 03:07:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id gz1si4256735pbd.38.2015.02.19.03.07.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Feb 2015 03:07:34 -0800 (PST)
Subject: Re: [PATCH 3/3] tomoyo: robustify handling of mm->exe_file
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	<1424304641-28965-4-git-send-email-dbueso@suse.de>
	<1424324307.18191.5.camel@stgolabs.net>
In-Reply-To: <1424324307.18191.5.camel@stgolabs.net>
Message-Id: <201502192007.AFI30725.tHFFOOMVFOQSLJ@I-love.SAKURA.ne.jp>
Date: Thu, 19 Feb 2015 20:07:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@stgolabs.net
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, takedakn@nttdata.co.jp, linux-security-module@vger.kernel.org

Thank you, but I think this patch is wrong and redundant.

Davidlohr Bueso wrote:
> On Wed, 2015-02-18 at 16:10 -0800, Davidlohr Bueso wrote:
> > +static const char *tomoyo_get_exe(struct mm_struct *mm)
> > +{
> > +	struct file *exe_file;
> > +	const char *cp = NULL;
> > +
> > +	if (!mm)
> > +		return NULL;
> > +	exe_file = get_mm_exe_file(mm);
> > +	if (!exe_file)
> > +		return NULL;
> > +
> > +	cp = tomoyo_realpath_from_path(&exe_file->f_path);
> 
> tomoyo_realpath_from_path can return NULL here, thus we'd leak the
> f_path in the caller... I guess this should be:
> 
> > +	path_get(&exe_file->f_path);
> 
> 	if (cp)
> 		path_get(&exe_file->f_path);
> 
Why do we need to let the caller call path_put() ?
There is no need to do like proc_exe_link() does, for
tomoyo_get_exe() returns pathname as "char *".

> > +	fput(exe_file);
> > +	return cp;
> > +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
