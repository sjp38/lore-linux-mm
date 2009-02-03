Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 25E585F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 06:48:01 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n13Blwet001614
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 3 Feb 2009 20:47:58 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28FF745DE55
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 20:47:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E530E45DE51
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 20:47:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CEF2AE18006
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 20:47:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A814E38002
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 20:47:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: /proc/sys/vm/drop_caches: add error handling
In-Reply-To: <20090203113319.GA2022@elf.ucw.cz>
References: <20090203113319.GA2022@elf.ucw.cz>
Message-Id: <20090203204456.ECA3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  3 Feb 2009 20:47:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@suse.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> Document that drop_caches is unsafe, and add error checking so that it
> bails out on invalid inputs. [Note that this was triggered by Android
> trying to use it in production, and incidentally writing invalid
> value...]

Yup. good patch.

> -	return 0;
> +	int res;
> +	res = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
> +	if (res)
> +		return res;
> +	if (!write)
> +		return res;
> +	if (sysctl_drop_caches & ~3)
> +		return -EINVAL;
> +	if (sysctl_drop_caches & 1)
> +		drop_pagecache();
> +	if (sysctl_drop_caches & 2)
> +		drop_slab();
> +	return res;
>  }

I think following is clarify more.

	res = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
	if (res)
		return res;
	if (!write)
		return 0;
	if (sysctl_drop_caches & ~3)
		return -EINVAL;
	if (sysctl_drop_caches & 1)
		drop_pagecache();
	if (sysctl_drop_caches & 2)
		drop_slab();
	return 0;


otherthings, _very_ looks good to me. :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
