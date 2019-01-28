Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57D92C282CD
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF1382084C
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:45:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="rIzslTGd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF1382084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A61B8E0002; Mon, 28 Jan 2019 11:45:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52ECD8E0001; Mon, 28 Jan 2019 11:45:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F7678E0002; Mon, 28 Jan 2019 11:45:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA778E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:45:06 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id x125so18519470qka.17
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:45:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yX0lx2enEm0ho3MBCT9f8E7DZGiastAJR1EiGt/PD+g=;
        b=UeRPRcKFo6vaDcbyyVmUmf2CUvLLM3VfMsKPJiuuLzFZSDuQzXLlQVRnxw4vlXwoeL
         h7c6VW3Xgkivdqm1RRiehj1M9rOMOMYCrFi28v26JiXt+GFii1IWEKNJ89WJ5KHi5WcJ
         BW9LxaaIcFY7Le2xQ679mYZ51vt7VH+t2om5msoO0CM5kEEFV7/lRHQWt8Mw2aiN7ie8
         LRo+JFLRCDVdcap3Oeva6E8eNSMDxULY7i/+bSIbuWuNBMZmg6H6iJdgJC1gwXg05Amb
         sjorY6qKVFknnAfkLJxNBNnQuj1InOHan+CNv3zc6HwSZQ+WNQDvEo6I7IN4LjA6Yhk5
         c+RQ==
X-Gm-Message-State: AJcUukc//0X4IvHEFE1aMKK97JMHIQVpKDoeZHOXu1QakyNPKs0tP4yl
	YAZnFiExbhvnjGnwCpAcdpaK83I03GL04buWxNf4GT6pOQTfwgCeMjH3OlctMJg3BWUID+XoT8N
	9RcNoJQbNgSS1AVs/2uilX4i9oNXvlqVlG8RFplp36K7GHdY+TK2oSm8DzVtr0NQLSMu9n/7Prv
	lKRix/6tyW20Y2hPKqlURiiD2gPretWinIfWJfXwaRZpxXDxmzH94OamaqUoxU5eNUvab0X3OBl
	oiG0B0sH8gONM2NDHcvOcfrxkEprzTCsIqnRzQuO35Ro3Xa8u8OLSTOQw/cKsWBfEa+JDUz/yiU
	PrT49BFFOHBewd6DbOA9ZwG04ECcdsXEx8t4PskomDHeKKl+EuKSls16cEpDIjxwaeFqNKlXe4l
	+
X-Received: by 2002:a0c:985d:: with SMTP id e29mr21211613qvd.16.1548693905688;
        Mon, 28 Jan 2019 08:45:05 -0800 (PST)
X-Received: by 2002:a0c:985d:: with SMTP id e29mr21211570qvd.16.1548693905006;
        Mon, 28 Jan 2019 08:45:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548693905; cv=none;
        d=google.com; s=arc-20160816;
        b=Pj0ptwVqOaYOvNzSjQYn7vjsdJwPpDbU0KLklOCUUksLo0AuzgpNc8u6EoDTpXW1wz
         gIzglrizR/M2Y1SC3HebsEAelFVT9xHIO5nJe3SL7OfvVbdt1kx7o6iivo5sy4HNjTc/
         ACOTPgHS03K1WvIPlGwEZ8SYaWI0Cu2/6c+8YZKBBqfQzTz8lNLPo4L94Ah27W4895uz
         0BHw8+/BBMBm+whAR+pDSjdMcBy8lcwOt9S6x89VH5jQirXNuoYISG3uzdzLVCey2btu
         5rg1pIvMd+OIcZBYxQotsaAXR4cHqbl5wqIDALKXb5YWbUWDoQQr+gVDtyNVgkA5n9FL
         bBxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yX0lx2enEm0ho3MBCT9f8E7DZGiastAJR1EiGt/PD+g=;
        b=RA0ggwmS7VUlRx9RkODAR1lpFjEWJ8kZuNcjW1KKV1dxq9ySW/2ZJwe4MIg8XhM8II
         JZIL3SQ4P0ekVrSTBPCuAjeI3XaXubnYDWVi/rnqRZCMdj7ZOBYeENUh6KmiyI177t69
         HCrWxPgC+omML+sQNH/+JbYhTHeTrd3Suwr2KobCDCTmcoStiNnMWK/EfYNoqclSmqCx
         WGsywqw7eGHUaoWKi/70ES4a6ItPdZGEuP72inTGgTsO58CTmS9Mcsr5GodQhUfesgPw
         x0oGaLFPGv4ejLFGn8SUyt39c5TXxJgKNUz32GsnACXIJgA0QHEGthAJ0U2yq/zTSmbv
         MWRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=rIzslTGd;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e11sor135627624qti.4.2019.01.28.08.45.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 08:45:04 -0800 (PST)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=rIzslTGd;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yX0lx2enEm0ho3MBCT9f8E7DZGiastAJR1EiGt/PD+g=;
        b=rIzslTGdanb2OhJ9WsCE0cZo8ngvCLC8GljHWKMvGCk9qg1D5X4UdljVEUy/4ID7XD
         pN7hkaGuI44+ldFu7cZkRaMnA3H7iJ2fC5leWHfMwOAsTYdhtdT2bsa12XNWGpUqovPa
         aS4OIUW5iJfsGvLIMhUwQb/MCjclMt1ydLrDY=
X-Google-Smtp-Source: ALg8bN6Okkn6VGO5VUPUUEjc8DtkIfFV+RPv0Hatm7QLi5IsmcbGh/a89HRckacmq69QyFBHCWHMUA==
X-Received: by 2002:aed:30c4:: with SMTP id 62mr21276888qtf.290.1548693904561;
        Mon, 28 Jan 2019 08:45:04 -0800 (PST)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id p42sm79595432qte.8.2019.01.28.08.45.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 08:45:03 -0800 (PST)
Date: Mon, 28 Jan 2019 11:45:02 -0500
From: Joel Fernandes <joel@joelfernandes.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Todd Kjos <tkjos@google.com>,
	syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com,
	ak@linux.intel.com, Johannes Weiner <hannes@cmpxchg.org>,
	jack@suse.cz, jrdr.linux@gmail.com,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	mawilcox@microsoft.com, mgorman@techsingularity.net,
	syzkaller-bugs@googlegroups.com,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: possible deadlock in __do_page_fault
Message-ID: <20190128164502.GA260885@google.com>
References: <201901230201.x0N214eq043832@www262.sakura.ne.jp>
 <20190123155751.GA168927@google.com>
 <201901240152.x0O1qUUU069046@www262.sakura.ne.jp>
 <20190124134646.GA53008@google.com>
 <d736c8f5-eba1-2da8-000f-4b2a80ad74ff@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <d736c8f5-eba1-2da8-000f-4b2a80ad74ff@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128164502.CZiIqs39jjZmLpvGxi4jdllJjssgDHJcwJnQmbb3EfU@z>

On Sat, Jan 26, 2019 at 01:02:06AM +0900, Tetsuo Handa wrote:
> On 2019/01/24 22:46, Joel Fernandes wrote:
> > On Thu, Jan 24, 2019 at 10:52:30AM +0900, Tetsuo Handa wrote:
> >> Joel Fernandes wrote:
> >>>> Anyway, I need your checks regarding whether this approach is waiting for
> >>>> completion at all locations which need to wait for completion.
> >>>
> >>> I think you are waiting in unwanted locations. The only location you need to
> >>> wait in is ashmem_pin_unpin.
> >>>
> >>> So, to my eyes all that is needed to fix this bug is:
> >>>
> >>> 1. Delete the range from the ashmem_lru_list
> >>> 2. Release the ashmem_mutex
> >>> 3. fallocate the range.
> >>> 4. Do the completion so that any waiting pin/unpin can proceed.
> >>>
> >>> Could you clarify why you feel you need to wait for completion at those other
> >>> locations?
> 
> OK. Here is an updated patch.
> Passed syzbot's best-effort testing using reproducers on all three reports.
> 
> From f192176dbee54075d41249e9f22918c32cb4d4fc Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 25 Jan 2019 23:43:01 +0900
> Subject: [PATCH] staging: android: ashmem: Don't call fallocate() with ashmem_mutex held.
> 
> syzbot is hitting lockdep warnings [1][2][3]. This patch tries to fix
> the warning by eliminating ashmem_shrink_scan() => {shmem|vfs}_fallocate()
> sequence.
> 
> [1] https://syzkaller.appspot.com/bug?id=87c399f6fa6955006080b24142e2ce7680295ad4
> [2] https://syzkaller.appspot.com/bug?id=7ebea492de7521048355fc84210220e1038a7908
> [3] https://syzkaller.appspot.com/bug?id=e02419c12131c24e2a957ea050c2ab6dcbbc3270
> 
> Reported-by: syzbot <syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com>
> Reported-by: syzbot <syzbot+148c2885d71194f18d28@syzkaller.appspotmail.com>
> Reported-by: syzbot <syzbot+4b8b031b89e6b96c4b2e@syzkaller.appspotmail.com>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  drivers/staging/android/ashmem.c | 23 ++++++++++++++++++-----
>  1 file changed, 18 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
> index 90a8a9f..d40c1d2 100644
> --- a/drivers/staging/android/ashmem.c
> +++ b/drivers/staging/android/ashmem.c
> @@ -75,6 +75,9 @@ struct ashmem_range {
>  /* LRU list of unpinned pages, protected by ashmem_mutex */
>  static LIST_HEAD(ashmem_lru_list);
>  
> +static atomic_t ashmem_shrink_inflight = ATOMIC_INIT(0);
> +static DECLARE_WAIT_QUEUE_HEAD(ashmem_shrink_wait);
> +
>  /*
>   * long lru_count - The count of pages on our LRU list.
>   *
> @@ -438,7 +441,6 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
>  static unsigned long
>  ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
> -	struct ashmem_range *range, *next;
>  	unsigned long freed = 0;
>  
>  	/* We might recurse into filesystem code, so bail out if necessary */
> @@ -448,17 +450,27 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
>  	if (!mutex_trylock(&ashmem_mutex))
>  		return -1;
>  
> -	list_for_each_entry_safe(range, next, &ashmem_lru_list, lru) {
> +	while (!list_empty(&ashmem_lru_list)) {
> +		struct ashmem_range *range =
> +			list_first_entry(&ashmem_lru_list, typeof(*range), lru);
>  		loff_t start = range->pgstart * PAGE_SIZE;
>  		loff_t end = (range->pgend + 1) * PAGE_SIZE;
> +		struct file *f = range->asma->file;
>  
> -		range->asma->file->f_op->fallocate(range->asma->file,
> -				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> -				start, end - start);
> +		get_file(f);
> +		atomic_inc(&ashmem_shrink_inflight);
>  		range->purged = ASHMEM_WAS_PURGED;
>  		lru_del(range);
>  
>  		freed += range_size(range);
> +		mutex_unlock(&ashmem_mutex);
> +		f->f_op->fallocate(f,
> +				   FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> +				   start, end - start);
> +		fput(f);
> +		if (atomic_dec_and_test(&ashmem_shrink_inflight))
> +			wake_up_all(&ashmem_shrink_wait);
> +		mutex_lock(&ashmem_mutex);

Let us replace mutex_lock with mutex_trylock, as done before the loop? Here
is there is an opportunity to not block other ashmem operations. Otherwise
LGTM. Also, CC stable.

thanks,

 - Joel

